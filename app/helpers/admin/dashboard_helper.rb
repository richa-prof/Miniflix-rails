module Admin::DashboardHelper

  def get_total_movie_count
    Movie.count
  end

  def get_total_user_count
    User.where(role: "User").count
  end

  def get_visitor_count
     ContactUs.count
  end

  def total_income_of_current_month
    amount = UserPaymentTransaction.where('created_at >= ?', Time.now.beginning_of_month).where.not(transaction_id: nil).sum(:amount)
    number_with_precision(amount, precision: 2)
  end

end
