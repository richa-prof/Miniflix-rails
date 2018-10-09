require 'rails_helper'

RSpec.describe UserPaymentMethod, type: :model do
  context "check attribute accessor" do
    it {should have_encrypted_attribue(:card_number)}
    it {should have_encrypted_attribue(:card_CVC)}
    it {should have_encrypted_attribue(:expiration_month)}
  end

  describe "Association" do
    context "has_many" do
      it{ should have_many(:user_payment_transactions).dependent(:destroy) }
    end
    context "belongs_to" do
      it{ should belong_to(:user) }
    end
  end

  context "nested attribute" do
    it { should accept_nested_attributes_for(:user_payment_transactions) }
  end

  context "check enum" do
    payment_hash = {
      paypal: 'Paypal',
      card:   'Card',
      ios:    'ios'
    }
    it {UserPaymentMethod.should have_valid_string_enum(:payment_types, payment_hash)}
  end

  context "Validation" do
    subject { create(:user_payment_method) }
      it { should validate_presence_of(:payment_type) }
      context "payment type- card?" do
        before { allow(subject).to receive(:card?).and_return(true) }
        it { should validate_presence_of(:expiration_month) }
        it { should validate_presence_of(:expiration_year) }
        it { should validate_presence_of(:card_CVC) }
      end
  end

end
