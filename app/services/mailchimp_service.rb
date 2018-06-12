class MailchimpService

  # CONSTANTS
  SUBSCRIBED = 'subscribed'.freeze

  def initialize(user)
    @user = user
  end

  def subscribe_user_to_list
    begin
      gibbon = Gibbon::Request.new
      list_id = list_id_to_subscribe_new_user
      body = user_details_hash(@user)

      gibbon.lists(list_id).members.create(body: body)

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

  def list_id_to_subscribe_new_user
    # TODO: Need to implement dynamic list ids feature on admin side and return the ids here.
  end

  def user_details_hash(user)
    { email_address: user.email,
      status: SUBSCRIBED,
      merge_fields: { FNAME: user.name, LNAME: '' }
    }
  end
end
