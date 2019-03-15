class Provider::RegistrationsController < Devise::RegistrationsController
  layout 'provider_login'
  
  def new
    super do
      render :file => 'provider/registrations/new' and return
    end
  end
end
