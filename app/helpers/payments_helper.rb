module PaymentsHelper

  def check_button_caption
    button_caption = case params[:action]
    when "android_payment_view"
      "Subscribe"
    when "android_payment_old_user_view"
      "Upgrade"
    else
      "Update"
    end
    button_caption
  end

  def price_rate_of_plan(plan_type)
    (plan_type == "Monthly") ? "$3.99 per month" : "$24 per year"
  end
end
