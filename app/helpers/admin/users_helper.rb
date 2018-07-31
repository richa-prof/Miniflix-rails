module Admin::UsersHelper

  def formatted_total_paid_amount(amount)
    "$#{number_with_precision(amount, precision: 3)}"
  end
end
