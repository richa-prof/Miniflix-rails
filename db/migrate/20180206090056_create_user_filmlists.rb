class CreateUserFilmlists < ActiveRecord::Migration[5.1]
  def change
    create_table :user_filmlists do |t|
      t.integer :user_id, foreign_key: true, index: true
      t.integer :admin_movie_id, foreign_key: true, index: true
      t.boolean    :is_active, default: true
      t.timestamps
    end
  end
end
