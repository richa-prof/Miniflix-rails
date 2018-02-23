class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def initialize(*)
    super
  rescue ArgumentError
    valid?
  end
end
