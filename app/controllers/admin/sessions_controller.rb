class Admin::SessionsController < Devise::SessionsController
  layout 'admin_login'

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    flash[:error] = 'Your session expired. Please try again!'
    redirect_to new_admin_user_session_path
  end

  def new
    super do
      render :file => 'admin/sessions/new' and return
    end
  end

  def create
    user = User.admin.find_by_email(params[:admin_user][:email])
    if user
      super
    else
      flash[:error] = 'Email is not valid for Admin!'
      redirect_to new_admin_user_session_path and return
    end
  end
end
