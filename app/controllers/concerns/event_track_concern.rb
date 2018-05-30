module EventTrackConcern
  extend ActiveSupport::Concern

  def facebook_pixel_event_track(event_type, event_parameter=nil)
    Rails.logger.debug "<<<<< facebook_pixel_event_track::event_type : #{event_type} << event_parameter:: #{event_parameter} <<<<<"

    tracker do |t|
      t.facebook_pixel :track_custom, { type: event_type, options: event_parameter  }
    end
  end

  def user_trackable_detail
    user_hash = {
      user_name: @user.name,
      email: @user.email,
      registration_plan: @user.registration_plan
    }
    user_hash.merge!(payment_type: fetch_payment_type) if !@user.Educational?
    Rails.logger.debug "<<<<< user_trackable_detail::user_hash : #{user_hash} <<<<<"

    user_hash
  end

  def fetch_payment_type
    user_payment_method = @user.user_payment_methods.last
    (user_payment_method.present?) ? user_payment_method.payment_type : "NA"
  end

end