class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.text :body
      t.string :commenter
      t.integer :user_id
      t.integer :blog_id, foreign_key: true
      t.timestamps
    end
  end
end
