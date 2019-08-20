class OwnFilm < ApplicationRecord
  belongs_to :film, polymorphic: true # Movie or Serial
  belongs_to :user
  before_save :check_same_film_id_and_type_exist

  private
  def check_same_film_id_and_type_exist
    old_data = OwnFilm.find_by(user_id: self.user_id, film_id: self.film_id)
    old_data.destroy if old_data.present?
  end
end
