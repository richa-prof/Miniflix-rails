class UserMailer < ApplicationMailer

  def free_user_signup_email(user)
    subject = "Thank you for sign up on miniflix."
    variable = { USER_NAME: user.name }
    body = MandrillService.new(FreeUserTemplate, variable).call()
    mail(to: user.email, subject: subject, body: body, content_type: "text/html")
  end
  
end
