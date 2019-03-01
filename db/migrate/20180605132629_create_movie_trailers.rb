class CreateMovieTrailers < ActiveRecord::Migration[5.2]
  def change
    create_table :movie_trailers do |t|
      t.string :file
      t.integer :s3_multipart_upload_id, foreign_key: true, index:true
      t.integer :admin_movie_id, foreign_key: true
      t.timestamps
    end
  end
end
