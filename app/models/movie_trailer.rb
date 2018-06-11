class MovieTrailer < ApplicationRecord
  belongs_to :movie, :foreign_key => 'admin_movie_id'

  # ===== Class methods Start =====
  class << self
    def delete_file_from_s3(s3_multipart_obj)
      s3 = AWS::S3.new( access_key_id: ENV['S3_KEY'],
                        secret_access_key: ENV['S3_SECRET'],
                        region: ENV['S3_VIDEO_REGION'] )

      movie_key_array = s3_multipart_obj.key.split('/')
      s3file_prefix = movie_key_array.first
      s3.buckets[ENV['S3_INPUT_BUCKET']].objects.with_prefix(s3file_prefix).delete_all

      puts "<<<<< MovieTrailer::delete_file_from_s3 : #{s3_multipart_obj.inspect} <<<<<"
      Rails.logger.debug "<<<<< MovieTrailer::delete_file_from_s3 : #{s3_multipart_obj.inspect} <<<<<"

      s3_multipart_obj.destroy
    end
  end
  # ===== Class methods End =====

end
