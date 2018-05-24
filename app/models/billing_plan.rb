class BillingPlan < ApplicationRecord

  has_many :user_payment_methods
  has_many :users,  through: :user_payment_methods

 enum interval:   { year: 'Year',
                    month: 'Month' }
 validates_presence_of :description, :name, :amount, :currency, :interval

 before_create :create_stripe_plan

 def currency=(val)
   super(val.upcase)
 end

  private

  def create_stripe_plan
    Stripe::PlanCreate.new(self).call
    throw(:abort) if self.errors.any?
  end
end
