class AddColumnLanguageToAdminSerials < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_serials, :language, :string, null: false
  end
end
