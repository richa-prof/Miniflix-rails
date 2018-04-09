class SocialMediaLink < ApplicationRecord
  belongs_to :user

  def assign_given_attributes(assigned_params)
    assigned_params.each do |key, value|
      self.assign_attributes(key.to_sym => value) if key.present?
    end
  end
end
