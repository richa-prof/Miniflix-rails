class CreateBlogSubscribers < ActiveRecord::Migration[5.2]
  def change
    create_table :blog_subscribers do |t|
      t.string :name
      t.string :email
      t.integer :user_id

      t.timestamps
    end
  end
end
