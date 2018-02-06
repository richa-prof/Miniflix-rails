class CreateUserFilmlists < ActiveRecord::Migration[5.1]
  def change
    create_table :user_filmlists do |t|
      t.references :user, foreign_key: true, index: true
      t.references :admin_movie, foreign_key: true, index: true
      t.boolean    :is_active, default: true
      t.timestamps
    end
  end
end
