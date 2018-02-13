class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User

  attr_accessor :temp_user_id
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
  before_create :create_user_email_notification
  before_create :set_free_user, if: '((Educational? && FreeMember.find_by_email(email)) || Freemium?)'
  before_create :check_user_valid_for_free, if: 'Educational?'
  before_destroy :cancel_subscription_plan
  after_create :delete_temp_user, if: 'temp_user_id.present?'
  before_update :assign_subscription_cancel_date, if: 'Cancelled?'
  after_create :send_free_user_mail, if: 'is_free'
  after_create :send_signup_mail_for_paid_user, unless: 'is_free'

  #enum
  enum registration_plan: {Educational: 'Educational', Monthly:'Monthly', Annually: 'Annually', Freemium: 'Freemium'}
  enum sign_up_from: {Web: 'web', Android: 'android', iOS: 'ios'}
  enum subscription_plan_status: {Activate: 'Activate', Cancelled: 'Cancelled', Expired: 'Expired'}

end
