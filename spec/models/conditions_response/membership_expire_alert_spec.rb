require 'rails_helper'

RSpec.describe MembershipExpireAlert do

  subject { described_class.instance } # just for readability

  # don't write anything to the log
  let(:mock_log) { instance_double("ActivityLogger") }
  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)
  end


  describe 'Unit tests' do

    let(:condition) { build(:condition, :before, config: { days: [1, 7, 14, 30] }) }
    let(:config) { { days: [1, 7, 14, 30] } }
    let(:timing) { MembershipExpireAlert::TIMING_BEFORE }

    describe '.send_alert_this_day?(config, user)' do

      context 'user is a member' do

        let(:is_a_member) { instance_double("User", membership_current?: true) }

        it 'checks to see if today is the right number of days away' do
          allow(is_a_member).to receive(:membership_expire_date).and_return(DateTime.new(2018, 12, 31))

          expect(is_a_member).to receive(:membership_current?).and_return(true)
          expect(described_class).to receive(:days_today_is_away_from)
                                         .with(is_a_member.membership_expire_date, timing)
                                         .and_return(30)
          expect(subject).to receive(:send_on_day_number?).and_return(true)

          travel_to(Time.zone.local(2018, 12, 1)) do
            expect(subject.send_alert_this_day?(timing, config, is_a_member)).to be_truthy
          end
        end


      end


      context 'not a member (membership has expired)' do

        it 'only needs to check the membership status and return false right away' do
          not_a_member = instance_double("User", membership_current?: false)
          allow(not_a_member).to receive(:membership_expire_date).and_return(DateTime.new(2018, 12, 31))

          expect(not_a_member).to receive(:membership_current?).and_return(false)
          expect(described_class).not_to receive(:days_today_is_away_from)
          expect(subject).not_to receive(:send_on_day_number?)

          travel_to(Time.zone.local(2018, 12, 1)) do
            expect(subject.send_alert_this_day?(timing, config, not_a_member)).to be_falsey
          end
        end

      end
    end


    it '.mailer_method' do
      expect(subject.mailer_method).to eq :membership_expiration_reminder
    end

  end


  describe 'Integration tests' do

    describe 'delivers email to all members about their upcoming expiration date' do

      # set the configuration (days that the emails will be sent)
      context 'configuration timing = before (send alerts X days _before_ membership expiration date)' do
        let(:timing_before) { MembershipExpireAlert::TIMING_BEFORE }

        context 'config days: [10, 2]' do
          let(:config_10_2) { { days: [10, 2] } }

          context '10 days before expiration date' do
            let(:condition) { build(:condition, :before, config: config_10_2) }

            let(:membership_expiration_date) { DateTime.new(2020, 12, 30, 6) }

            it 'sends out alerts only to  users meeting the criteria for the alert' do

              testing_today = DateTime.new(2020, 12, 20)

              mock_not_member = instance_double("User")
              allow(mock_not_member).to receive(:membership_current?).and_return(false)

              mock_member_exp_in_10_days = instance_double("User")
              allow(mock_member_exp_in_10_days).to receive(:membership_current?).and_return(true)
              exp_10d_later = testing_today + 10
              allow(mock_member_exp_in_10_days).to receive(:membership_expire_date).and_return(exp_10d_later)

              mock_member_exp_in_2_days = instance_double("User")
              allow(mock_member_exp_in_2_days).to receive(:membership_current?).and_return(true)
              exp_2d_later = testing_today + 2
              allow(mock_member_exp_in_2_days).to receive(:membership_expire_date).and_return(exp_2d_later)

              mock_member_exp_in_3_days = instance_double("User")
              allow(mock_member_exp_in_3_days).to receive(:membership_current?).and_return(true)
              exp_3d_later = testing_today + 3
              allow(mock_member_exp_in_3_days).to receive(:membership_expire_date).and_return(exp_3d_later)

              allow(subject).to receive(:entities_to_check).and_return([mock_not_member,
                                                                        mock_member_exp_in_2_days,
                                                                        mock_member_exp_in_3_days,
                                                                        mock_member_exp_in_10_days])

              expect(subject).to receive(:send_email)
                                     .with(mock_member_exp_in_2_days, mock_log)
              expect(subject).to receive(:send_email)
                                     .with(mock_member_exp_in_10_days, mock_log)
              travel_to testing_today do
                subject.condition_response(condition, mock_log)
              end

            end

          end

        end

      end

    end
  end
end

