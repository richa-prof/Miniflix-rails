class CreateSocialMediaLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :social_media_links do |t|
      t.string :link
      t.string :link_type
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
