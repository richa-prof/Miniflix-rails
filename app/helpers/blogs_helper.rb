module BlogsHelper

  def formatted_social_media_link(link)
    link.presence || 'javascript:void(0)'
  end
end
