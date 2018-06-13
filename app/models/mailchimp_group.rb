class MailchimpGroup < ApplicationRecord

  # Ref.: https://github.com/norman/friendly_id
  extend FriendlyId
  friendly_id :name, use: :slugged

  # VALIDATIONS
  validates :name, :list_id, presence: true

  # ===== Class methods Start =====
  class << self
    def available_list_ids_arr
      self.pluck(:list_id).reject(&:blank?)
    end

    def is_list_ids_available?
      available_list_ids_arr.any?
    end
  end
  # ===== Class methods End =====
end
