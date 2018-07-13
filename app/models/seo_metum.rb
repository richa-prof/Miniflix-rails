class SeoMetum < ActiveRecord::Base
  if ActiveRecord.constants.include?(:MassAssignmentSecurity)
    attr_accessible :seo_meta_type, :browser_title, :meta_description
  end

  scope :static_seo_metas,  -> { where("page_name is NOT NULL") }
  scope :seo_meta_by_page_name, -> (page_name){ where("page_name = ? AND page_name is NOT NULL", page_name) }

  # This PAGE_NAMES constant is used at select tag in file
  # /app/views/marketing_staff/seo_metas/_form.html.erb#L5
  # and for getting the object at line:
  # /app/controllers/api/v1/seo_metas_controller.rb#L24
  # the react dev end code must be aware with these values.
  PAGE_NAMES = ['home_page', 'about_us', 'help_center', 'term_of_services', 'privacy_policy']

  validates_presence_of :page_name, :browser_title, :meta_keywords, :meta_description, if: "seo_meta_id.blank? && seo_meta_type.blank?"
  validates_uniqueness_of :page_name, if: "seo_meta_id.blank? && seo_meta_type.blank?"

  def frontend_view_page_url
    target_page_name = if is_home_page?
                        nil
                      else
                        page_name
                      end
    "#{ENV['Host']}/#{target_page_name}"
  end

  private

  def is_home_page?
    page_name == 'home_page'
  end
end