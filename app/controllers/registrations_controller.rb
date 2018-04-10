class RegistrationsController < Devise::RegistrationsController

  def update
    save_user_image
    save_staff_address
    save_social_media_link

    super
  end

  private

  def save_user_image
    image = staff_user_params.delete(:image)
    if image.present?
      resource.image = image
      resource.save
    end
  end

  def save_staff_address
    address = resource.address || resource.build_address
    address.assign_attributes(address_params)
    address.save if address.city_changed?
  end

  def save_social_media_link
    social_media_link = resource.social_media_link || resource.build_social_media_link
    social_media_link.assign_given_attributes(social_media_link_params)
    social_media_link.save
  end

  def address_params
    staff_user_params.require(:address).permit(:city)
  end

  def social_media_link_params
    staff_user_params.require(:social_media_link).permit(:facebook, :twitter, :google_plus, :linekdin)
  end

  def staff_user_params
    params.require(:staff_user)
  end
end
