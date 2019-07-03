class Admin::DashboardController < ApplicationController
  # before_action :authenticate_admin_user!, only: [:index]

  layout "admin"
  def index
    if current_marketing_staff_user
      redirect_to admin_marketing_staffs_path and return
    elsif current_admin_user
      # Allow admin user to go ahead.
    else
      authenticate_admin_user!
    end

    @unique_month_wise = User.select("created_at").map{ |item| item.created_at.beginning_of_month }.uniq
    @monthly_movies_cnt = Movie.group("created_at").select("count(*) as movies_cnt,DATE_FORMAT(admin_movies.created_at,'%m') as created_day,admin_movies.created_at")
    @total_income_of_current_month = UserPaymentTransaction.total_income_of_current_month
  end

  def login
    @user = User.new
    render layout: "admin_login"
  end

  def sign_in
    found_user = User.where("email = ? OR name = ?", params[:email], params[:email]).first
    if found_user
      authorized_user = found_user.authenticate(params[:password])
    end
    if authorized_user
      if authorized_user.admin?
        session[:user_id] = authorized_user.id
        session[:user_name] = authorized_user.name
        session[:user_role] = authorized_user.role
        redirect_to admin_dashboard_path
      else
        flash[:error] = "Invalid email/password combination."
        redirect_to(:action => 'login')
      end
    else
      flash[:error] = "Invalid email/password combination."
      redirect_to(:action => 'login')
    end
  end
end
