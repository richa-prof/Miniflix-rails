class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|
      t.string :city
      t.references :user, foreign_key: true, type: :integer
      t.timestamps
    end
  end
end
