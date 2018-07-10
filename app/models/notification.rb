class Notification < ApplicationRecord
  require 'fcm'

  belongs_to :movie, foreign_key: "admin_movie_id"
  belongs_to :user

  #Pagination per page
  PER_PAGE = 10
  self.per_page = PER_PAGE

  delegate :name, to: :movie, prefix: :movie,  allow_nil: true

  # ======= Related to mobile API's START =======

  # ===== Class methods START =====
  class << self

    def send_movie_added_push_notification(movie)
      notification_message = movie.new_movie_added_notification_message

      user_ids = UserEmailNotification.where(films_added: true).pluck("user_id")
      values = []
      User.ids.map {|user| values.push({message: notification_message, admin_movie_id: movie.id, user_id: user})}

      Notification.create([values])

      android_user_tokens = LoggedInUser.android_user_tokens(user_ids)

      fcm = FCM.new(ENV['FCM_API_KEY'])

      @data = { notifications_id: 0,
                message: notification_message,
                created_at: Time.now.to_s,
                movie_id: movie.id,
                name: movie.name,
                realesed: movie.created_at.to_s,
                image: movie.movie_thumbnail.thumbnail_screenshot.url.to_s}

      options = { notification:
                    { "title": movie.name,
                      "text": notification_message,
                      "icon": "ic_logo",
                      "color": "#e4087e",
                      "sound": "default"},
                  data: @data }

      response = fcm.send(android_user_tokens, options)
      puts "response-- #{response}"

      iOS_user_development_tokens = LoggedInUser.ios_user_development_tokens(user_ids)

      iOS_user_development_tokens.each do |ios_token|
        @data = { message: notification_message,
                  created_at: Time.now.to_s,
                  movie_id: movie.id,
                  name: movie.name,
                  realesed: movie.created_at.to_s }

        send_ios_development_user_notification(ios_token, notification_message)
      end
    end

    def test_notification(token,device)
      @adminMovie = Movie.first

      notification_message = movie.new_movie_added_notification_message

      data_image_url = CommonHelpers.cloud_front_url(@adminMovie.movie_thumbnail.try(:thumbnail_screenshot).try(:path))

      @data = { notifications_id: 0,message: notification_message,created_at: Time.now.to_s,movie_id: @adminMovie.id,name: @adminMovie.name,realesed: @adminMovie.created_at.to_s,image: data_image_url.try(:to_s) }

      if device == 'android'
        android_user_tokens = [].push(token)
        fcm = FCM.new(ENV['FCM_API_KEY'])
        options = {notification: {"title": @adminMovie.name,"text": notification_message,"icon": "ic_logo","color": "#e4087e","sound": "default"},data: @data}
        response = fcm.send(android_user_tokens,options)
        puts "response-- #{response}"
      elsif device == 'iOS'
        @data = { message: notification_message,created_at: Time.now.to_s,movie_id: @adminMovie.id,name: @adminMovie.name,realesed: @adminMovie.created_at.to_s}
        send_ios_development_user_notification(token, notification_message)
      end
    end

    def send_ios_development_user_notification(ios_token, notification_message)
      begin
        iphone_notification = {
          aps: {
            alert: notification_message, sound: 'default', badge: 1,
            category: "SNOOZE_CATEGORY",
            data: @data
          }
        }
        message = {
          default: notification_message,
          APNS_SANDBOX: iphone_notification.to_json,
          APNS: iphone_notification.to_json
        }

        @platform_app_arn = ENV['IOS_ARN']
        sns = Aws::SNS::Client.new
        endpoint = sns.create_platform_endpoint(
          platform_application_arn: @platform_app_arn,
          token:  ios_token,
          attributes: { 'Enabled' => "true" },
          custom_user_data: 'set reminder'
        )
        @getEndpointResult = sns.get_endpoint_attributes(endpoint_arn: endpoint[:endpoint_arn] )
        puts " getEndpointResult  -- #{@getEndpointResult.to_json} -- endpoint -->  #{endpoint.to_json}--token--#{ios_token} "
        if @getEndpointResult[:attributes][:Token] != ios_token || @getEndpointResult[:attributes][:Enabled] == "false"
          @setEndpointResult = sns.set_endpoint_attributes(
            endpoint_arn: endpoint[:endpoint_arn],
            attributes:  { 'Token' => ios_token,'Enabled' => "true"}
          )
        end
        @result = sns.publish(target_arn: endpoint[:endpoint_arn], message: message.to_json,message_structure: "json")
        puts "get -- result -->  #{@result.to_json} "
        v = sns.delete_endpoint(endpoint_arn: endpoint.endpoint_arn);

      rescue Aws::SNS::Errors::ServiceError => e
        puts "------ Error -----> #{e}"
      end
    end
  end
  # ===== Class methods END =====

  def as_json
    super(except: [:updated_at,:admin_movie_id, :user_id]).merge(movie_detail)
  end

  def movie_detail
    movie.movie_details_hash_for_notification
  end

  # ======= Related to mobile API's END =======
end
