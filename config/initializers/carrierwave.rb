CarrierWave.configure do |config|
  config.fog_credentials = {


    # Configuration for Amazon S3
    :provider              => 'AWS',
    :aws_access_key_id     => ENV['S3_KEY'],
    :aws_secret_access_key => ENV['S3_SECRET'],
    :region                => ENV['S3_VIDEO_REGION']
  }


  # For testing, upload files to local `tmp` folder.
  if Rails.env.test?
    config.storage = :file
  else
    config.storage = :fog
  end


  config.cache_dir = "#{Rails.root}/tmp/uploads"

  config.fog_directory    = ENV['S3_INPUT_BUCKET']

  config.fog_public     = false

end
