class CreateFreeMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :free_members do |t|
      t.string :email, null: false
      t.timestamps
    end
  end
end
