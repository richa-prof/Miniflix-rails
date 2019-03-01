class RenameLinekdinToLinkedin < ActiveRecord::Migration[5.2]
  def change
    rename_column :social_media_links, :linekdin, :linkedin
  end
end
