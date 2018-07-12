class SeoMetum < ActiveRecord::Base
  if ActiveRecord.constants.include?(:MassAssignmentSecurity)
    attr_accessible :seo_meta_type, :browser_title, :meta_description
  end

  scope :static_seo_metas,  -> { where("page_name is NOT NULL") }
  scope :seo_meta_by_page_name, -> (page_name){ where("page_name = ? AND page_name is NOT NULL", page_name) }

  PAGE_NAMES = ['home_page']

  validates_presence_of :page_name, :browser_title, :meta_keywords, :meta_description, if: "seo_meta_id.blank? && seo_meta_type.blank?"
  validates_uniqueness_of :page_name, if: "seo_meta_id.blank? && seo_meta_type.blank?"

  def frontend_view_page_url
    case self.page_name
    when 'home_page'
      ENV['Host']
    end
  end
end