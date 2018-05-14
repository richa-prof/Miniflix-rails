TRANSCODER = AWS::ElasticTranscoder::Client.new(region: ENV['S3_VIDEO_REGION']
)