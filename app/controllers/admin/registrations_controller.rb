class Admin::RegistrationsController < Devise::RegistrationsController

  def new
    super do
      render :file => 'admin/registrations/new' and return
    end
  end
end
