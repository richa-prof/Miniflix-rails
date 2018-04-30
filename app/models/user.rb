class User < ActiveRecord::Base
  attr_accessor :skip_callbacks

  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  include DeviseTokenAuth::Concerns::User

  attr_accessor :social_login, :paypal_token, :payment_type

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
  OLDUSER = "Trial Completed"
  UPGRADE_SUBSCRIPTION = "upgrade plan for"
  UPDATE_SUBSCRIPTION = "subscription plan for update"
  ADMIN_EMAIL = 'admin@admin.com'

  # CALLBACKS
  after_initialize :set_default_subscription_plan, if: -> { new_record?}
  before_validation :valid_for_Education_plan, if: 'Educational?', on: :create
  before_create :build_email_notification
  before_create :set_free_user_and_subscription_staus, if: -> { condition_for_free_user}
  after_create :welcome_mail_for_free_user, if: :is_free
  after_validation :send_verification_code, if: ->  { unconfirmed_phone_number_changed? && errors.blank? }
  before_update :assign_unverified_phone_to_phone_number, if: -> { check_condition_for_assign_phone_number }
  before_update :make_migrate_user_false, if: -> { can_make_migrate_user_false? }
  before_save :set_job_for_annual_user_to_change_subscription_status, if: -> {user_choose_annual_plan?}

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
               user: 'User' }
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
  # SCOPE ENDS


  # ===== Class methods Start =====
  class << self
    def send_reset_password_reminder
      with_migrate_user.each do |user|
        if user.phone_number.present?
          user.send_reset_password_reminder_sms
        end

        if user.email? && user.Web?
          user.send_reset_password_reminder_email
        elsif user.iOS? || user.Android?
          user.send_reset_password_reminder_push_notification
        end
      end
    end
  end
  # ===== Class methods End =====

  def skip_registration_plan_validation
    social_login || staff?
  end

  def skip_sign_up_from_validation
    staff?
  end

  def is_payment_verified?
    Educational? || trial? || activate?
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

    if Android?
      fcm_service.send_notification_to_android(logged_in_user_device_tokens, options)
    elsif iOS?
      ios_token = logged_in_user_device_tokens.last
      fcm_service.send_notification_to_ios(ios_token, options[:data])
    end
  end

  def send_welcome_mail
    UserMailer.staff_member_signup_email(self).deliver
  end

  def checkout_url
    response = PaypalSubscription.new(:checkout, self).call
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
    assign_token_and_customer_id(token,payer_id)
    response = PaypalSubscription.new(:create_recurring_profile, self).call
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
    else
      response = Stripe::UpdateCard.new(self, token).call
    end
    response
  end

  def upgrade_payment_through_card
    Stripe::SubscriptionUpgrade.new(self).call
  end

  private

  def valid_for_Education_plan
    if (FreeMember.find_by_email(email)).nil?
      errors.add(:email, "Email not added as free email by admin. Contact to miniflix for free signup!")
    end
  end

  def set_free_user_and_subscription_staus
    self.subscription_plan_status = User.subscription_plan_statuses['trial']
    self.is_free = true
  end

  def build_email_notification
    build_user_email_notification(product_updates: true,films_added: true,special_offers_and_promotions: true,better_product: true,do_not_send: true)
  end

  def welcome_mail_for_free_user
    UserMailer.free_user_signup_email(self).deliver
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

  def fetch_billing_plan
    billing_plans_interval = ((self.Monthly?) ? "month" : "year")
    eval("BillingPlan.#{billing_plans_interval}").last
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
    self.valid_for_thankyou_page = true
    self.subscription_id = agreement_id
    self.subscription_plan_status = User.subscription_plan_statuses['trial']
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
    cancel_previous_subscription
    assign_registration_plan_and_build_payment_method if upgrade_payment
    self.subscription_id = agreement_id
    self.save
  end

  def assign_registration_plan_and_build_payment_method
    self.subscription_plan_status = User.subscription_plan_statuses['trial']
    self.registration_plan = User.registration_plans['Annually']
    self.build_user_payment_method(UserPaymentMethod.payment_types['paypal'])
  end

  def cancel_previous_subscription
    if latest_payment_method.paypal?
      cancel_previous_paypal_subscription(self.subscription_id)
    else
      # Cancel stripe subscription
      # here we are actually doing `canel` the subscription  not `suspend`.
      cancel_previous_stripe_subscription(self.subscription_id)
    end
  end

  def cancel_previous_paypal_subscription(subscription_id)
    ppr = PayPal::Recurring.new(profile_id: subscription_id)
    ppr.cancel
  end

  def cancel_previous_stripe_subscription(subscription_id)
    begin
      subscription = Stripe::Subscription.retrieve(subscription_id)
      if subscription.status != "canceled"
        subscription.delete
        puts 'subscription canceled!'
      else
        puts 'Subscription already canceled.'
      end
    rescue Exception => e
      puts "====== response stripe error : #{e.message} ======"
    end
  end

  def user_choose_annual_plan?
    self.registration_plan_changed? && self.Annually? && self.trial?
  end

end
