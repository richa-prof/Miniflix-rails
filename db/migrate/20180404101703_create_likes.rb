class CreateLikes < ActiveRecord::Migration[5.1]
  def change
    create_table :likes do |t|
      t.integer :user_id
      t.references :blog, foreign_key: true, type: :integer
      t.timestamps
    end
  end
end
