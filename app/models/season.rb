class Season < ApplicationRecord
  belongs_to :serial, class_name: "Serial", foreign_key: "admin_serial_id"
  has_many :episodes, dependent: :destroy, foreign_key: "season_id"
end
