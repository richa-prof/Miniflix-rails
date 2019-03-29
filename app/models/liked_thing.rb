class LikedThing < ApplicationRecord
  self.table_name = 'liked_info'

  belongs_to :user
  belongs_to :thing, polymorphic: true

#, foreign_key: :thing_id, foreign_type: :thing_type
end