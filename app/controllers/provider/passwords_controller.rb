class Provider::PasswordsController < Devise::PasswordsController
  layout 'provider_login'
  
  def new
    super do
      render file: 'provider/passwords/new' and return
    end
  end

  def edit
    super do
      render file: 'provider/passwords/edit' and return
    end
  end

  def create
    flash[:success] = 'Password reset instructions has been sent to specified email'
    super
  end
end