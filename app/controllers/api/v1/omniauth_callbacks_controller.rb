class Api::V1::OmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController
  include Api::V1::Concerns::UserSerializeDataConcern

  def omniauth_success
    db_user = User.find_by_email(auth_hash['info']['email'])
    can_proceed = true

    if db_user.present?
      old_provider = db_user.provider
      new_provider = auth_hash['provider']
      can_proceed = old_provider == new_provider
    end

    if can_proceed
      super do
        response.headers['client'] = auth_hash[:client_id]
        response.headers['access-token'] =  @auth_params[:auth_token]
        response.headers['uid'] = @auth_params[:uid]
        response.headers['expiry'] =  @auth_params[:expiry]

        redirect_to react_redirect_url and return
      end
    else
      error_message = I18n.t('flash.omniauth.signup_fail', provider: old_provider)

      target_url = "#{ENV['Host']}/sign_in?success=false&&message=#{error_message}"

      redirect_to target_url and return
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
