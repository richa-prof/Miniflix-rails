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
end
