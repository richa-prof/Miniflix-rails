class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  #Association
  has_many :user_payment_methods, dependent: :destroy
  has_many :user_filmlists,  dependent: :destroy
  has_many :my_list_movies,  through: :user_filmlists, source: "movie"
  has_many :user_video_last_stops,  dependent: :destroy
  has_one :user_email_notification, dependent: :destroy
  has_one :logged_in_user, dependent: :destroy
  has_many :user_video_last_stops, as: :role, dependent: :destroy
  has_many :notifications, dependent: :destroy

  #constant
  OLDUSER = "Trial Completed"
  UPGRADE_SUBSCRIPTION = "upgrade plan for"
  UPDATE_SUBSCRIPTION = "subscription plan for update"

  #callback
  before_validation :valid_for_Education_plan, if: 'Educational?', on: :create
  before_create :build_email_notification
  before_create :set_free_user, if: '(Educational? && FreeMember.find_by_email(email))'
  after_create :welcome_mail_for_free_user, if: :is_free
  after_validation :send_verification_code, if: ->  {unconfirmed_phone_number_changed? && errors.blank? }
  before_update :assign_unverified_phone_to_phone_number, if: -> { check_condition_for_assign_phone_number}

  #change phone number in nomalize form before validate
  phony_normalize :phone_number, :unconfirmed_phone_number

  #Validation
  validates_presence_of :registration_plan, :sign_up_from, :name
  validates_plausible_phone :phone_number,:unconfirmed_phone_number

  #enum
  enum registration_plan: {Educational: 'Educational', Monthly:'Monthly', Annually: 'Annually', Freemium: 'Freemium'}
  enum sign_up_from: {Web: 'web', Android: 'android', iOS: 'ios'}
  enum subscription_plan_status: {Activate: 'Activate', Cancelled: 'Cancelled', Expired: 'Expired'}

  def is_payment_verified?
    Educational?
  end

  def find_or_initialize_filmlist(movie_id)
    self.user_filmlists.find_or_initialize_by(admin_movie_id: movie_id)
  end

  def valid_verification_code?(verification_code)
    self.verification_code == verification_code
  end

  private

  def valid_for_Education_plan
    if (FreeMember.find_by_email(email)).nil?
      errors.add(:email, "Email not added as free email by admin. Contact to miniflix for free signup!")
    end
  end

  def set_free_user
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

end
