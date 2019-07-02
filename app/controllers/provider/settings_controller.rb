class Provider::SettingsController < ApplicationController
  layout 'provider'

  def new
    super do
      render :file => 'provider/sessions/new' and return
    end
  end

  def update
    @user = current_user
    pparams = provider_params.except(:current_password)
    success_msg = 'User account has been successfully updated'
    error_msg = 'An error occured while trying to update user account'
    if provider_params[:current_password] 
      if !passed_current_password_invalid? && @user.update_with_password(provider_params)
        flash[:success] = success_msg
        sign_in(@user, bypass: true, scope: :provider) if @user.encrypted_password_changed?
      else
        flash[:error] = error_msg
      end
    else
      if @user.update(provider_params)
        flash[:success] = success_msg
      else
        flash[:error] = error_msg
      end
    end
    respond_to do |format|
      format.js { render layout: false, content_type: 'text/javascript' }
      format.html { redirect_back(fallback_location: provider_settings_path) }
    end
  end

  def passed_current_password_invalid?
    if provider_params[:current_password] && provider_params[:password]
      if !@user.valid_password?(provider_params[:current_password])
        @user.errors.add(:password, 'specified as current is invalid!')
        return true
      end
    end
    return false
  end

  def index
  end

  private

  def provider_params
    params[:provider].permit(:name, :email, :image, :phone_number, :category, :id, :current_password, :password, :password_confirmation)
  end

  def configure_permitted_parameters
    update_attrs = [:password, :password_confirmation, :current_password]
    devise_parameter_sanitizer.permit :account_update, keys: update_attrs
  end

end
