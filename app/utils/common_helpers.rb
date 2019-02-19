module CommonHelpers

  module_function

  def cloud_front_url(path)
    path if path.present?
  end
end
