class CreateOrganizationsUsersInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :organizations_users_infos do |t|
      t.references :user, foreign_key: true
      t.references :organization, foreign_key: true
      t.integer :role

      t.timestamps
    end
  end
end
