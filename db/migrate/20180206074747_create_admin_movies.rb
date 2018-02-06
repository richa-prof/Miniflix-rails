class CreateAdminMovies < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_movies do |t|
      t.references :admin_genre, foreign_key: true
      t.integer    :s3_multipart_upload_id, foreign_key: true, index:true
      t.string     :name
      t.string     :title
      t.text       :description
      t.string     :film_video
      t.string     :video_type
      t.string     :video_size
      t.string     :video_format
      t.string     :directed_by
      t.date       :released_date
      t.string     :language
      t.date       :posted_date
      t.string     :star_cast
      t.string     :actors
      t.boolean    :downloadable
      t.string     :video_duration
      t.string     :uploader
      t.string     :festival_laureates
      t.boolean    :is_featured_film
      t.string     :version_file
      t.timestamps
    end
  end
end
