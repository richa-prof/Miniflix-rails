require 'rails_helper'

RSpec.describe User, type: :model do
  it "valid user" do
   FactoryBot.create(:user).should be_valid
  end

  context "Attribute Accessor" do
   it { should have_attr_accessor(:temp_user_id) }
  end

  context "Association" do
    context "has_many" do
      it { should have_many(:user_payment_methods) }
      it { should have_many(:user_filmlists) }
      it { should have_many(:user_video_last_stops) }
    end
    context "has_one" do
      it { should have_one(:user_email_notification) }
      it { should have_one(:logged_in_user) }
    end
  end

  context "nested attribute" do
    it { should accept_nested_attributes_for(:user_payment_methods) }
  end

  context "check constant" do
    it "fixed list constant for OLDUSER" do
      User.should have_constant(:OLDUSER, "Trial Completed")
    end
    it "fixed list constant for UPGRADE_SUBSCRIPTION" do
      User.should have_constant(:UPGRADE_SUBSCRIPTION, "upgrade plan for")
    end
    it "fixed list constant for UPDATE_SUBSCRIPTION" do
      User.should have_constant(:UPDATE_SUBSCRIPTION, "subscription plan for update")
    end
  end

  context "enum checking" do
    plan_hash = {
      Educational: "Educational",
      Monthly: "Monthly",
      Annually: "Annually",
      Freemium: "Freemium"
    }
    sign_up_hash = {
      Web: "web",
      Android: "android",
      iOS: 'ios'
    }
    plan_status_hash = {
      Activate: "Activate",
      Cancelled: 'Cancelled',
      Expired: 'Expired'
    }

    it { User.should have_valid_string_enum(:registration_plans, plan_hash)}
    it { User.should have_valid_string_enum(:sign_up_froms, sign_up_hash)}
    it { User.should have_valid_string_enum(:subscription_plan_statuses, plan_status_hash)}
  end

  context "Presence of validation check-- record" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_presence_of(:sign_up_from) }
    context "user comes from ios background" do
      before { allow(subject).to receive(:iOS? && :Monthly?).and_return(true) }
      it { should validate_presence_of(:receipt_data) }
    end
  end

  describe "Scope" do
    it "paid user" do
      users = create_list(:user, 10, registration_plan: ["Monthly", "Annually"].sample)
      (User.paid_users).should  match_array users
    end

    it "find user by month and year" do
      month_and_year = [Date.today.month, Date.today.year]
      users = create_list(:user, 10)
      users = User.where('extract(month from created_at) = ? and extract(year from created_at) = ?', month_and_year.first, month_and_year.last)
      (User.find_by_month_and_year(month_and_year)).should match_array (users)
    end
  end

  describe "Callback" do
    context "before_create" do
      context "create_user_email_notification" do
         it { should callback(:create_user_email_notification).before(:create) }
         it "with calling of callback" do
           user = create(:user)
           email_and_notification = create(:user_email_notification, user: user)
           user.user_email_notification.as_json.should eq (email_and_notification.as_json)
         end
      end
      context "set_free_user" do
        let (:create_free_user) do
          free_member = create(:free_member, email: "test1@yopmail.com")
          create(:user, registration_plan: "Educational", email: free_member.email)
        end
        it { should callback(:set_free_user).before(:create).if('((Educational? && FreeMember.find_by_email(email)) || Freemium?)') }
        it "with valid user" do

          create_free_user.is_free.should eq(true)
        end
        it "with invalid user" do
          user = create(:user, registration_plan: ["Monthly", "Annually"].sample)
          user.is_free.should_not eq(true)
        end
      end
      #
      context "check user valid for free" do
        it { should callback(:check_user_valid_for_free).before(:create).if ('Educational?') }
        it "with Educational plan" do
          user = create(:user, registration_plan: "Educational")

        end
        it "With other plan" do
          user = create(:user, registration_plan: ["Monthly", "Annually", "Freemium"].sample)
        end
      end
    end

    context "after_create" do
      context "delete temp user" do
        it {should callback(:delete_temp_user).after(:create).if('temp_user_id.present?')}
        it "check callback method" do
          temp_user = create(:temp_user)
          user = create(:user, temp_user_id: temp_user.id)
          user.destroy
          (TempUser.find_by_id temp_user.id).should eq (nil)
        end
      end
      context "when send_free_user_mail" do
        it { should callback(:send_free_user_mail).before(:update).if('is_free')}
      end
      context "send send_signup_mail_for_paid_user" do
        it { should callback(:send_signup_mail_for_paid_user).before(:update).unless('is_free')}
      end
    end

    context "before_update" do
      it { should callback(:assign_subscription_cancel_date).before(:update).if('Cancelled?')}
      it "check assign subscription plan" do
        user = create(:user)
        user.Cancelled!
        user.cancelation_date.class.should eq(ActiveSupport::TimeWithZone)
      end
    end

    context "before_destroy" do
      it { should callback(:cancel_subscription_plan).before(:destroy)}
      it "cancel subscription plan" do

      end
    end
  end

  describe "Instance method" do

    context "valid_for_monthly_plan?" do
      it "with freemium user" do
        user = create(:user , registration_plan: "Freemium")
        user.valid_for_monthly_plan?.should eq (true)
      end
      it "with other plan user" do
        user = create(:user , registration_plan: ["Monthly", "Annually", "Educational"].sample)
        user.valid_for_monthly_plan?.should_not eq (true)
      end
    end

    context "check_user_free_or_not" do
      it "with freemium or Educational user" do
        user = create(:user , registration_plan: ["Freemium", "Educational"].sample)
        user.check_user_free_or_not.should eq (true)
      end
      it "with other plan user" do
        user = create(:user , registration_plan: ["Monthly", "Annually"].sample)
        user.check_user_free_or_not.should_not eq (true)
      end
    end
  end

end
