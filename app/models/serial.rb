class Serial < ApplicationRecord

  self.table_name = 'admin_serials'

  has_many :seasons, dependent: :destroy, foreign_key: "admin_serial_id"
  
  has_many :liked_things
#  has_many :user_likes, through: :liked_things, source: :user, source_type: 'thing_type'  #foreign_key: 'thing_id', foreign_type: 'thing_type',  dependent: :destroy
# should be:
# SELECT `users`.* FROM `users` INNER JOIN `liked_info` ON `users`.`id` = `liked_info`.`user_id` WHERE `liked_info`.`thing_id` = 28 AND `like_info.thing_type` = 'Serial'

  # associations for content provider
  has_one :own_film, as: :film
  has_one :owner, through: :own_film, source: :user
  has_one :rate, as: :entity, inverse_of: :entity # inverse_of important here! to save assocatiated object

  has_one :serial_thumbnail, dependent: :destroy, foreign_key: "admin_serial_id"
  has_one :movie_trailer, dependent: :destroy, foreign_key: "admin_serial_id"
  belongs_to :genre, class_name: "Genre", foreign_key: "admin_genre_id"

  alias_method :trailer, :movie_trailer
  alias_method :thumbnail, :serial_thumbnail

  accepts_nested_attributes_for :serial_thumbnail
  accepts_nested_attributes_for :rate, allow_destroy: true

  PER_PAGE = 15
  ENTRY_TYPE = 1

  extend FriendlyId
  friendly_id :title, use: :slugged

  scope :alfa_order, -> { order(:name) }
  
  def should_generate_new_friendly_id?
    title_changed?
  end


  def find_genre(id)
    genre = Genre.find(id)
    genre.name
  end

  def seasons_list
    season_numbers = self.seasons.pluck(:season_number)
    h = Hash.new
    arr = []
    season_numbers.each do |el|
      season = self.seasons.find_by(season_number: el)
      h[el] = season.episodes.count
    end
    arr << h
    return arr.first
  end

  def seasons_extended_list
    season_numbers = self.seasons.pluck(:season_number)
    h = Hash.new
    seasons.each do |season|
      h[season.season_number] = season.episodes.map {|ep| ep.format(mode: 'full')}
    end
    h
  end

  def screenshot_list
    out = {
      original: "",
      thumb330: "",
      thumb640: "",
      thumb800: ""
    }
    if serial_thumbnail
      out.merge! serial_thumbnail.screenshot_urls_map
    else
      Rails.logger.error "SerialThumbnail not exist for Serial #{id} !!"
    end
    # episodes.each do |ep|
    #   out.merge!(ep.movie_thumbnail.screenshot_urls_map)
    # end
    out
  end

  def episodes
    Episode.where("season_id in (:list)", list: seasons.pluck(:id))
  end

  # all users who liked this serial
  def user_likes
    q = "INNER JOIN liked_info ON users.id = liked_info.user_id WHERE liked_info.thing_id = #{id} AND liked_info.thing_type = 'Serial'"
    User.joins(q)
  end

  def mark_as_liked_by_user(user)
    if user.liked_serials.find_by(id: id)
      user.liked_serials.delete(id)
    else
      user.liked_serials << self
    end
  end

  def is_liked_by_user?(user)
    return false unless user
    user.liked_serials.find_by(id: id).present?
    #user_likes.include? user
  end

  def compact_response
    {
      id: id, 
      title: title.to_s, 
      year: year&.year.to_s, 
      genre_data: { 
        id: genre&.id, 
        name: genre&.name.to_s
      },
      seasons_data: seasons_list,
      screenshot: screenshot_list,
      type: ENTRY_TYPE,
      trailer: movie_trailer&.file
    }
  end

  def format(user: nil, mode: nil)
    case mode
    when "compact"
      compact_response
    else
      compact_response.merge!(
        director: directed_by.to_s, 
        description: description.to_s, 
        audio: language.to_s,
        isLiked: is_liked_by_user?(user),
        stars: star_cast.to_s,
        seasons: seasons_extended_list
      )
    end
  end

  def self.fetch_new_serials(limit: PER_PAGE, offset: 0)
    new_episodes = Episode.new_entries
    Rails.logger.debug "new_episodes: #{new_episodes.inspect}"
    sids = new_episodes.map {|ep| ep.season&.admin_serial_id}.compact.uniq
    Serial.where("id in (:ids)", ids: sids).order('updated_at desc').limit(limit).offset(offset)
  end

  def self.fetch_recent_watched_serials(limit: PER_PAGE, offset: 0)
    recent_episodes = Episode.recently_watched
    recent_episodes.map {|ep| ep.season&.serial}.compact
  end

  def self.fetch_top_watched_serials(limit: PER_PAGE, offset: 0)
    #q = "INNER JOIN (SELECT admin_movie_id, COUNT(*) AS cnt FROM user_video_last_stops GROUP BY admin_movie_id ORDER BY cnt DESC LIMIT 100) AS top_watched ON admin_movies.id = top_watched.admin_movie_id"
    #joins(q).limit(limit).offset(offset)
    top_watched_episodes = Episode.top_watched  
    top_watched_episodes.map {|ep| ep.season&.serial}.compact.uniq
  end

  def self.collect_genres_data(mode: nil)
    out = []
    Genre.all.each do |genre|
      genre_serials =  genre.serials.map {|s| s.format(mode: 'compact')}.compact.uniq
      genre_movies = genre.movies.map {|s| s.format(mode: 'compact')}.compact.uniq if mode == 'with_movies'
      entry = {
        genre_data: {
          id: genre&.id, 
          name: genre&.name.to_s
        }
      }
      if mode != 'with_movies'
        entry[:serials] = genre_serials
      else
        entry[:data] = genre_serials + genre_movies
      end
      out << entry if entry.dig(:genre_data, :id)
    end
    out
  end

end
