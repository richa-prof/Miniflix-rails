require 'rails_helper'

RSpec.describe UserFilmlist, type: :model do
  describe "Association" do
    context "belongs_to" do
      it{ should belong_to(:user) }
      it{ should belong_to(:movie) }
    end
  end
end
