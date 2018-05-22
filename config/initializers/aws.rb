Aws.config[:credentials] = Aws::Credentials.new(ENV['S3_KEY'], ENV['S3_SECRET'])
Aws.config[:region] = ENV['S3_REGION']