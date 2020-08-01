require 'rails_helper'
require 'email_spec/rspec'

require 'shared_context/stub_email_rendering'
require 'shared_context/named_dates'


RSpec.describe MembershipExpireAlert do

  include_context 'named dates'

  subject  { described_class.instance }

  let(:mock_log) { instance_double("ActivityLogger") }

  let(:user) { create(:user, email: FFaker::InternetSE.disposable_email) }


  let(:paid_exp_dec30) {
    member = create(:member_with_membership_app)
    create(:membership_fee_payment,
           :successful,
           user:        member,
           start_date:  jan_1,
           expire_date: User.expire_date_for_start_date(jan_1))
    member
  }

  let(:paid_expires_dec2) {
    member = create(:member_with_membership_app)

    create(:membership_fee_payment,
           :successful,
           user:        member,
           start_date:  lastyear_dec_3,
           expire_date: User.expire_date_for_start_date(lastyear_dec_3))
    member
  }

  let(:condition) { create(:condition, :before, config: { days: [1, 7, 14, 30] }) }

  let(:config) { { days: [1, 7, 14, 30] } }

  let(:timing) { MembershipExpireAlert::TIMING_BEFORE }

  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)
  end


  # All examples assume today is 1 December, 2018 by default
  around(:each) do |example|
    Timecop.freeze(Time.utc(2018, 12, 1))
    example.run
    Timecop.return
  end


  describe '.send_alert_this_day?(config, user)' do

    context 'user is a member' do

      context 'membership has not expired yet' do

        it 'true when the day is in the config list of days to send the alert' do
          expect(described_class.instance.send_alert_this_day?(timing, config, paid_exp_dec30)).to be_truthy
        end

        it 'false when the day  is not in the config list of days to send the alert' do
          expect(described_class.instance.send_alert_this_day?(timing, { days: [999] }, paid_exp_dec30)).to be_falsey
        end

      end # context 'membership has not expired yet'


      context 'membership expiration is before or on the given date to check' do

        context 'membership expires 1 day after today (dec 1); expires dec 2' do

          it 'true if the day is in the config list of days to send the alert (= 1)' do
            expect(paid_expires_dec2.membership_expire_date).to eq dec_2
            expect(described_class.instance.send_alert_this_day?(timing, { days: [1] }, paid_expires_dec2)).to be_truthy
          end

          it 'false if the day is not in the config list of days to send the alert' do
            expect(described_class.instance.send_alert_this_day?(timing, { days: [999] }, paid_expires_dec2)).to be_falsey
          end

        end

        context 'membership expires on the given date (dec 1), expired dec 1' do

          let(:paid_expires_today_member) {
            member = create(:member_with_membership_app)

            create(:membership_fee_payment,
                   :successful,
                   user:        member,
                   start_date:  lastyear_dec_2,
                   expire_date: User.expire_date_for_start_date(lastyear_dec_2))
            member
          }

          it 'false even if the day is in the list of days to send it' do
            expect(paid_expires_today_member.membership_expire_date).to eq dec_1
            expect(described_class.instance.send_alert_this_day?(timing, { days: [0] }, paid_expires_today_member)).to be_falsey
          end

        end

      end # context 'membership expiration is before or on the given date'


      context 'membership has expired' do

        let(:paid_expired_member) {
          member = create(:member_with_membership_app)
          create(:membership_fee_payment,
                 :successful,
                 user:        member,
                 start_date:  lastyear_nov_30,
                 expire_date: User.expire_date_for_start_date(lastyear_nov_30))
          member
        }


        it 'false if the day is in the config list of days to send the alert' do
          expect(described_class.instance.send_alert_this_day?(timing, config, paid_expired_member)).to be_falsey
        end

        it 'false if the day is not in the config list of days to send the alert' do
          expect(described_class.instance.send_alert_this_day?(timing, { days: [999] }, paid_expired_member)).to be_falsey
        end

      end

    end


    context 'user is not a member and has no payments: always false' do

      let(:user) { create(:user) }

      it 'false when the day is in the config list of days to send the alert' do
        expect(described_class.instance.send_alert_this_day?(timing, config, user)).to be_falsey
      end

      it 'false when the day is not in the config list of days to send the alert' do
        expect(described_class.instance.send_alert_this_day?(timing, { days: [999] }, user)).to be_falsey
      end

    end

  end


  it '.mailer_method' do
    expect(described_class.instance.mailer_method).to eq :membership_expiration_reminder
  end


  describe 'delivers email to all members about their upcoming expiration date' do

    include_context 'stub email rendering'


    describe 'emails sent to all members and logged' do

      let(:paid_exp_dec30_logmsg)     { "MembershipExpireAlert email sent to id: #{paid_exp_dec30.id} email: #{paid_exp_dec30.email}." }
      let(:paid_expires_dec2_logmsg)  { "MembershipExpireAlert email sent to id: #{paid_expires_dec2.id} email: #{paid_expires_dec2.email}." }


      it 'nov 25: sends out 1 email' do
        nov_25_ts = Time.utc(2018, 11, 25)
        Timecop.freeze(nov_25_ts) do
          # create the members
          paid_exp_dec30
          paid_expires_dec2

          # update membership status based on today's date
          MembershipStatusUpdater.instance.user_updated(paid_exp_dec30)
          MembershipStatusUpdater.instance.user_updated(paid_expires_dec2)

          expect(mock_log).to receive(:info).with(/#{paid_expires_dec2_logmsg}/)
          expect(mock_log).not_to receive(:info).with(/#{paid_exp_dec30}/)

          described_class.instance.condition_response(condition, mock_log)
          expect(ActionMailer::Base.deliveries.size).to eq 1
        end
      end

      it 'nov 30: sends out no emails' do
        nov_30_ts = Time.utc(2018, 11, 30)
        Timecop.freeze(nov_30_ts) do
          # create the members
          paid_exp_dec30
          paid_expires_dec2

          # update membership status based on today's date
          MembershipStatusUpdater.instance.user_updated(paid_exp_dec30)
          MembershipStatusUpdater.instance.user_updated(paid_expires_dec2)

          expect(mock_log).not_to receive(:info)

          described_class.instance.condition_response(condition, mock_log)
          expect(ActionMailer::Base.deliveries.size).to eq 0
        end
      end

      it 'dec 1: sends out 2 emails' do
        dec_1_ts = Time.utc(2018, 12, 1)
        Timecop.freeze(dec_1_ts) do
          # create the members
          paid_exp_dec30
          paid_expires_dec2

          # update membership status based on today's date
          MembershipStatusUpdater.instance.user_updated(paid_exp_dec30)
          MembershipStatusUpdater.instance.user_updated(paid_expires_dec2)

          expect(mock_log).to receive(:info).with(/#{paid_exp_dec30_logmsg}/)
          expect(mock_log).to receive(:info).with(/#{paid_expires_dec2_logmsg}/)

          described_class.instance.condition_response(condition, mock_log)
          expect(ActionMailer::Base.deliveries.size).to eq 2
        end
      end

      it 'dec 30: sends out 1 email' do
        dec_30_ts = Time.utc(2018, 12, 30)
        Timecop.freeze(dec_30_ts) do
          # create the members
          paid_exp_dec30
          paid_expires_dec2

          # update membership status based on today's date
          MembershipStatusUpdater.instance.user_updated(paid_exp_dec30)
          MembershipStatusUpdater.instance.user_updated(paid_expires_dec2)

          expect(mock_log).to receive(:info).with(/#{paid_exp_dec30_logmsg}/)
          expect(mock_log).not_to receive(:info).with(/#{paid_expires_dec2_logmsg}/)

          described_class.instance.condition_response(condition, mock_log)
          expect(ActionMailer::Base.deliveries.size).to eq 1
        end
      end

    end

  end
end
