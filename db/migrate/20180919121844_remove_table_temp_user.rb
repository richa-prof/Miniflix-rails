class RemoveTableTempUser < ActiveRecord::Migration[5.1]
  def up
    drop_table :temp_users
  end

  def down
    create_table :temp_users do |t|
      t.string :registration_plan
      t.string :email
      t.string :name
      t.string :password
      t.string :sign_up_from
      t.string :uid
      t.string :provider
      t.string :token
      t.string :auth_token
      t.string :image
      t.string :expires_at
      t.timestamps
    end
  end
end
