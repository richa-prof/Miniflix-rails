class AddCategoryToUsers < ActiveRecord::Migration[5.1]
  def change
     add_column :users, :category, :string, default: "general"
  end
end
