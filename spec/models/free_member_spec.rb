require 'rails_helper'

RSpec.describe FreeMember, type: :model do
  it "valid FreeMember" do
    free_member = create(:free_member)
    free_member.should be_valid
  end
  context "Validation uniqness" do
    it {should validate_presence_of(:email)}
    it { should validate_uniqueness_of(:email) }
  end
end
