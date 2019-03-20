class Provider::DashboardController < ApplicationController
  #before_action :authenticate_admin_user!, only: [:index]  # FIXME!

  layout "provider"

  def index
    @unique_month_wise = User.select("created_at").map{ |item| item.created_at.beginning_of_month }.uniq
    @monthly_movies_cnt = Movie.group("created_day").select("count(*)as movies_cnt,DATE_FORMAT(admin_movies.created_at,'%m') as created_day,admin_movies.created_at")
    @total_income_of_current_month = UserPaymentTransaction.total_income_of_current_month
  end

end
