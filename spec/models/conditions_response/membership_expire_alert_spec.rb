require 'rails_helper'
require 'email_spec/rspec'


RSpec.describe MembershipExpireAlert, type: :model do

  let(:jan_1) { Date.new(2018, 1, 1) }
  let(:dec_1) { Date.new(2018, 12, 1) }
  let(:dec_2) { Date.new(2018, 12, 2) }

  let(:nov_30_last_year) { Date.new(2017, 11, 30) }
  let(:dec_2_last_year) { Date.new(2017, 12, 2) }
  let(:dec_3_last_year) { Date.new(2017, 12, 3) }

  let(:user) { create(:user, email: FFaker::InternetSE.disposable_email) }

  let(:condition) { create(:condition, :before, config: { days: [1, 7, 14, 30]} ) }

  let(:config) { { days: [1, 7, 14, 30] } }

  let(:timing) { MembershipExpireAlert::TIMING_BEFORE }


  # All examples assume today is 1 December, 2018
  around(:each) do |example|
    Timecop.freeze(dec_1)
    example.run
    Timecop.return
  end


  describe '.send_alert_this_day?(config, user)' do

    context 'user is a member' do

      context 'membership has not expired yet' do

        let(:paid_member) {
          member = create(:member_with_membership_app)
          create(:membership_fee_payment,
                 :successful,
                 user:        member,
                 start_date:  jan_1,
                 expire_date: User.expire_date_for_start_date(jan_1))
          member
        }


        it 'true when the day is in the config list of days to send the alert' do
          expect(described_class.send_alert_this_day?(timing, config, paid_member)).to be_truthy
        end

        it 'false when the day  is not in the config list of days to send the alert' do
          expect(described_class.send_alert_this_day?(timing, { days: [999] }, paid_member)).to be_falsey
        end

      end # context 'membership has not expired yet'


      context 'membership expiration is before or on the given date to check' do

        context 'membership expires 1 day after today (dec 1); expires dec 2' do

          let(:paid_expires_tomorrow_member) {
            member = create(:member_with_membership_app)

            create(:membership_fee_payment,
                   :successful,
                   user:        member,
                   start_date:  dec_3_last_year,
                   expire_date: User.expire_date_for_start_date(dec_3_last_year))
            member
          }

          it 'true if the day is in the config list of days to send the alert (= 1)' do
            expect(paid_expires_tomorrow_member.membership_expire_date).to eq dec_2
            expect(described_class.send_alert_this_day?(timing, { days: [1] }, paid_expires_tomorrow_member)).to be_truthy
          end

          it 'false if the day is not in the config list of days to send the alert' do
            expect(described_class.send_alert_this_day?(timing, { days: [999] }, paid_expires_tomorrow_member)).to be_falsey
          end

        end

        context 'membership expires on the given date (dec 1), expired dec 1' do

          let(:paid_expires_today_member) {
            member = create(:member_with_membership_app)

            create(:membership_fee_payment,
                   :successful,
                   user:        member,
                   start_date:  dec_2_last_year,
                   expire_date: User.expire_date_for_start_date(dec_2_last_year))
            member
          }

          it 'false even if the day is in the list of days to send it' do
            expect(paid_expires_today_member.membership_expire_date).to eq dec_1
            expect(described_class.send_alert_this_day?(timing, { days: [0] }, paid_expires_today_member)).to be_falsey
          end

        end

      end # context 'membership expiration is before or on the given date'


      context 'membership has expired' do

        let(:paid_expired_member) {
          member = create(:member_with_membership_app)
          create(:membership_fee_payment,
                 :successful,
                 user:        member,
                 start_date:  nov_30_last_year,
                 expire_date: User.expire_date_for_start_date(nov_30_last_year))
          member
        }


        it 'false if the day is in the config list of days to send the alert' do
          expect(described_class.send_alert_this_day?(timing, config, paid_expired_member)).to be_falsey
        end

        it 'false if the day is not in the config list of days to send the alert' do
          expect(described_class.send_alert_this_day?(timing, { days: [999] }, paid_expired_member)).to be_falsey
        end

      end

    end


    context 'user is not a member and has no payments: always false' do

      let(:user) { create(:user) }

      it 'false when the day is in the config list of days to send the alert' do
        expect(described_class.send_alert_this_day?(timing, config, user)).to be_falsey
      end

      it 'false when the day is not in the config list of days to send the alert' do
        expect(described_class.send_alert_this_day?(timing, { days: [999] }, user)).to be_falsey
      end

    end

  end


  it '.mailer_method' do
    expect(described_class.mailer_method).to eq :membership_expiration_reminder
  end

end
