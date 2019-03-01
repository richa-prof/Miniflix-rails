class AddThankYouFieldToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :valid_for_thankyou_page, :boolean, default: false
  end
end
