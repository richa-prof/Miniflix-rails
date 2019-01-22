module CommonHelpers

  module_function

  def cloud_front_url(path)
    'https://d32c9chnc7rnl8.cloudfront.net/' + path if path.present?
  end
end
