require 'rails_helper'

RSpec.describe MembershipFeeOverdueAlert, type: :model do

  let(:nov_30) { Date.new(2018, 11, 30) }
  let(:dec_1)  { Date.new(2018, 12,  1) }
  let(:dec_2)  { Date.new(2018, 12,  2) }
  let(:dec_3)  { Date.new(2018, 12,  3) }
  let(:nov_30_next_year) { Date.new(2019, 11, 30) }


  let(:condition) { create(:condition, timing: MembershipFeeOverdueAlert::TIMING_AFTER, config: { days: [1, 3, 5]} ) }
  let(:config) { { days: [1, 3, 5] } }
  let(:timing) { MembershipFeeOverdueAlert::TIMING_AFTER }


  around(:each) do |example|
    Timecop.freeze(dec_1)
    example.run
    Timecop.return
  end


  describe '.send_alert_this_day?(config, user)' do

    context 'user has an approved application' do

      context 'next membership payment is past due' do

        let(:membership_app) do
          app = create(:shf_application, :accepted)
          app.update(created_at: nov_30)
          app
        end

        let(:user) { membership_app.user }

        pending "We don't have a way to calculate how many days _past_due_ the membership_fee payment is!"

        #it "true when today (dec 1) is in the config list of days [1] to send the alert" do
          #'expect(described_class.send_alert_this_day?(timing, config, user)).to be_truthy'
        #end

        it 'false when today is not in the config list of days to send the alert' do # dec_3
          expect(described_class.send_alert_this_day?(timing, config, user)).to be_falsey
        end
      end


      context 'next membership payment is NOT past due' do

        let(:membership_app) do
          app = create(:shf_application, :accepted, updated_at: dec_1)
          app.update(created_at: dec_1)
          app_user = app.user

          create(:payment, :successful, user: app_user,
                 payment_type: Payment::PAYMENT_TYPE_MEMBER,
                 start_date: dec_1,
                 expire_date: nov_30_next_year)
          app
        end

        let(:user) { membership_app.user }

        it "false when today is in the config list of days to send the alert" do #dec2
          expect(described_class.send_alert_this_day?(timing, config, user)).to be_falsey
        end

        it 'false when today is not in the config list of days to send the alert' do #dec3
          expect(described_class.send_alert_this_day?(timing, config, user)).to be_falsey
        end

      end # context 'next membership payment is NOT past due'
    end


    context 'user does NOT have an approved application (= always false)' do

      let(:user) { create( :user ) }

      it "false when today is in the config list of days to send the alert" do #dec2
        expect(described_class.send_alert_this_day?(timing, config, user)).to be_falsey
      end

      it 'false when today is not in the config list of days to send the alert' do #dec3
        expect(described_class.send_alert_this_day?(timing, config, user)).to be_falsey
      end

    end # context 'user does NOT have an approved application'

  end


  it '.mailer_method' do
    expect(described_class.mailer_method).to eq :membership_payment_due
  end

end
