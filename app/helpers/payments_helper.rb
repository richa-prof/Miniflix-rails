module PaymentsHelper

  def check_button_caption
    (params[:action] == "android_payment_update_view") ? "Update" : "Upgrade"
  end

  def price_rate_of_plan(plan_type)
    (plan_type == "Monthly") ? "$3.99 per month" : "$24 per year"
  end
end
