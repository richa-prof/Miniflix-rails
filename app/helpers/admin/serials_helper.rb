module Admin::SerialsHelper
  
  def formatted_released_date_for(serial)
    released_date = serial.year

    return t('label.not_available') unless released_date.present?

    released_date.to_s(:full_date_month_and_year_format)
  end
end
