class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true, with: :exception,  unless: :api_request?
  layout :determine_layout

  def api_request?
    request.url.include?('api')
  end

  def determine_layout
    controller_path.include?('admin/') ? 'admin' : 'application'
  end

  protected

  def after_sign_in_path_for(resource)
    Rails.logger.debug "after_sign_in_path_for, resource: #{resource}"
    sign_in(:user, resource) unless current_user
    return provider_dashboard_path if resource.provider?
    return admin_dashboard_path if resource.admin?
    return marketing_staff_genres_path if resource.marketing_staff?
    return root_path if resource.staff?
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    return new_marketing_staff_user_session_path if resource_or_scope == :marketing_staff_user
    return new_provider_user_session_path if resource_or_scope == :provider_user
    resource_or_scope == :admin_user ? new_admin_user_session_path : root_path
  end
end
