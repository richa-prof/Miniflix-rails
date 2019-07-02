class CreateAdminMovieCaptions < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_movie_captions do |t|
      t.integer :admin_movie_id, foreign_key: true, index: true
      t.string :language
      t.string :caption_file
      t.boolean :status
      t.boolean :is_default
      t.timestamps
    end
  end
end
