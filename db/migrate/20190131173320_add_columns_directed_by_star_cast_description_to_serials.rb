class AddColumnsDirectedByStarCastDescriptionToSerials < ActiveRecord::Migration[5.2]
  def change
    add_column :serials, :directed_by, :string, null: false
    add_column :serials, :star_cast, :string, null: false
    add_column :serials, :description, :text, null: false
  end
end
