Aws.config[:credentials] = Aws::Credentials.new(ENV['S3_KEY'], ENV['S3_SECRET'])
Aws.config[:region] = ENV['S3_VIDEO_REGION']

S3_BUCKET = Aws::S3::Resource.new.bucket(ENV['S3_INPUT_BUCKET'])
