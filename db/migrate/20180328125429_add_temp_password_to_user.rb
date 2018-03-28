class AddTempPasswordToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :temp_password, :string
  end
end
