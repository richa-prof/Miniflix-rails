class Api::V1::OmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController
  include Api::V1::Concerns::UserSerializeDataConcern
  def omniauth_success
    super do
      response.headers['client'] = @auth_params[:client_id]
      response.headers['access-token'] =  @auth_params[:auth_token]
      response.headers['uid'] = @auth_params[:uid]
      response.headers['expiry'] =  @auth_params[:expiry]
      redirect_to ENV['SocialReturn'] and return
    end
  end

   protected

   def assign_provider_attrs(user, auth_hash)
     attrs = auth_hash['info'].slice(*user.attributes.keys)
     attrs.merge!(social_login: true, sign_up_from: "web")
     user.assign_attributes(attrs)
   end

end
