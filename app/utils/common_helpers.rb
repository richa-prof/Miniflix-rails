module CommonHelpers

  module_function

  def cloud_front_url(path)
    ENV['CLOUD_FRONT_URL'] + path.path if path.present?
  end
end
