class CreateLikedInfo < ActiveRecord::Migration[5.1]
  def change
    create_table :liked_info do |t|
      t.integer  :user_id, foreign_key: true, index: true
      t.integer  :thing_id
      t.string   :thing_type
      t.timestamps
    end
    add_index  :liked_info, [:thing_type, :thing_id]
  end
end
