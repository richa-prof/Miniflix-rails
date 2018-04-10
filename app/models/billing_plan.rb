class BillingPlan < ApplicationRecord

 enum interval:   {Year: "year", Month: "month"}
 validates_presence_of :description, :name, :amount, :currency, :interval

 def currency=(val)
   super(val.upcase)
 end
end
