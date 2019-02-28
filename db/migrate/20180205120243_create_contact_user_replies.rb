class CreateContactUserReplies < ActiveRecord::Migration[5.1]
  def change
    create_table :contact_user_replies do |t|
      t.references :contact_us, foreign_key: true, index: true, type: :integer
      t.text :message
      t.timestamps
    end
  end
end
