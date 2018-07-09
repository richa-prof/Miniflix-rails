
class MiniflixSitemap
  def self.generate_sitemap
    # Set the host name for URL creation
    SitemapGenerator::Sitemap.default_host = ENV['BLOG_HOST']

    SitemapGenerator::Sitemap.public_path = 'tmp/sitemaps/'

    SitemapGenerator::Sitemap.create do
      add new_staff_user_session_path
      add blogs_path

      Blog.find_each do |blog|
        add blog_path(blog.slug), lastmod: blog.updated_at, changefreq: 'weekly'
      end
    end
  end

  def self.s3_upload
    puts 'Starting sitemap upload to S3...'

    s3 = AWS::S3.new( access_key_id: ENV['S3_KEY'],
                      secret_access_key: ENV['S3_SECRET'],
                      region: ENV['S3_VIDEO_REGION'] )

    s3_bucket = s3.buckets[ENV['S3_INPUT_BUCKET']]

    Dir.entries(File.join(Rails.root, 'tmp', 'sitemaps')).each do |file_name|
      next if ['.', '..', '.DS_Store'].include? file_name
      path = "sitemaps/#{file_name}"
      file = File.join(Rails.root, 'tmp', 'sitemaps', file_name)

      begin
        object = S3_BUCKET.object(path).upload_file(file, acl: 'public-read')
      rescue Exception => e
        raise e
      end
      puts "Saved #{file_name} to S3"
    end
  end
end
