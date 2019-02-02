class AddSlugToSerials < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_serials, :slug, :string
    add_index :admin_serials, :slug, unique: true
  end
end
