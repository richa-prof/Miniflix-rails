module CommonHelpers

  module_function

  def cloud_front_url(path)
    ENV['CLOUD_FRONT_URL'] + path if path.present?
  end

  def cloud_front_url_for_serial(path)
    path if path.present?
  end
end
