require 'rails_helper'

RSpec.describe ContactUserReply, type: :model do
  describe "Association" do
    context "belongs_to" do
      it{ should belong_to(:contact_us) }
    end
  end
end
