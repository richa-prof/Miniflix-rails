class AddUploaderToMovieTrailer < ActiveRecord::Migration[5.1]
  def change
    change_table :movie_trailers do |t|
      t.string :uploader
    end
  end
end
