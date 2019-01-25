# Change to series
json.array!(@admin_movies) do |admin_movie|
  json.extract! admin_movie, :id, :name, :title, :description, :film_video, :video_type, :video_size, :video_format, :directed_by, :released_date, :language, :posted_date, :star_cast, :actors
  json.url admin_movie_url(admin_movie, format: :json)
end
