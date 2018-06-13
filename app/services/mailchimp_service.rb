class MailchimpService

  # CONSTANTS
  SUBSCRIBED = 'subscribed'.freeze

  def initialize(user)
    @user = user
  end

  def subscribe_user_to_list
    begin
      gibbon = Gibbon::Request.new
      body = user_details_hash(@user)
      list_ids = mailchimp_list_ids_arr
      list_ids.each do |list_id|
        gibbon.lists(list_id).members.create(body: body)
      end

      response = { success: true }
      Rails.logger.debug "<<<<< subscribe_user_to_list <<< success for user_id : #{@user.id} <<<<<"
      puts "<<<<< subscribe_user_to_list <<< success for user_id : #{@user.id} <<<<<"
    rescue Gibbon::MailChimpError => e
      response = { success: false,
                   message: e.message }
      Rails.logger.debug "<<<<< subscribe_user_to_list <<< Gibbon::MailChimpError: #{e.message} - #{e.raw_body} <<<<<"
      puts "<<<<< subscribe_user_to_list <<< Gibbon::MailChimpError: #{e.message} - #{e.raw_body} <<<<<"
    end

    response
  end

  private

  def mailchimp_list_ids_arr
    MailchimpGroup.available_list_ids_arr
  end

  def user_details_hash(user)
    { email_address: user.email,
      status: SUBSCRIBED,
      merge_fields: { FNAME: user.name, LNAME: '' }
    }
  end
end
