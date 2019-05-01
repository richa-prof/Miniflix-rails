module Provider::StatisticsHelper

  def get_total_movie_count
    Movie.count
  end

  def get_total_user_count
    User.user.count
  end

  def get_visitor_count
     ContactUs.count
  end

  def get_formatted_total_amount(amount)
    number_with_precision(amount, precision: 2)
  end

end
