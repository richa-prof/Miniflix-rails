class Api::V1::ContactUsController < Api::V1::ApplicationController

  def create
    contact_us = ContactUs.new(contact_us_params)
    if contact_us.save
      render json: {success: true, message: "Details successfully saved"}
    else
      render json: {success: false, message: contact_us.errors}
    end
  end

  private

  def contact_us_params
    params.require(:contact_us).permit(:name,:email, :school, :occupation)
  end
end
