require "mandrill"

class UserNotifier < ApplicationMailer
	default :from => 'info@miniflix.tv'
	# default :from => 'vedtest2@gmail.com'
	layout 'mailer'

  def send_free_user_signup_email(user)
    user = user
    subject = "Thank you for sign up on miniflix."
    merge_vars = {
      "USER_NAME" => user.name
    }
    body = mandrill_template("Free-user-signup-mail", merge_vars)

    send_mail(user.email, subject, body)
  end

	# send a signup email to the user, pass in the user object that contains the user's email address
	def send_signup_email(user)
		user = user
    subject = "Thank you for sign up on miniflix."
    merge_vars = {
      "USER_NAME" => user.name
    }
    body = mandrill_template("Paid-user-signup-mail", merge_vars)

    send_mail(user.email, subject, body)
	end

	def send_subscription_over_email(user,payment_expire_date)
		@user = user
		@payment_expire_date = payment_expire_date
	    mail( :to => @user.email, :subject => 'Your miniflix subscription plan is finish.')
	end
	
	def send_reply_mail_to_visitor(visitor,reply_message)
		@visitor = visitor
		@reply_message = reply_message
		mail( :to => @visitor.email, :subject => 'Reply from miniflix admin.')
	end
	
	def send_reset_password_instruction(user,token)
		@user = user
		@token = token
	  mail( :to => @user.email, :subject => 'Reset Password instruction' )
	end

	def send_invoice_mail_to_user(user,amount,charged_to,transaction_id,payment_date,expire_date)
		@user = user
		@amount = amount
		@charged_to = charged_to
		@transaction_id = transaction_id
		@payment_date = payment_date
		@expire_date = expire_date
		mail( :to => @user.email, :subject => 'Miniflix invoice receipt.' )
	end

	def invite_free_member(free_member)
    user = free_member
    subject = "Create free account in miniflix."
    merge_vars = {
      "USER_EMAIL" => user.email
    }
    body = mandrill_template("Send-invitation-mail", merge_vars)

    send_mail(user.email, subject, body)
  end

	private

		def send_mail(email, subject, body)
	    mail(to: email, subject: subject, body: body, content_type: "text/html")
	  end

	  def mandrill_template(template_name, attributes)
	    mandrill = Mandrill::API.new('M5xmtcfWhC4rjTjQsjrAmg')

	    merge_vars = attributes.map do |key, value|
	      { name: key, content: value }
	    end

	    mandrill.templates.render(template_name, [], merge_vars)["html"]
	  end
end