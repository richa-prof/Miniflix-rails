class AddReferencesToMovieTrailers < ActiveRecord::Migration[5.1]
  def change
    add_reference :movie_trailers, :admin_serial, foreign_key: true, type: :bigint
  end
end
