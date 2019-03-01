class CreateContactUs < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_us do |t|
      t.string :name
      t.string :email
      t.string :school
      t.string :occupation
      t.timestamps
    end
  end
end
