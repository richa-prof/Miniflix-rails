class CreateLikes < ActiveRecord::Migration[5.1]
  def change
    create_table :likes do |t|
      t.integer :user_id
      t.integer :blog_id, foreign_key: true
      t.timestamps
    end
  end
end
