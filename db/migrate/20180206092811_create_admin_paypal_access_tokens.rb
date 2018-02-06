class CreateAdminPaypalAccessTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_paypal_access_tokens do |t|
      t.string :access_token
      t.string :mode
      t.string :grant_type
      t.timestamps
    end
  end
end
