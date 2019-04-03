class Serial < ApplicationRecord

  self.table_name = 'admin_serials'

  has_many :seasons, dependent: :destroy, foreign_key: "admin_serial_id"
  
  has_many :liked_things
#  has_many :user_likes, through: :liked_things, source: :user, source_type: 'thing_type'  #foreign_key: 'thing_id', foreign_type: 'thing_type',  dependent: :destroy
# should be:
# SELECT `users`.* FROM `users` INNER JOIN `liked_info` ON `users`.`id` = `liked_info`.`user_id` WHERE `liked_info`.`thing_id` = 28 AND `like_info.thing_type` = 'Serial'

  # associations for content provider
  has_many :own_films, as: :film
  has_many :owners, through: :own_films, source: :user
  has_one :rate, as: :entity

  has_one :serial_thumbnail, dependent: :destroy, foreign_key: "admin_serial_id"
  has_one :movie_trailer, dependent: :destroy, foreign_key: "admin_serial_id"
  belongs_to :genre, class_name: "Genre", foreign_key: "admin_genre_id"

  accepts_nested_attributes_for :serial_thumbnail

  PER_PAGE = 15
  ENTRY_TYPE = 1

  extend FriendlyId
  friendly_id :title, use: :slugged

  scope :alfa_order, -> { order(:name) }
  
  def user_likes
    q = "INNER JOIN liked_info ON users.id = liked_info.user_id WHERE liked_info.thing_id = #{id} AND liked_info.thing_type = 'Serial'"
    User.joins(q)
  end

  def owner
    owners&.first
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
    episodes.each do |ep|
      out.merge!(ep.movie_thumbnail.screenshot_urls_map)
    end
    out
  end

  def episodes
    Episode.where("season_id in (:list)", list: seasons.pluck(:id))
  end

  def mark_as_liked_by_user(user)
    user.liked_serials << self
  end

  def is_liked_by_user?(user)
    user_likes.include? user
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
      type: ENTRY_TYPE
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
        isLiked: true,  # is_liked_by_user?(user),
        stars: star_cast.to_s,
        seasons: seasons_extended_list
      )
    end
  end

  def self.fetch_new_serials(limit: PER_PAGE, offset: 0)
    new_episodes = Episode.new_entries #where("id not in (:list)", list: UserVideoLastStop.pluck(:id).uniq).order(:updated_at).limit(limit).offset(offset)
    p "new_episodes: #{new_episodes.inspect}"
    new_episodes.map {|ep| ep.season&.serial}.compact
  end

  def self.fetch_recent_watched_serials(limit: PER_PAGE, offset: 0)
    recent_episodes = Episode.recently_watched #where("id in (:list)", list: UserVideoLastStop.order(:updated_at).pluck(:id).uniq).order(:updated_at).limit(limit).offset(offset)
    #p "recent_episodes: #{recent_episodes.inspect}"    
    recent_episodes.map {|ep| ep.season&.serial}.compact
  end

  def self.fetch_top_watched_serials(limit: PER_PAGE, offset: 0)
    #q = "INNER JOIN (SELECT admin_movie_id, COUNT(*) AS cnt FROM user_video_last_stops GROUP BY admin_movie_id ORDER BY cnt DESC LIMIT 100) AS top_watched ON admin_movies.id = top_watched.admin_movie_id"
    top_watched_episodes = Episode.top_watched  #joins(q).limit(limit).offset(offset)
    #p "top_watched_episodes: #{top_watched_episodes.count}"
    top_watched_episodes.map {|ep| ep.season&.serial}.compact
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
      out << entry
    end
    out
  end

end
