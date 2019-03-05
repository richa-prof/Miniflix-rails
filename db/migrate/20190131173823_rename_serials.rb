class RenameSerials < ActiveRecord::Migration[5.1]
  def change
    rename_table :serials, :admin_serials
  end
end
