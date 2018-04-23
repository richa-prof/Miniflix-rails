class BillingPlan < ApplicationRecord

  has_many :user_payment_methods
  has_many :users,  through: :user_payment_methods

 enum interval:   {year: "Year", month: "Month"}
 validates_presence_of :description, :name, :amount, :currency, :interval

 def currency=(val)
   super(val.upcase)
 end
end
