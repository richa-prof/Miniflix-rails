class VerificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'high', failure: true

  def perform(options={})
    puts "#{options['type']}"
    case options['type']
    when "delete_verification_code"
      user = User.find (options['user_id'])
      user.update_columns(verification_code: nil, unconfirmed_phone_number: nil) if user.verification_code.present?
    end
  end
end
