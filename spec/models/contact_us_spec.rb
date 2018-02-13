require 'rails_helper'

RSpec.describe ContactUs, type: :model do
  describe "Association" do
    context "has_many" do
      it{ should have_many(:contact_user_replies) }
    end
  end
end
