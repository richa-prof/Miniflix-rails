class MarketingStaff::SessionsController < Devise::SessionsController
  layout 'admin_login'

  def new
    super do
      render :file => 'marketing_staff/sessions/new' and return
    end
  end

  def create
    user = User.marketing_staff.find_by_email(params[:marketing_staff_user][:email])
    if user
      super
    else
      flash[:error] = 'Email is not valid for Marketing Staff!'
      redirect_to new_marketing_staff_user_session_path and return
    end
  end
end
