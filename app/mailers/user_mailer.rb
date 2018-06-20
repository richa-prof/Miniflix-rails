class UserMailer < ApplicationMailer

  def free_user_signup_email(user)
    subject = "Thank you for sign up on miniflix."
    variable = { USER_NAME: user.name }
    body = MandrillService.new(FreeUserTemplate, variable).call()
    mail(to: user.email, subject: subject, body: body, content_type: "text/html")
  end

  def reset_password_reminder_email(user)
    subject = 'Reset your Miniflix password'
    @user = user
    user_name = user.name
    @display_name = user_name.present? ? user_name.titleize : user.email
    mail(to: user.email, subject: subject)
  end

  def staff_member_signup_email(user)
    subject = 'Reset your Miniflix password'
    body = "Your are registered as Staff Member by Admin. Your temporary password is: #{user.temp_password} Please login Here : #{ENV['BLOG_LOGIN_URL']} and reset your password."
    mail(to: user.email, subject: subject, body: body, content_type: 'text/html')
  end

  def marketing_staff_member_signup_email(user)
    subject = 'Login to your Miniflix Marketing Staff Member account'
    @user = user
    user_name = user.name
    @display_name = user_name.present? ? user_name.titleize : user.email

    mail(to: user.email, subject: subject)
  end
end
