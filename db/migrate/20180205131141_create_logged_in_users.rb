class CreateLoggedInUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :logged_in_users do |t|
      t.references :user, foreign_key: true, index: true
      t.string   "device_type"
      t.string   "device_token"
      t.string   "notification_from"
      t.timestamps
    end
  end
end
