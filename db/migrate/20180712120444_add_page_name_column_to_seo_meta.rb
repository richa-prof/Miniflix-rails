class AddPageNameColumnToSeoMeta < ActiveRecord::Migration[5.1]
  def change
    add_column :seo_meta, :page_name, :string
  end
end
