class CreateFilmSchoolStudentsSessions < ActiveRecord::Migration[5.1]
  def change
    create_table :film_school_students_sessions do |t|
      t.string :name
      t.string :ip_address
      t.string :access_token
      t.datetime :sign_out_time
      t.references :user, foreign_key: true
      t.references :organization, foreign_key: true

      t.timestamps
    end
  end
end
