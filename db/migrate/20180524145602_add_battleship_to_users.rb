class AddBattleshipToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :battleship, :boolean
  end
end
