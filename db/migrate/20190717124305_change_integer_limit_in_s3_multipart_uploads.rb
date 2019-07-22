class ChangeIntegerLimitInS3MultipartUploads < ActiveRecord::Migration[5.1]
  def change
    change_column :s3_multipart_uploads, :size, :integer, limit: 8
  end
end
