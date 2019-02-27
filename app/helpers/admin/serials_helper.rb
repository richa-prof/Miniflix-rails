module Admin::SerialsHelper

  def formatted_released_date_for_serial(serial)
    released_date = serial&.year

    return t('label.not_available') unless released_date&.present?

    released_date.to_s(:full_date_month_and_year_format)
  end

  def render_thumbnail_image_for(is_edit_mode, thumbnail_type, thumbnail_screenshot)
    target_image = if is_edit_mode && thumbnail_screenshot.present?
                        CommonHelpers.cloud_front_url_for_serial(thumbnail_screenshot)
                      else
                        get_default_thumbnail_url_for(thumbnail_type)
                      end

    image_tag(target_image).html_safe
  end

  def get_default_thumbnail_url_for_serial(thumbnail_type)
    case thumbnail_type
    when 'thumbnail_640_screenshot'
      'admin/upload_img640.jpg'
    when 'thumbnail_screenshot'
      'admin/upload_img330.png'
    when 'thumbnail_800_screenshot'
      'admin/upload_img800.png'
    else
      'admin/upload_img.png'
    end
  end
end
