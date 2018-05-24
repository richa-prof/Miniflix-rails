class AddBattleshipToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :battleship, :boolean
  end
end
