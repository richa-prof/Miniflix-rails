class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.text :body
      t.string :commenter
      t.integer :user_id
      t.references :blog, foreign_key: true, type: :integer
      t.timestamps
    end
  end
end
