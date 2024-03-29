class Movie < ApplicationRecord
  self.table_name = 'admin_movies'

  # CONSTANT STARTS
  PER_PAGE = 6
  ENTRY_TYPE = 2

  SHARE_ON = ['facebook', 'twitter']

  SUPPORTED_FORMATS = %w(webm wmv avi mp4 mkv mov mpeg)

  TRANSCODE_VERSION = {
    generic_full_hd: '1505471425821-qrjgkg',
    generic_hd_720: '1505471608525-v75q4b',
    generic_2m: '1351620000001-200010',
    generic_15m: '1351620000001-200020',
    generic_1m: '1351620000001-200030',
    generic_600k: '1351620000001-200040',
    generic_400k: '1351620000001-200050' }

  TRANSCODE_VERSION_MOBILE = {
    generic_720p: '1351620000001-000010',
    generic_480p: '1351620000001-000020',
    generic_320p: '1351620000001-000061'
  }
  # CONSTANT ENDS

  # Ref.: https://github.com/norman/friendly_id
  extend FriendlyId
  friendly_id :name, use: :slugged
  # To update the slug of old records please run below query.
  # Movie.find_each(&:save)

  # ASSOCIATIONS
  belongs_to :genre, class_name: "Genre", foreign_key: "admin_genre_id"
  belongs_to :season, optional: true

  has_one :movie_thumbnail, dependent: :destroy, foreign_key: "admin_movie_id", inverse_of: :movie
  has_one :movie_trailer, dependent: :destroy, foreign_key: "admin_movie_id"
  has_many :notifications, dependent: :destroy, foreign_key: "admin_movie_id"

  has_many :user_filmlists, dependent: :destroy, foreign_key: "admin_movie_id"
  alias_method :favorite_for_users, :user_filmlists

  # point in timeline where user stopped watching movie
  has_many :user_video_last_stops, dependent: :destroy, foreign_key: "admin_movie_id"
  alias_method  :watched_by_users, :user_video_last_stops

  has_many :movie_captions, dependent: :destroy, foreign_key: "admin_movie_id"
  has_many :movie_versions, dependent: :destroy

  # associations for content provider
  has_one :own_film, as: :film, dependent: :destroy
  has_one :owner, through: :own_film, source: :user
  has_one :rate, as: :entity, inverse_of: :entity # inverse_of important here! to save associated object

  accepts_nested_attributes_for :movie_thumbnail
  accepts_nested_attributes_for :rate, allow_destroy: true

  # CALLBACKS
  before_save :create_bitly_url, if: -> { slug_changed? }
  before_validation :fix_attrs
  # after_create :write_file
  after_save :write_file, if: :saved_change_to_s3_multipart_upload_id?
  after_update :send_notification


  # SCOPES
  default_scope  { where(kind: self.name.downcase) }

  scope :featured, -> { where(is_featured_film: true) }
  scope :episodes, -> { where(kind: 'episode') }
  scope :my_movies, -> (user) { joins(:user_filmlists).where('user_filmlists.user_id = ?', user.id) }

  # DELIGATES
  delegate :name, to: :genre, prefix: :genre,  allow_nil: true

  validates_presence_of :title

  self.per_page = PER_PAGE

  # ===== Class methods Start =====
  class << self
    def delete_movie_from_s3(s3_multipart_obj, version_file)
      s3 = AWS::S3.new( access_key_id: ENV['S3_KEY'],
                        secret_access_key: ENV['S3_SECRET'],
                        region: ENV['S3_VIDEO_REGION'] )

      # s3 uploader file delete and api version file delete
      # response = s3.client.delete_object(
      #   bucket_name: ENV['S3_INPUT_BUCKET'],
      #   key: s3_multipart_obj.key
      # )

      movie_key_array = s3_multipart_obj.key.split('/')
      s3file_prefix = movie_key_array.first
      s3.buckets[ENV['S3_INPUT_BUCKET']].objects.with_prefix(s3file_prefix).delete_all
      # elastic transcoder file delete
      # file_name = File.basename(version_file)
      # version_file.slice!(file_name)
      # s3.buckets[ENV['S3_OUTPUT_BUCKET']].objects.with_prefix(version_file).delete_all

      s3_multipart_obj.destroy
    end

    def search(search_query)
      key = "%#{search_query}%"

      # Movie.where('name LIKE :search OR title LIKE :search OR festival_laureates LIKE :search', search: key).order(:name)
      Movie.where('(name LIKE :search OR title LIKE :search OR festival_laureates LIKE :search) AND s3_multipart_upload_id IS NOT NULL', search: key).order(:name)
    end

    def battleship_movies_name_arr
      [ 'Silent Child',
        'Madam Black',
        'Super Sex',
        'Clones',
        'The Pond',
        'The Phone Call',
        'Stutterer',
        'A Good Story' ]
    end

    def battleship_movies
      Movie.where(name: Movie.battleship_movies_name_arr)
    end

    def popular_movies(target_count=nil)
      movies_arr = Movie.joins(:user_video_last_stops)
                   .group("admin_movies.id")
                   .select("admin_movies.*, sum(user_video_last_stops.watched_count) AS total_watches")
                   .order("total_watches DESC")

      return movies_arr unless target_count.present?
      movies_arr.first(target_count)
    end

    def new_entries_for_user(user: nil, limit: nil, offset: 0)
      where("id not in (:list)", list: UserVideoLastStop.pluck(:id).uniq).order("updated_at desc").limit(limit).offset(offset)
    end

    def new_entries(limit: PER_PAGE, offset: 0)
      order("updated_at desc").limit(limit).offset(offset)
    end

    def recently_watched(limit: PER_PAGE, offset: 0)
      where("id in (:list)", list: UserVideoLastStop.order(:updated_at).pluck(:id).uniq).order(:updated_at).limit(limit).offset(offset)
    end

    def top_watched(limit: PER_PAGE, offset: 0)
      q = "INNER JOIN (SELECT admin_movie_id, COUNT(*) AS cnt FROM user_video_last_stops GROUP BY admin_movie_id ORDER BY cnt DESC LIMIT 100) AS top_watched ON admin_movies.id = top_watched.admin_movie_id"
      joins(q).limit(limit).offset(offset)
    end

  end
  # ===== Class methods End =====

  # ===== Instance methods Start =====
  def should_generate_new_friendly_id?
    name_changed?
  end

  def hls_movie_url
    version_file.present? ? ENV['VERSION_FILE_CLOUD_FRONT_URL'] + version_file : nil
  end

  def active_movie_captions
    self.movie_captions.active_caption
  end

  def set_is_featured_film_false
    self.update(is_featured_film: false)
  end

  def has_trailer?
    movie_trailer.try(:file).present?
  end

  def write_file
    movie = self
    # FIXME
    return unless s3_multipart_upload_id
    s3_upload = S3Multipart::Upload.find(movie.s3_multipart_upload_id)
    #folder_environment_name =  "streaming_#{Rails.env}"
    folder_environment_name =  "streaming_development"
    output_key_prefix = "#{folder_environment_name}/#{movie.id.to_s}/"
    new_file_name = fetch_movie_file_name(s3_upload.name)

    # call transcode video method to create job of aws transcode
    trancode_videos_for_web(s3_upload, output_key_prefix, new_file_name )
    trancode_videos_for_mobile(s3_upload, movie, new_file_name)

    file_name = output_key_prefix + new_file_name + '.m3u8'
    movie.version_file = file_name

    movie.save(validate: false)
  end

  def trancode_videos_for_web(s3_upload_obj, file_name_prefix, m3u8_file_name)
    # Aws elastic transcoder
    pipeline_id = ENV['S3_TRANSCODE_PIPELINE']
    input_key = s3_upload_obj.key

    input = { key: input_key, frame_rate: 'auto', resolution: 'auto', aspect_ratio: 'auto' }
    segment = ENV['segment_duration']

    outputs = []
    TRANSCODE_VERSION.each do |version_key, version_value|
      outputs << {
        key: "#{version_key}/#{m3u8_file_name}",
        preset_id: version_value,
        segment_duration: segment
      }
    end

    #playlist
    playlist = {
      name: m3u8_file_name,
      format: 'HLSv3',
      output_keys: outputs.map { |output| output[:key] }
    }

    job = TRANSCODER.create_job(
      pipeline_id: pipeline_id,
      input: input,
      output_key_prefix: file_name_prefix,
      outputs: outputs,
      playlists: [playlist]
      )
      puts "job created for web"
      puts "======================================================"
  end

  def fetch_movie_file_name(file)
    file_extension =  File.extname(file)
    file.slice!(file_extension)
    file.underscore.parameterize(separator: '_')
  end

  def trancode_videos_for_mobile(s3_upload_obj, admin_movie, version_file_name)
    Rails.logger.debug ">>>>> transcode_videos_for_mobile  <<<<"
    pipeline_id = ENV['S3_TRANSCODE_PIPELINE_Mobile']
    input_key = s3_upload_obj.key
    input = { key: input_key }
    movie_key = s3_upload_obj.key
    key_array = movie_key.split('/')
    output_key_prefix = key_array.first
    if admin_movie.movie_versions.present?
      admin_movie.movie_versions.delete_all
    end
    outputs = []
    TRANSCODE_VERSION_MOBILE.each do |version_key, version_value|
      file_resolution = version_key.to_s.scan(/\d+/).first
      file_name = "#{version_file_name}#{file_resolution}.mp4"
      outputs << {
        key: file_name,
        preset_id: version_value
      }
      Rails.logger.debug ">>> creating movie version for resolution #{file_resolution} <<<"
      mv = admin_movie.movie_versions.create(film_video: "#{output_key_prefix}/#{file_name}", resolution: file_resolution )
      #Rails.logger.debug mv.errors.full_messages
    end
    job = TRANSCODER.create_job(
      pipeline_id: pipeline_id,
      input: input,
      output_key_prefix: output_key_prefix + '/',
      outputs: outputs)
    puts "job created for mobile site under #{output_key_prefix} for #{admin_movie.id}"
    puts "======================================================================"
  end

  # ===== Instance methods End =====

  # ======= Related to mobile API's start =======

  def movie_view_by_user?(user_id)
    (self.user_filmlists.find_by_user_id user_id).present?
  end

  def as_json(mode = nil)
    case mode
    when "full_movie_detail"
      return super(except: [
        :created_at, :updated_at, :version_file, :uploader, :s3_multipart_upload_id
      ]).merge(
        movie_screenshot: screenshot_list,
        captions: self.movie_captions.map(&:as_json),
        film_video: film_video_map,
        genre_name: genre_name
      )
    when "genre_wise_list"
      return super(only: [:id, :name, :admin_genre_id]).merge(movie_screenshot: movie_screenshot_list)
    when 'genres_with_latest_movie'
      return super(only: [:id, :name, :title, :description, :language, :video_duration, :admin_genre_id]).merge(film_video: fetch_movie_urls, genre_name: genre_name, movie_screenshot: movie_screenshot_list)
    else
      movie_detail =  super(only: [:id, :name, :title, :description, :language, :video_duration, :admin_genre_id]).merge(film_video: fetch_movie_urls, genre_name: genre_name, movie_screenshot: movie_screenshot_list)
      return movie_detail
    end
  end

  # invalid ? use film_video_map instead
  def fetch_movie_urls
    movie_urls = {}
    movie_urls[:hls] = ENV['VERSION_FILE_CLOUD_FRONT_URL'] + version_file if version_file.present?
    self.movie_versions.each do |version|
      movie_urls["video_"+version.resolution.to_s]  = CommonHelpers.cloud_front_url(version.film_video)
    end
    movie_urls
  end

  # invalid? use screenshot_list instead
  def movie_screenshot_list
    movie_thumbnail ? movie_thumbnail.screenshot_urls_map : {}
  end

  def fetch_last_stop(user)
    user_video_last_stop = user.user_video_last_stops.find_by(admin_movie_id: self.id)
    user_video_last_stop.present? ? user_video_last_stop.last_stopped : 0
  end

  def movie_details_hash_for_notification
    target_path = movie_thumbnail.thumbnail_screenshot.carousel_thumb.try(:path)

    { movie_id: id,
      name: name,
      realesed: created_at,
      image: CommonHelpers.cloud_front_url(target_path)
    }
  end

  # ======= Related to mobile API's end =======

  def new_movie_added_notification_message
    I18n.t( 'contents.movie.new_movie_added_notification_message', movie_name: self.name )
  end

  def screenshot_list
    out = {
      original: "",
      thumb330: "",
      thumb640: "",
      thumb800: ""
    }
    if movie_thumbnail
      out.merge!(movie_thumbnail.screenshot_urls_map)
    else
      out
    end
  end


  def compact_response
    {
      id: id,
      title: name.to_s,
      year: created_at.year.to_s,
      genre_data: {
        id: genre&.id,
        name: genre&.name.to_s
      },
      screenshot: screenshot_list,
      type: ENTRY_TYPE,
      trailer: movie_trailer&.file
    }
  end

  def short_response
    {
      id: id,
      name: name.to_s,
      title: name,
      description: description,
      language: language,
      video_duration: video_duration,
      genre_name: genre&.name.to_s,
      last_stopped: user_video_last_stops.last.as_json(only: [:total_time, :last_stopped, :watched_percent]),
      film_video: film_video_map,
      movie_screenshot: screenshot_list
    }
  end

  def film_video_map
    h = {
      hls: film_video || '',
      video_720: '',
      video_480: '',
      video_320: ''
    }
    upload_host = film_video.split('/').slice(0,3).join('/') if film_video
    movie_versions.each do |mv|
      h["video_#{mv.resolution}".to_sym] = film_video ? "#{upload_host}/#{mv.film_video}" : ''
    end
    h
  end

  def format(mode: nil)
    case mode
    when "compact"
      compact_response
    when 'short'
      short_response
    when 'full'
      short_response.merge!(
        admin_genre_id: admin_genre_id,
        captions: movie_captions.map(&:as_json),
        trailer: movie_trailer&.file
      )
      # super(except: [:created_at, :updated_at, :version_file, :uploader, :s3_multipart_upload_id]).merge(movie_screenshot: movie_screenshot_list, captions: self., film_video: fetch_movie_urls, genre_name: genre_name)
    else # 'browse'
      compact_response.merge!(
       film_video: film_video_map,
       screenshot: screenshot_list
      )
    end
  end


  private

  def create_bitly_url
    bitly = Bitly.client.shorten(movie_show_url)
    self.bitly_url = bitly.short_url
  end

  def fix_attrs
    name = S3Multipart::Upload.find(s3_multipart_upload_id).name if s3_multipart_upload_id.present?
    self.slug ||= name.gsub(/[\W]/,'-').downcase
    self.title ||= self.name
  end

  def movie_show_url
     "#{ENV['Host']}/movies/#{self.slug}"
  end

  def send_notification
    if title_was.nil? && title.present?  # saved_change_to_attribute?(:title)
      Notification.send_movie_added_push_notification(self)
    end
  end
end
