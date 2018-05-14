module UsersHelper

  def image_cloud_front_url(path)
    url = 'https://' +  ENV['cloud_front_url'] +'/'+ path
  end
end
