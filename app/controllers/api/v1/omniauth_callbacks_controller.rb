class Api::V1::OmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController
  include Api::V1::Concerns::UserSerializeDataConcern
  def omniauth_success
    super do
      response.headers['client'] = @auth_params[:client_id]
      response.headers['access-token'] =  @auth_params[:auth_token]
      response.headers['uid'] = @auth_params[:uid]
      response.headers['expiry'] =  @auth_params[:expiry]

      redirect_to react_redirect_url and return
    end
  end

   protected

   def assign_provider_attrs(user, auth_hash)
     attrs = auth_hash['info'].slice(*user.attributes.keys)
     attrs.merge!(social_login: true, sign_up_from: "web")
     user.assign_attributes(attrs)
   end

  def react_redirect_url
    auth_token = current_user.create_new_auth_token

    if current_user.incomplete?
      action_name = t('payment.paypal.choose_plan')
      "#{ENV['Host']}/#{action_name}?client_id=#{auth_token['client']}&token=#{auth_token['access-token']}&uid=#{auth_token['uid']}&expiry=#{auth_token['expiry']}"
    else
      "#{ENV['SocialReturn']}/?client_id=#{auth_token['client']}&token=#{auth_token['access-token']}&uid=#{auth_token['uid']}&expiry=#{auth_token['expiry']}"
    end
  end
end
