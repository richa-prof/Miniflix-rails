class Provider::AnalyticsController < ApplicationController

  before_action :authenticate_provider_user!

  layout "provider"

  def index
    own_videos =   #current_user.own_movies.pluck(:id) + current_user.own_serials.map{|s| s.episodes.pluck(:id)}.flatten
      if params[:search]
        current_user.own_serials.where(
          "admin_serials.title like :search", search: "%#{params[:search]}%"
        ).map{|s| s.episodes.pluck(:id)}.flatten +  current_user.own_movies.where(
          "admin_movies.name like :search", search: "%#{params[:search]}%"
        ).pluck(:id)
      else
        current_user.own_movies.pluck(:id) + current_user.own_serials.map{|s| s.episodes.pluck(:id)}.flatten
      end
    Rails.logger.debug own_videos.inspect
    flash[:success] =
      if params[:search]
        flash[:success] = "Displaying statistics for #{own_videos.length} videos matched '#{params[:search]}' keyword"
      else
        flash[:success] = "Displaying statistics for #{own_videos.length} videos"
      end
    # FIXME - Couldn't find Admin::ContactUserRepliesHelper, expected it to be defined in helpers/admin/contact_user_replies_helper.rb
    users_who_watched_videos = UserVideoLastStop.who_watched_videos(own_videos)
    @unique_month_wise = users_who_watched_videos.select("created_at").map{ |item| item.created_at.beginning_of_month }.uniq
    # FIXME - wrong counter for current month!!!
    @monthly_movies_cnt = current_user.own_movies.group("created_at").select("count(*) as movies_cnt, DATE_FORMAT(admin_movies.created_at,'%m') as created_day, admin_movies.created_at")
    @total_income_of_current_month = UserPaymentTransaction.total_income_of_current_month_for_user(current_user)

    @m_months = []
    @monthly_movies_cnt.each do |main|
      m_month = [];
      m_month << main.created_at.strftime('%B')
      m_month << main.movies_cnt
      @m_months << m_month;
    end
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
