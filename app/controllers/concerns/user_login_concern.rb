module UserLoginConcern
  extend ActiveSupport::Concern

  def session_create
    session[:user_id]= @user.id
    session[:user_name]= @user.name
    redirect_to thankyou_path
  end

  def render_user_on_error
    @contact_us = ContactUs.new
    if @user.errors.present?
      error_msg = @user.errors.full_messages.to_sentence
    else
     error_msg = "Entered information is invalid, we can not process further"
    end
    flash.now[:error] = error_msg
    render :new
  end

  def redirect_on_success_according_to_devise
    if request.user_agent =~ /(iPhone|iPod|Android|webOS|Mobile|iPad)/
      redirect_to 'miniflix://mob?is_payment_success=true&error_code=0&msg=Payment successfully done.'
    else
      session_create
    end
  end

  def redirect_on_fail_according_to_devise
    if request.user_agent =~ /(iPhone|iPod|Android|webOS|Mobile|iPad)/
      redirect_to 'miniflix://mob?is_payment_success=false&error_code=2&msg=Your payment token is invalid.'
    else
      flash[:error] = "Something wrong with paypal"
      redirect_to signup_path
    end
  end
end