class Admin::UsersController < ApplicationController
  before_action :authenticate_admin_user!
  layout 'admin'

  def index
    # Returns all the users whose role is `User`.
    # For more info refer enum `role` in `app/models/user.rb`
    @users = User.user
  end

  def educational_users
    # Refer scope :registration_plan in `app/models/user.rb`
    @users = User.Educational
  end

  def monthly_users
    # Refer scope :registration_plan in `app/models/user.rb`
    @users = User.Monthly
  end

  def annually_users
    # Refer scope :registration_plan in `app/models/user.rb`
    @users = User.Annually
  end

  def freemium_users
    # Refer scope :registration_plan in `app/models/user.rb`
    @users = User.Freemium
  end

  def get_user_payment_details
    user = User.find(params[:id])

    user_payment_methods = user.user_payment_methods

    user_payment_list = user_payment_methods.map do |payment_method|
                          prepare_user_payment_method_map(payment_method)
                        end

    render :json => user_payment_list
  end

  def get_monthly_revenue
    selected_month_date = params[:id].split('-')
    colors = ['#98FB98', '#FA8072', '#00AAEE']
    response = []
    User.sign_up_froms.keys.each_with_index do |key, index|
    count = eval("User.#{key}.paid_users.find_by_month_and_year(selected_month_date).count")
    response << {label: "#{key} Users- #{count}", data: count, color: colors[index] }
    end
    render :json => response
  end

  def visitors
    @visitors = ContactUs.all
  end

  def send_reply
    @contact_user_reply = ContactUserReply.new(contact_u_id: params[:v_id],message: params[:v_reply])
    respond_to do |format|
      if @contact_user_reply.save
        @visitor = ContactUs.find(@contact_user_reply.contact_u_id)
        UserNotifier.send_reply_mail_to_visitor(@visitor,@contact_user_reply.message).deliver
        format.html { redirect_to admin_visitors_path, notice: 'Send reply successfully.' }
      else
        format.html { render :visitors }
      end
    end
  end

  def destroy_visitor
    @visitor = ContactUs.find(params[:id])
    @visitor.destroy
    respond_to do |format|
      format.html { redirect_to admin_visitors_path, notice: 'Visitor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def prepare_user_payment_method_map(object)
   object.as_json(root: false, only: [:first_name, :last_name, :payment_type, :card_number, :expiration_month, :expiration_year, :amount], methods: [:service_period])
  end
end
