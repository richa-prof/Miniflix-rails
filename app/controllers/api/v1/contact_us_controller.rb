class Api::V1::ContactUsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create]

  def create
    contact_us = ContactUs.new(contact_us_params)
    if contact_us.save
      render json: {success: true, success_msg: "Details successfully saved"}
    else
      render json: {success: false, error_message: contact_us.errors}
    end
  end

  private

  def contact_us_params
    params.require(:contact_us).permit(:name,:email, :school, :occupation)
  end
end
