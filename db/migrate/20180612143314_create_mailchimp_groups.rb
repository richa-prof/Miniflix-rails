class CreateMailchimpGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :mailchimp_groups do |t|
      t.string :list_id
      t.string :name
      t.string :slug

      t.timestamps
    end
  end
end
