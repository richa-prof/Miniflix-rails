class CreateMovieVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :movie_versions do |t|
      t.integer :movie_id, index: true
      t.integer :s3_multipart_upload_id, index: true
      t.string  :uploader
      t.string  :film_video
      t.string  :video_size
      t.string  :resolution
      t.timestamps
    end
  end
end
