require "#{Rails.root}/lib/paypal_service"
class User < ActiveRecord::Base

  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  include DeviseTokenAuth::Concerns::User

  attr_accessor :skip_callbacks, :social_login, :paypal_token, :payment_type

  mount_uploader :image, ImageUploader

  # Ref.: https://github.com/norman/friendly_id
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Note: These are the reserved_words from FriendlyId.
  # config.reserved_words = %w(new edit index session login logout users admin stylesheets assets javascripts images)

  # ASSOCIATION STARTS
  has_many :user_payment_methods, dependent: :destroy
  has_many :user_filmlists,  dependent: :destroy
  has_many :my_list_movies,  through: :user_filmlists, source: "movie"
  has_many :user_video_last_stops,  dependent: :destroy
  has_one :user_email_notification, dependent: :destroy
  has_one :logged_in_user, dependent: :destroy
  has_many :user_video_last_stops, as: :role, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :blogs, dependent: :destroy
  has_one :address, dependent: :destroy
  has_one :social_media_link, dependent: :destroy
  has_many :my_transactions, through: :user_payment_methods, source: "user_payment_transactions"
  # ASSOCIATION ENDS

  accepts_nested_attributes_for :address, :social_media_link

  # CONSTANTS
  FREEMIUM = 'Android'
  OLDUSER = "Trial Completed"
  UPGRADE_SUBSCRIPTION = "upgrade plan for"
  UPDATE_SUBSCRIPTION = "subscription plan for update"
  ADMIN_EMAIL = 'admin@admin.com'
  PAYMENT_TYPE_PAYPAL = 'paypal'
  PLATFORMS = {
    web: 'web',
    android: 'android'
  }

  # CALLBACKS
  after_initialize :set_default_subscription_plan, if: :new_record?
  before_validation :valid_for_Education_plan, if: -> { Educational? }, on: :create
  before_create :build_email_notification
  before_create :set_free_user_and_subscription_staus, if: :condition_for_free_user
  after_create :welcome_mail_for_free_user, if: :is_free
  after_create :subscribe_user_to_mailchimp_list, if: -> { MailchimpGroup.is_list_ids_available? }
  after_validation :send_verification_code, if: ->  { unconfirmed_phone_number_changed? && errors.blank? }
  before_update :assign_unverified_phone_to_phone_number, if: :check_condition_for_assign_phone_number
  before_update :make_migrate_user_false, if: :can_make_migrate_user_false?
  before_update :assign_subscription_cancel_date, if: :cancelled?
  before_save :set_job_for_annual_user_to_change_subscription_status, if: :user_choose_annual_plan?

  before_validation do
    self.uid = email if uid.blank?
    self.provider = User.providers['email'] if provider.blank?
  end

  #change phone number in nomalize form before validate
  phony_normalize :phone_number, :unconfirmed_phone_number

  # VALIDATIONS
  validates_presence_of :name
  validates_plausible_phone :phone_number,:unconfirmed_phone_number
  validates_presence_of :registration_plan, unless: -> { skip_registration_plan_validation }
  validates_presence_of :sign_up_from, unless: -> { skip_sign_up_from_validation }

  # ENUM STARTS
  enum registration_plan: { Educational: 'Educational',
                            Monthly:'Monthly',
                            Annually: 'Annually',
                            Freemium: 'Freemium' }
  enum sign_up_from: { by_admin: 'by_admin',
                       Web: 'web',
                       Android: 'android',
                       iOS: 'ios' }
  enum provider: {  email: 'email',
                    facebook: 'facebook',
                    twitter: 'twitter' }
  enum role: { admin: 'Admin',
               staff: 'Staff',
               user: 'User',
               marketing_staff: 'marketing_staff' }
  enum subscription_plan_status: { incomplete: 'Incomplete',
                                   trial: 'Trial',
                                   activate: 'Activate',
                                   cancelled: 'Cancelled',
                                   expired: 'Expired' }
  # ENUM ENDS

  # SCOPE STARTS
  scope :with_migrate_user, -> { where(migrate_user: true) }
  scope :without_admin, -> { where.not(email: ADMIN_EMAIL)  }
  scope :without_educational_plan, -> { where.not(registration_plan: 'Educational')  }
  scope :premium_users, -> { without_admin.without_educational_plan }
  scope :paid_users, -> {where(registration_plan: ['Monthly','Annually'])}
  scope :find_by_month_and_year, ->(month_year){where('extract(month from created_at) = ? and extract(year from created_at) = ? ', month_year.first, month_year.last)}
  # SCOPE ENDS

  # ===== Class methods Start =====
  class << self
    def marketing_staff_member_signin_url
      "#{ENV['RAILS_ADMIN_HOST']}/marketing_staff/users/sign_in"
    end
  end
  # ===== Class methods End =====

  def total_amount_paid
    my_transactions.sum(:amount)
  end

  def subscribe_user_to_mailchimp_list
    mailchimp_service_obj = MailchimpService.new(self)

    mailchimp_service_obj.subscribe_user_to_list
  end

  def skip_registration_plan_validation
    social_login || staff? || marketing_staff? || is_social_login?
  end

  def is_social_login?
    facebook? || twitter?
  end

  def skip_sign_up_from_validation
    staff? || marketing_staff?
  end

  def is_payment_verified?
    Educational? || trial? || activate?
  end

  def assign_subscription_cancel_date
    self.cancelation_date = Time.now
  end

  def find_or_initialize_filmlist(movie_id)
    self.user_filmlists.find_or_initialize_by(admin_movie_id: movie_id)
  end

  def valid_verification_code?(verification_code)
    self.verification_code == verification_code
  end

  def send_reset_password_reminder_sms
    message = notification_message_to_reset_password
    TwilioService.new(phone_number, message).call()
  end

  def send_reset_password_reminder_email
    UserMailer.reset_password_reminder_email(self).deliver
  end

  def send_reset_password_reminder_push_notification
    options = { data: { message: notification_message_to_reset_password } }
    if current_mobile_logged_in_user
      device_type = current_mobile_logged_in_user.device_type
      case device_type
      when LoggedInUser::DEVICE_TYPE_ANDROID
        fcm_service.send_notification_to_android(logged_in_user_device_tokens, options)
      when LoggedInUser::DEVICE_TYPE_IOS
        ios_token = logged_in_user_device_tokens.last
        fcm_service.send_notification_to_ios(ios_token, options[:data])
      end
    end
  end

  def current_mobile_logged_in_user
    if logged_in_user && logged_in_user.device_type.present? && logged_in_user.device_token.present?
      logged_in_user
    end
  end

  def send_welcome_mail
    if staff?
      UserMailer.staff_member_signup_email(self).deliver
    elsif marketing_staff?
      UserMailer.marketing_staff_member_signup_email(self).deliver
    end
  end

  def checkout_url(platform=nil)
    response = PaypalSubscription.new(:checkout, self, platform).call
    if response
      self.save
    end

    response.checkout_url
  end

  def update_checkout_url
    response = PaypalUpdateSubscription.new(:checkout, self).call
    response.checkout_url
  end

  def upgrade_checkout_url
    response = PaypalUpgradeSubscription.new(:checkout, self).call
    response.checkout_url
  end

  def confirm_payment(token, payer_id)
    assign_token_and_customer_id(token, payer_id)
    response = PaypalSubscription.new(:create_recurring_profile, self).call

    Rails.logger.debug "<<<<< confirm_payment::response : #{response} <<<<<"
    return response unless response

    self.build_user_payment_method(UserPaymentMethod.payment_types['paypal'])
    payment_cofirmation_setting(response.profile_id)
  end

  def confirm_for_update_payment(token, payer_id)
    assign_token_and_customer_id(token,payer_id)
    response = PaypalUpdateSubscription.new(:create_recurring_profile, self).call
    return response unless response
    update_or_upgrade_payment_confirmation(response.profile_id)
  end

  def confirm_for_upgrade_payment(token, payer_id)
    assign_token_and_customer_id(token,payer_id)
    response = PaypalUpgradeSubscription.new(:create_recurring_profile, self).call
    return response unless response
    update_or_upgrade_payment_confirmation(response.profile_id, true)
  end

  def latest_payment_method
    self.user_payment_methods.active.last
  end

  def build_user_payment_method(payment_type)
    self.user_payment_methods.build(payment_method_attribute(payment_type))
  end

  def update_card_payment(token)
    if latest_payment_method.paypal?
      paypal_subscription_id = self.subscription_id
      response = Stripe::SubscriptionUpdate.new(self, token).call
      cancel_previous_paypal_subscription(paypal_subscription_id) if response[:success]
    elsif latest_payment_method.card?
      response = Stripe::UpdateCard.new(self, token).call
    else
      response = Stripe::SubscriptionUpdate.new(self, token).call
    end

    response
  end

  def upgrade_payment_through_card
    Stripe::SubscriptionUpgrade.new(self).call
  end

  def suspend_subscription
    if latest_payment_method.paypal?
      ppr_response = suspend_paypal_subscription(subscription_id)
      if ppr_response.valid?
        self.cancelled!

        response = { success: true,
                     message: (I18n.t 'suspend_subscription.success') }
      else
        response = { success: false,
                     message: ppr_response.errors[0][:messages][0] }
      end
    elsif latest_payment_method.card?
      stripe_service_obj = StripeService.new(subscription_id)
      response = stripe_service_obj.suspend_subscription
      self.cancelled! if response[:success]
    else
      response = { success: false,
                   message: (I18n.t 'suspend_subscription.error') }
    end

    response
  end

  def reactivate_subscription
    if latest_payment_method.paypal?
      ppr_response = reactivate_paypal_subscription(subscription_id)

      if ppr_response.valid?
        ppr = PayPal::Recurring.new(profile_id: ppr_response.profile_id)

        case ppr.profile.try(:status)
        when 'active'
          self.activate!
        when 'suspended'
          self.cancelled!
        when 'canceled'
          self.expired!
        else
          self.activate!
        end

        response = { success: true,
                     message: (I18n.t 'reactivate_subscription.success') }
      else
        response = { success: false,
                     message: ppr_response.errors[0][:messages][0] }
      end

    elsif latest_payment_method.card?
      stripe_service_obj = StripeService.new(subscription_id)

      response = stripe_service_obj.reactivate_subscription
      if response[:success]
        subscription = response[:subscription]

        case subscription.status
        when 'trialing'
          self.trial!
        when 'active'
          self.activate!
        when 'canceled'
          self.cancelled!
        when 'unpaid'
          self.expired!
        end
      end
    else
      response = { success: true,
                   message: (I18n.t 'reactivate_subscription.error') }
    end

    response
  end

  def next_charge_date
    latest_transaction  = self.my_transactions.last
    next_charge_date_time_obj = latest_transaction.try(:payment_expire_date)

    if !next_charge_date_time_obj && latest_payment_method.present?
      latest_payment_method_created_at = latest_payment_method.created_at

      next_charge_date_time_obj =
        if Monthly?
          latest_payment_method_created_at + 1.month
        elsif Annually?
          latest_payment_method_created_at + 1.year
        end
    end

    next_charge_date_time_obj
  end

  def fetch_stripe_card_number
    begin
      customer = Stripe::Customer.retrieve(customer_id)
      default_card_map = customer.sources.data.select{ |a| a.id == customer.default_source }
      card_number = default_card_map.last.try(:last4)

      { success: true, card_number: card_number }
    rescue Exception => e
      puts"<===response stripe error===#{e.message}=======>"

      { success: false }
    end
  end

  def fetch_billing_plan
    if self.Monthly? && self.battleship?
      battleship_trial_plan
    else
      billing_plans_interval = ((self.Monthly?) ? "month" : "year")
      monthly_plans = eval("BillingPlan.#{billing_plans_interval}")
      monthly_plans.where.not(stripe_plan_id: ENV['BATTLESHIP_TRIAL_PLAN_ID']).last
    end
  end

  def profile_image_url
    path = image.try(:staff_medium).try(:path)

    if path.present?
      return CommonHelpers.cloud_front_url(path)
    end

    image.default_url
  end

  # ======= Related to mobile API's start =======
  def update_auth_token
    token = Digest::SHA1.hexdigest([Time.now, rand].join)
    self.update_attribute('auth_token', token)
    token
  end

  def create_hash
    as_json(include: [{logged_in_user: {only: [:notification_from, :device_type, :device_token]}}, {user_email_notification: {except: [:id, :created_at, :updated_at, :user_id]}}])
  end

  def as_json(options={})
    user_hash = super(except: [:role,:created_at, :updated_at, :password_digest, :receipt_data, :auth_token, :image, :provider, :uid, :migrate_user, :slug, :allow_password_change, :valid_for_thankyou_page]).reject { |k, v| v.nil? }
    user_hash = user_hash.merge(super["logged_in_user"]) if super["logged_in_user"]
    user_hash = user_hash.merge(super["user_email_notification"]) if super["user_email_notification"]
    user_hash = user_hash.merge(isPaymentSettingsAllow: self.payment_setting_allow?,  is_validPlan: is_valid_payment? )

    if self.image.present?
      user_hash = user_hash.merge( image: self.image_url )
    end

    user_hash
  end

  def payment_setting_allow?
    self.Android? && self.user_payment_methods.present?
  end

  def valid_for_monthly_plan?
    self.Freemium?
  end

  def is_invalid_email?
    self.valid?
    self.errors[:email].present?
  end

  def check_login
    return check_user_free_or_not if check_user_free_or_not
    self.is_valid_payment?
  end

  def is_valid_payment?
    (trial? || activate?) && is_paid_user?
  end

  def is_paid_user?
    self.Monthly? || self.Annually?
  end

  def check_user_free_or_not
    self.Educational?
  end

  def create_or_update_logged_in_user(params)
    logged_in_user = LoggedInUser.find_or_initialize_by(user_id: self.id)
    logged_in_user.device_token =  params[:device_token]
    logged_in_user.device_type = params[:device_type]
    logged_in_user.notification_from = params[:notification_from]
    logged_in_user.save
  end

  def self.check_user_already_present_or_not(provider, uid )
    find_by_provider_and_uid(provider, uid)
  end

  def invalid_only?(field_name)
    ( self.errors.count == 1 && !self.valid?(field_name) )
  end

  def destroy_auth_token
    self.update_attribute('auth_token', nil)
  end

  def stripe_subscription_cancel(period_end_hash=nil)
    begin
      customer = Stripe::Customer.retrieve(customer_id)
      subscription = customer.subscriptions.retrieve(subscription_id)
      if subscription.status != "canceled"
        delete_subscription = subscription.delete(period_end_hash)
        puts "subscription canceled"
      else
        puts" Subscription already canceled."
      end
      true
    rescue Exception => e
       puts"<===response stripe error===#{e.message}=======>"
       errors.add(:stripe, e.message)
       false
    end
  end

  def cancel_paypal_subscription
    access_token = PaypalAccessToken.last.access_token
    token = "#{subscription_id}/suspend"
    request_data = JSON.dump({ note: "Suspending the agreement" })

    suspend_response = Paypal::BillingPlanRequest.paypal_request_send(ENV["PAYPAL_BILLING_AGREEMENTS_URL"], "post", access_token, request_data, token)
    if  suspend_response.code == "204"
      puts "paypal subscription successfully canceled"
      return true
    elsif suspend_response.code == "401"
      PaypalAccessToken.fetch_paypal_access_token
      cancel_paypal_subscription
    else
      suspend_response_json = JSON.load(suspend_response.body)
      if suspend_response_json.present? && suspend_response_json['name'] == "STATUS_INVALID"
        puts "Plan already canceled"
        return true
      else
        errors.add(:paypal, "Plan unable to suspend")
        return false
      end
    end
  end

  def reactive_payment_subscription
    if latest_payment_method.card?
      reactive_subscription_for_stripe
    else
      reactive_subscription_for_paypal
    end
  end

  def reactive_subscription_for_paypal
    access_token = PaypalAccessToken.last.access_token
    token = "#{subscription_id}/re-activate"
    request_data = JSON.dump({ note: "Reactive the agreement" })
    reactive_response = Paypal::BillingPlanRequest.paypal_request_send(ENV["PAYPAL_BILLING_AGREEMENTS_URL"], "post", access_token, request_data, token)
    if  reactive_response.code == "204"
      puts "paypal subscription successfully canceled"
      return true
    elsif reactive_response.code == "401"
      PaypalAccessToken.fetch_paypal_access_token
      reactive_subscription_for_paypal
    else
      reactive_response_json = JSON.load(reactive_response.body)
      if reactive_response_json.present? && reactive_response_json['name'] == "STATUS_INVALID"
        puts "Plan already activated"
        return true
      else
        errors.add(:paypal, "Plan unable to active")
        return false
      end
    end
  end

  def reactive_subscription_for_stripe
    begin
      customer = Stripe::Customer.retrieve(customer_id)
      subscription = customer.subscriptions.retrieve(subscription_id)
      item = subscription.items.data.last
      items = [{
        id: item.id,
        plan: item.plan.id,
      }]
      subscription.items = items
      subscription.save
      true
    rescue Stripe::InvalidRequestError => e
      puts "#{e.http_status}"
      body = e.json_body
      error = body[:error][:message]
      puts "#{error}"
      errors.add(:stripe, "#{error}" )
      false
    rescue => e
      false
    end
  end

  # ======= Related to mobile API's END =======

  private

  def valid_for_Education_plan
    if (FreeMember.find_by_email(email)).nil?
      errors.add(:email, 'not added as free email by admin. Contact to miniflix for free signup!')
    end
  end

  def set_free_user_and_subscription_staus
    self.subscription_plan_status = User.subscription_plan_statuses['trial']
    self.is_free = true
    self.valid_for_thankyou_page = true
  end

  def build_email_notification
    build_user_email_notification(product_updates: true,films_added: true,special_offers_and_promotions: true,better_product: true,do_not_send: true)
  end

  def welcome_mail_for_free_user
    if Rails.env.production?
      UserMailer.free_user_signup_email(self).deliver
    end
  end

  def send_verification_code
    self.verification_code =  rand(1 .. 99999)
    twillo_response = TwilioService.new(unconfirmed_phone_number, message_with_verification_code(verification_code)).call()
    errors.add(:unconfirmed_phone_number, twillo_response[:message]) unless twillo_response[:success]
    destroy_verification_code_after_2minutes if errors.blank?
    errors.blank?
  end

  def message_with_verification_code(verification_code)
    "you are requesting for updating phone number your verification code is #{verification_code}, this code is valid for 2 minute "
  end

  def check_condition_for_assign_phone_number
    verification_code_changed? && verification_code.nil? && unconfirmed_phone_number.present?
  end

  def assign_unverified_phone_to_phone_number
    self.phone_number = self.unconfirmed_phone_number
    self.unconfirmed_phone_number = nil
  end

  def destroy_verification_code_after_2minutes
    VerificationWorker.perform_in(2.minutes, type: "delete_verification_code", user_id: self.id)
  end

  def can_make_migrate_user_false?
    !skip_callbacks && encrypted_password_changed? && migrate_user
  end

  def make_migrate_user_false
    self.migrate_user = false
  end

  def fcm_service
    @fcm_service ||= FcmService.new
  end

  def logged_in_user_device_tokens
    LoggedInUser.where(user_id: self.id).pluck('device_token')
  end

  def notification_message_to_reset_password
    "Your temporary password is: #{self.temp_password} Please login and reset your password."
  end

  def set_job_for_annual_user_to_change_subscription_status
    SubscriptionStatusChangeJob.set(wait: 6.hours).perform_later(self.id)
  end

  def battleship_trial_plan
    BillingPlan.find_by_stripe_plan_id(ENV['BATTLESHIP_TRIAL_PLAN_ID'])
  end

  def payment_method_attribute(payment_type)
    {
      payment_type: payment_type,
      billing_plan: fetch_billing_plan
    }
  end

  def assign_token_and_customer_id(token, payer_id)
    self.paypal_token = token
    self.customer_id = payer_id
  end

  def payment_cofirmation_setting(agreement_id)
    Rails.logger.debug "<<<<< payment_cofirmation_setting::agreement_id : #{agreement_id} <<<<<"
    self.valid_for_thankyou_page = true
    self.subscription_id = agreement_id
    self.subscription_plan_status = User.subscription_plan_statuses['trial']

    Rails.logger.debug "<<<<< payment_cofirmation_setting::user : #{self.inspect} << is_valid:: #{self.valid?} << errors:: #{self.errors.full_messages} <<<<<"

    self.save
  end

  def condition_for_free_user
    (Educational? && FreeMember.find_by_email(email))
  end

  #set default values
  def set_default_subscription_plan
    self.subscription_plan_status = User.subscription_plan_statuses['incomplete']
  end

  def update_or_upgrade_payment_confirmation(agreement_id, upgrade_payment=nil)
    cancel_previous_subscription if latest_payment_method.present?
    assign_registration_plan_and_build_payment_method if upgrade_payment
    self.subscription_id = agreement_id
    self.build_user_payment_method(UserPaymentMethod.payment_types['paypal'])

    self.save
  end

  def assign_registration_plan_and_build_payment_method
    self.subscription_plan_status = User.subscription_plan_statuses['trial']
    self.registration_plan = User.registration_plans['Annually']
  end

  def cancel_previous_subscription
    if latest_payment_method.paypal?
      cancel_previous_paypal_subscription(self.subscription_id)
    else
      stripe_service_obj = StripeService.new(subscription_id)
      stripe_service_obj.cancel_subscription
    end
  end

  def cancel_previous_paypal_subscription(subscription_id)
    ppr = PayPal::Recurring.new(profile_id: subscription_id)
    ppr.cancel
  end

  def suspend_paypal_subscription(subscription_id)
    ppr = PayPal::Recurring.new(profile_id: subscription_id)
    ppr.suspend
  end

  def reactivate_paypal_subscription(subscription_id)
    ppr = PayPal::Recurring.new(profile_id: subscription_id)
    ppr.reactivate
  end

  def user_choose_annual_plan?
    self.registration_plan_changed? && self.Annually? && self.trial?
  end
end
