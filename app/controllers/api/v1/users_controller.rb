class Api::V1::UsersController < Api::V1::ApplicationController
  include Api::V1::Concerns::UserSerializeDataConcern

  before_action :authenticate_user!
  before_action :check_current_password, only: [:send_verification_code]
  before_action :check_verification_code, only: [:verify_verification_code]

  def send_verification_code
    if current_user.update_attributes(user_update_phone_params)
     response = { success: true,
                  user: serialize_user,
                  message: "Verification code is sent to your entered phone number, verify phone number for complete process." }
    else
      response = {success: false, message: current_user.errors}
    end
    render json: response
  end

  def verify_verification_code
    current_user.update_attribute('verification_code', nil)
    render json: { success: true,
                   user: serialize_user,
                   message: "Phone number is successfully updated" }
  end

  def my_activity
    user_video_last_stops = current_user.user_video_last_stops.order("updated_at DESC").paginate(page: params[:page])
    serialize_user_video_last_stop = ActiveModelSerializers::SerializableResource.new(user_video_last_stops,
        each_serializer: Api::V1::MyActivitySerializer)
    render json: {total_page: user_video_last_stops.total_pages, current_page: user_video_last_stops.current_page, activity: serialize_user_video_last_stop}

  end

  def make_invalid_for_thankyou_page
    current_user.update_attribute('valid_for_thankyou_page', false)
    render json: {success: true}
  end

  def billing_details
    user_transactions = UserPaymentTransaction.joins(:user_payment_method => :user).where('user_payment_methods.user_id = ?', current_user.id).order(created_at:'desc')

    user_transaction_serializer = ActiveModelSerializers::SerializableResource.new(user_transactions, each_serializer: Api::V1::UserPaymentTransactionSerializer)

    render json: { user_payment_transactions: user_transaction_serializer }
  end

  def update_profile
    unless user_update_profile_params.present?
      return render json: { success: false,
                            message: I18n.t('invalid_params.user.empty_image') }
    end

    if current_user.update(user_update_profile_params)
      return render json: { success: true,
                            user: serialize_user,
                            message: I18n.t('flash.user.image.successfully_updated') }
    else
      render json: { success: false,
                     message: current_user.errors.full_messages[0] }
    end
  end

  private

  def check_current_password
     render json: {success: false, message: "invalid current password" } if !authenticate_password
  end

  def authenticate_password
    current_user.valid_password?(params[:user][:current_password])
  end

  def user_update_phone_params
    params.require(:user).permit(:unconfirmed_phone_number)
  end

  def check_verification_code
     render json: {success: false, message: "invalid code" } unless current_user.valid_verification_code?(params[:verification_code])
  end

  def user_update_profile_params
    params.require(:user).permit(:image)
  end
end
