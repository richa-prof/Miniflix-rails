class SessionsController < Devise::SessionsController
  devise_group :blogger, contains: [:staff_user]

  def create
    staff_user = User.admin.find_by_email(params[:staff_user][:email])
    if staff_user.staff?
      super
    else
      flash[:alert] = 'You are not authorized for this feature!'
      redirect_to new_staff_user_session_path
    end
  end
end
