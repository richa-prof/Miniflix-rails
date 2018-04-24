class Stripe::PlanCreate
  def initialize(billing_plan)
    @billing_plan = billing_plan
  end

  def call
    create_plan_on_stripe( @billing_plan )
  end

  private

    def create_plan_on_stripe(billing_plan)
      stripe_plan =  Stripe::Plan.create( plan_create_attribute(billing_plan))
      billing_plan.stripe_plan_id = stripe_plan.id
    rescue Stripe::InvalidRequestError => e
        billing_plan.errors.add(:stripe, stripe_error(e))
    end

    def plan_create_attribute(billing_plan)
      {
        name: billing_plan.name,
        id: generate_stripe_id,
        interval: billing_plan.interval.downcase,
        currency: billing_plan.currency.downcase,
        amount: stripe_amount(billing_plan.amount),
        trial_period_days: billing_plan.trial_days
      }
    end

    def generate_stripe_id
      "stripe-#{SecureRandom.hex(5)}"
    end

    def stripe_amount(amount)
      (amount * 100).to_i
    end

    def stripe_error(exception)
      exception.json_body[:error][:message]
    end
end
