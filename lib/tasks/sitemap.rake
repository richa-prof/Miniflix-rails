require 'aws-sdk'
require 'miniflix_sitemap'

namespace :sitemap do
  desc 'Upload the sitemap files to S3'
  task upload_to_s3: :environment do
    MiniflixSitemap.s3_upload
  end
end