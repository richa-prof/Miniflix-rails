ActiveAdmin.register User do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
permit_params do
  [:name, :email, :role, :sign_up_from, :password, :password_confirmation]
end

 form do |f|
   f.semantic_errors
   f.inputs do
     f.input :name, label: 'Name*'
     f.input :email, label: 'Email*'
     f.input :role, prompt: 'Select User Role', as: :select, collection: User.roles.keys.map{|r| [r.titleize, r] }
     f.input :sign_up_from, value: User.sign_up_froms[:Web]
     unless f.object.persisted?
       f.input :password
       f.input :password_confirmation
     end
     f.actions
   end
 end

end
