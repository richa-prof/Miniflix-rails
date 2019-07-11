class CreateOrganizations < ActiveRecord::Migration[5.1]
  def change
    create_table :organizations do |t|
      t.string :org_name
      t.integer :no_of_students
      t.timestamps
    end
  end
end
