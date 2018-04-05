class RegistrationsController < Devise::RegistrationsController

  def update
    save_staff_address
    save_social_media_link

    super
  end

  private

  def save_staff_address
    address = resource.address || resource.build_address
    address.update(address_params)
  end

  def save_social_media_link
    social_media_link = resource.social_media_link || resource.build_social_media_link
    social_media_link.update(social_media_link_params)
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
