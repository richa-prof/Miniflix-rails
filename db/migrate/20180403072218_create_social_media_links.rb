class CreateSocialMediaLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :social_media_links do |t|
      t.string :facebook
      t.string :twitter
      t.string :google_plus
      t.string :linekdin
      t.integer :user_id, foreign_key: true
      t.timestamps
    end
  end
end
