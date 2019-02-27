class CreateMovieTrailers < ActiveRecord::Migration[5.1]
  def change
    create_table :movie_trailers do |t|
      t.string :file
      t.integer :s3_multipart_upload_id, foreign_key: true, index:true
      t.references :admin_movie, foreign_key: true, type: :integer
      t.timestamps
    end
  end
end
