class AddReferencesToMovieTrailers < ActiveRecord::Migration[5.2]
  def change
    add_reference :movie_trailers, :admin_serial, foreign_key: true
  end
end
