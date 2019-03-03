class Episode < Movie

  # ASSOCIATIONS

  belongs_to :season


  # CALLBACKS
  #before_save :create_bitly_url, if: -> { slug_changed? }
  #after_create :write_file
  #after_update :send_notification
end


