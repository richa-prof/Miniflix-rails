SeoMeta.module_eval do
  class << self
    def attributes
      @attributes ||= {
        :browser_title => :string,
        :meta_keywords => :string,
        :meta_description => :text,
      }
    end
  end
end

def add_validations
  attr_accessor :check_seo_meta_tags
  validates_presence_of :browser_title, :meta_keywords, :meta_description, if: "check_seo_meta_tags.present?"
end
