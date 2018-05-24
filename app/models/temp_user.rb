class TempUser < ApplicationRecord

  def self.save_user_detail_into_temp_user(user, social_authenticate=nil)
    # user_hash = user.as_json(only: [:name, :email, :registration_plan])
    # temp_user = self.create(user_hash.merge(password: user.password))
    # temp_user.id
    temp_user = (social_authenticate.present?) ? eval("find_or_initialize_by(provider: user.provider.try(:downcase), uid: user.uid)") : eval("find_or_initialize_by(email: user.email)")
    temp_user.name = user.name
    temp_user.registration_plan = user.registration_plan
    temp_user.password = user.password
    temp_user.sign_up_from = user.sign_up_from
    temp_user.email = user.email
    temp_user.save
    temp_user.id
  end

  def self.fetch_temp_user_id(description)
    description[/\d+/].to_i
  end

  def self.omniauth(auth)
    find_or_initialize_by(provider: auth.provider.try(:downcase), uid: auth.uid) do |temp_user|
    puts "auth.info==== #{auth.info}"
    temp_user.name = auth.info.name
    temp_user.email = auth.info.email
    temp_user.image = auth.info.image
    temp_user.token = auth.credentials.token
    temp_user.password = '123'
    temp_user.sign_up_from = 'web'
    if temp_user.provider == 'facebook'
      temp_user.expires_at = Time.at(auth.credentials.expires_at)
    end
      temp_user.save!
    end
  end

  def save_other_info(registration_plan, email=nil)
    self.registration_plan = registration_plan
    self.email = email if email.present?
    self.save
  end

  def self.json_content(id)
    (self.find id).as_json(except: [:created_at, :updated_at, :password, :auth_token]).reject{|k,v| v.nil?}
  end

  def update_auth_token
    token = Digest::SHA1.hexdigest([Time.now, rand].join)
    self.update_attribute('auth_token', token)
    token
  end
end
