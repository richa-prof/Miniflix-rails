json.array!(@admin_genres) do |admin_genre|
  json.extract! admin_genre, :id, :name
  json.url admin_genre_url(admin_genre, format: :json)
end
