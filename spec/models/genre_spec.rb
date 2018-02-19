require 'rails_helper'

RSpec.describe Genre, type: :model do

  it { should have_many(:movies).dependent(:destroy).with_foreign_key('admin_genre_id') }
  it { described_class.should have_per_page(3) }
  it { described_class.should have_constant(:PER_PAGE, 3) }

  it "should generate valid factory" do
    expect(create(:genre)).to be_valid
  end
end
