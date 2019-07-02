module ApplicationHelper

  STATIC_PAGES_URLS_MAP = {
      'about_us' => "#{ENV['Host']}/about_us",
      'help_center' => "#{ENV['Host']}/help_center",
      'term_of_services' => "#{ENV['Host']}/term_of_services",
      'privacy_policy' => "#{ENV['Host']}/privacy_policy"
    }.freeze

  def errors_for(form, field)
    content_tag(:span, form.object.errors[field].join(', '), class: 'blg-advice text-danger') unless form.object.errors[field].blank?
  end

  def get_static_page_url_for(target_uri)
    STATIC_PAGES_URLS_MAP[target_uri]
  end

  def css_class_for_admin_sidebar_treeview
    treeview_actions = %w(index educational_users monthly_users annually_users freemium_users)

    (controller_path == 'admin/users' && treeview_actions.include?(action_name)) ? 'active' : ''
  end

  def css_class_for_treeview_users_menu(target_action_path)
    (controller_path == 'admin/users' && action_name == target_action_path) ? 'active' : ''
  end

  def body_page_name
    @body_page_name ||= [controller_name.camelcase.gsub('::',''), action_name.camelcase].join
  end

  def watch_video_url(video_slug)
    "#{ENV['Host']}/watch/#{video_slug}"
  end
end
