class Provider::SessionsController < Devise::SessionsController
  layout 'provider_login'

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    flash[:error] = 'Your session expired. Please try again!'
    redirect_to new_provider_user_session_path
  end

  prepend_before_action :require_no_authentication, only: :cancel

  def new
    super do
      render :file => 'provider/sessions/new' and return
    end
  end

  def create
    user = User.provider.find_by_email(params[:provider_user][:email])
    if user
      super
    else
      flash[:error] = 'Email is not valid for Content Provider!'
      redirect_to new_provider_user_session_path and return
    end
  end
end
