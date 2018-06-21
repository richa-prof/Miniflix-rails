namespace :update_user_video_last_stops do
  desc "update watched count of update user video last stops"
  task update_watched_count_of_update_user_video_last_stops: :environment do
    UserVideoLastStop.find_each do |object|
      if object.update_columns(watched_count: 1)
        Rails.logger.debug "<<<<<<<<< Successfully updated UserVideoLastStop: #{object.id} <<<<<<<<<"
        puts "<<<<<<<<< Successfully updated UserVideoLastStop: #{object.id} <<<<<<<<<"
      else
        error_messages = object.errors.full_messages
        Rails.logger.debug "<<<<<<<<< #{object.id} is still invalid. <<< errors:: #{error_messages} <<<<<<<<<"
        puts "<<<<<<<<< #{object.id} is still invalid. <<< errors:: #{error_messages} <<<<<<<<<"
      end
    end
  end
end

# RAILS_ENV=production bundle exec rake update_user_video_last_stops:update_watched_count_of_update_user_video_last_stops