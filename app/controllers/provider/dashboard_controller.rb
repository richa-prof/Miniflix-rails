class Provider::DashboardController < ApplicationController
  #before_action :authenticate_admin_user!, only: [:index]  # FIXME!
  before_action :authenticate_user!, only: [:index]

  layout "provider"

  def index
    #@unique_month_wise = User.select("created_at").map{ |item| item.created_at.beginning_of_month }.uniq # FIXME!
    own_videos = current_user.own_movies.pluck(:id) + current_user.own_serials.map{|s| s.episodes.pluck(:id)}.flatten
    users_who_watched_videos = UserVideoLastStop.who_watched_videos(own_videos)
    @unique_month_wise = users_who_watched_videos.select("created_at").map{ |item| item.created_at.beginning_of_month }.uniq
    @monthly_movies_cnt = current_user.own_movies.group("created_at").select("count(*) as movies_cnt,DATE_FORMAT(admin_movies.created_at,'%m') as created_day,admin_movies.created_at")
    @total_income_of_current_month = UserPaymentTransaction.total_income_of_current_month_for_user(current_user)

    @m_months = []
    @monthly_movies_cnt.each do |main|
      m_month = [];
      m_month << main.created_at.strftime('%B')
      m_month << main.movies_cnt
      @m_months << m_month;
    end
    Rails.logger.debug @m_months
    Rails.logger.debug "current_user: #{current_user}"
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

end
