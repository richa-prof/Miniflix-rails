class CreateContactUserReplies < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_user_replies do |t|
      t.integer :contact_us_id, foreign_key: true, index: true
      t.text :message
      t.timestamps
    end
  end
end
