class AddCommenterEmailToComment < ActiveRecord::Migration[5.1]
  def change
  	add_column :comments, :commenter_email, :string
  end
end
