class Provider::RegistrationsController < Devise::RegistrationsController
  layout 'provider_login'
  
  def new
    super do
      render :file => 'provider/registrations/new' and return
    end
  end

  def create
    super
  end

  private

  def after_sign_up_path_for(_resource)
    sign_in(:user,_resource)
    provider_dashboard_path
  end


   def sign_up_params
    params.require(:provider_user).permit(:name, :email, :password, :password_confirmation, :category, :phone_number)
   end
end
