class Admin::VisitorsController < ApplicationController

  def index
    @visitors = ContactUs.all
    @contact_user_reply = ContactUserReply.new
  end

  def destroy
    visitor = ContactUs.find(params[:id])
    visitor.destroy

    respond_to do |format|
      format.html { redirect_to admin_visitors_path,
                    notice: I18n.t('flash.visitor.successfully_deleted') }
      format.json { head :no_content }
    end
  end
end
