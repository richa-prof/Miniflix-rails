class Provider::SettingsController < ApplicationController
  layout 'provider'

  def new
    super do
      render :file => 'provider/sessions/new' and return
    end
  end

  def create
    user = User.provider.find_by_email(params[:admin_user][:email])
    if user
      super
    else
      flash[:error] = 'Email is not valid for Content Provider!'
      redirect_to new_provider_user_session_path and return
    end
  end

  def index
  end
end
