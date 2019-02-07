class AddSeasonsNumberToAdminSerials < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_serials, :seasons_number, :integer
  end
end
