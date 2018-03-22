class AddBitlyUrlToAdminMovie < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_movies, :bitly_url, :string
  end
end
