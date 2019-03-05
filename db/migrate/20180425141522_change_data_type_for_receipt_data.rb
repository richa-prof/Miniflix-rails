class ChangeDataTypeForReceiptData < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :receipt_data, :text, :limit => 4294967295
  end
end
