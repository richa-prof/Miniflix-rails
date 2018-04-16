class Admin::ContactUserRepliesController < ApplicationController

  def create
    contact_user_reply = ContactUserReply.new(contact_user_reply_params)

    respond_to do |format|
      if contact_user_reply.save
        visitor = ContactUs.find(contact_user_reply.contact_us_id)
        UserNotifier.send_reply_mail_to_visitor(visitor, contact_user_reply.message).deliver

        format.html { redirect_to admin_visitors_path,
                      notice: I18n.t('flash.visitor.send_reply_successfully') }
      else
        format.html { render :visitors,
                      notice: contact_user_reply.errors.full_messages[0] }
      end
    end
  end

  private

  def contact_user_reply_params
    params.require(:contact_user_reply).permit(:contact_us_id, :message)
  end
end
