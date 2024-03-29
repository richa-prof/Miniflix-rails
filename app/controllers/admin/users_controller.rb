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

  def premium_users
    @users = User.premium_users
  end

  def get_user_payment_details
    user = User.find(params[:id])

    transactions = user.my_transactions

    transactions_list = transactions.as_json(root: false, only: :amount, methods: [:payer_first_name, :payer_last_name, :payment_type, :service_period])

    render :json => transactions_list
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

  def destroy
    User.friendly.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to admin_users_path,
                    notice: I18n.t('flash.user.successfully_deleted') }
      format.json { head :no_content }
    end
  end
end
