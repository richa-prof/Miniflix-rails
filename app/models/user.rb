class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  #Association
  has_many :user_payment_methods, dependent: :destroy
  has_many :user_filmlists,  dependent: :destroy
  has_many :user_video_last_stops,  dependent: :destroy
  has_one :user_email_notification, dependent: :destroy
  has_one :logged_in_user, dependent: :destroy
  has_many :user_video_last_stops,as: :role, dependent: :destroy

  #constant
  OLDUSER = "Trial Completed"
  UPGRADE_SUBSCRIPTION = "upgrade plan for"
  UPDATE_SUBSCRIPTION = "subscription plan for update"

  #callback
  before_validation :valid_for_Education_plan, if: 'Educational?', on: :create
  before_create :build_email_notification
  before_create :set_free_user, if: '(Educational? && FreeMember.find_by_email(email))'
  after_create :welcome_mail_for_free_user, if: :is_free

  #Validation
  validates_presence_of :registration_plan, :sign_up_from, :name

  #enum
  enum registration_plan: {Educational: 'Educational', Monthly:'Monthly', Annually: 'Annually', Freemium: 'Freemium'}
  enum sign_up_from: {Web: 'web', Android: 'android', iOS: 'ios'}
  enum subscription_plan_status: {Activate: 'Activate', Cancelled: 'Cancelled', Expired: 'Expired'}

  def is_payment_verified?
    Educational?
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
end
