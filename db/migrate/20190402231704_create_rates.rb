class CreateRates < ActiveRecord::Migration[5.1]
  def change
    create_table :rates do |t|
      t.integer  :entity_id
      t.string   :entity_type
      t.string   :notes
      t.float	 :price
      t.integer	 :discount
      t.timestamps
    end
    add_index  :rates, [:entity_type, :entity_id]
  end
end
