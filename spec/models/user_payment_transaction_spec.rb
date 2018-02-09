require 'rails_helper'

RSpec.describe UserPaymentTransaction, type: :model do

  describe "Association" do
    context "belongs_to" do
      it{ should belong_to(:user_payment_method) }
    end
  end

  context "check validation" do
    it { should validate_presence_of(:payment_expire_date) }
    it { should validate_uniqueness_of(:transaction_id)}
  end

  context "Delegate" do
    it { should delegate_method(:payment_type).to(:user_payment_method).with_prefix(:transcation) }
  end

  context "methods" do
    let (:create_payment_transaction){
       create(:user_payment_transaction, user_payment_method: FactoryBot.create(:user_payment_method, user: FactoryBot.create(:user)) )
    }
    it "retrun payment type of user from user payment method" do
      payment_type = create_payment_transaction.user_payment_method.payment_type
      create_payment_transaction.payment_type.should eq (payment_type)
    end

    it "check as_json method response" do
      user_payment_transaction = create_payment_transaction
      transaction_hash = {id: user_payment_transaction.id, payment_date: user_payment_transaction.payment_date, payment_expire_date: user_payment_transaction.payment_expire_date, transaction_id: user_payment_transaction.transaction_id, amount: user_payment_transaction.amount}
      user_payment_transaction.as_json.should eq transaction_hash.stringify_keys
    end

  end
end
