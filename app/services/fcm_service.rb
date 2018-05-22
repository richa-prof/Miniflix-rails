require 'fcm'

class FcmService

  def send_notification_to_android(device_tokens, options={})
    fcm = FCM.new(ENV['FCM_API_KEY'])

    fcm.send(device_tokens, options)
  end

  def send_notification_to_ios(ios_token, options={})
    notification_message = options[:message]

    begin
      iphone_notification = {
        aps: {
          alert: notification_message, sound: 'default', badge: 1,
          category: "SNOOZE_CATEGORY",
          data: options
        }
      }

      message = {
        default: notification_message,
        APNS_SANDBOX: iphone_notification.to_json,
        APNS: iphone_notification.to_json
      }

      platform_app_arn = ENV['IOS_ARN']
      sns = Aws::SNS::Client.new

      endpoint = sns.create_platform_endpoint(
        platform_application_arn: platform_app_arn,
        token:  ios_token,
        attributes: { 'Enabled' => "true" },
        custom_user_data: 'set reminder'
      )

      sns_endpoint_result = sns.get_endpoint_attributes(endpoint_arn: endpoint[:endpoint_arn] )
      puts " sns_endpoint_result  -- #{sns_endpoint_result.to_json} -- endpoint -->  #{endpoint.to_json}--token--#{ios_token} "

      token_matched = sns_endpoint_result[:attributes][:Token] == ios_token
      is_enabled_attr_false = sns_endpoint_result[:attributes][:Enabled] == "false"

      if !token_matched || is_enabled_attr_false
        set_attrs_endpoint_result = sns.set_endpoint_attributes(
                              endpoint_arn: endpoint[:endpoint_arn],
                              attributes:  { 'Token' => ios_token, 'Enabled' => "true"}
                            )
      end

      result = sns.publish( target_arn: endpoint[:endpoint_arn],
                            message: message.to_json,
                            message_structure: 'json' )

      puts "get -- result -->  #{result.to_json} "

      v = sns.delete_endpoint(endpoint_arn: endpoint.endpoint_arn)

    rescue Aws::SNS::Errors::ServiceError => e
      puts "------ Error -----> #{e}"
    end
  end
end
