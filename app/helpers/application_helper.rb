module ApplicationHelper
  def errors_for(form, field)
    content_tag(:span, form.object.errors[field].join(', '), class: 'blg-advice text-danger') unless form.object.errors[field].blank?
  end
end
