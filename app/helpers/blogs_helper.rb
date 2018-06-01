module BlogsHelper

  SHARE_ON = %w(facebook twitter)

  def get_share_button(share_on)
    str = case share_on
          when 'facebook'
            "<i class='fa fa-facebook'></i>"
          when 'twitter'
            "<i class='fa fa-twitter'></i>"
          end

    str.html_safe
  end

  def get_share_url(blog, share_on)
    title = blog.title
    description = blog.description
    target_url = blog_url(id: blog.slug)

    url = case share_on
          when 'facebook'
            "http://www.facebook.com/sharer/sharer.php?u=#{target_url}&title=#{title}&description=#{description}"
          when 'twitter'
            "https://twitter.com/intent/tweet?url=#{target_url}&text=#{title}"
          end

    url
  end

  def formatted_social_media_link(link)
    link.presence || 'javascript:void(0)'
  end

  def staff_location(staff)
    staff.address.try(:city).presence || '-'
  end

  def profile_path_for(user)
    # Returns the Dashboard path if the logged in staff clicks on his own profile link.
    if current_staff_user.present? && (current_staff_user == user)
      root_path
    else
      profile_path(user)
    end
  end
end
