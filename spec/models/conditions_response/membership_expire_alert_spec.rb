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

        let(:is_a_member) { instance_double("User", payments_current?: true, current_member?: true) }

        it 'checks to see if today is the right number of days away' do
          allow(is_a_member).to receive(:membership_expire_date).and_return(DateTime.new(2018, 12, 31))

          expect(is_a_member).to receive(:current_member?).and_return(true)
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
          not_a_member = instance_double("User", payments_current?: false, current_member?: false)
          allow(not_a_member).to receive(:membership_expire_date).and_return(DateTime.new(2018, 12, 31))

          expect(not_a_member).to receive(:current_member?).and_return(false)
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
        let(:timing) { described_class.timing_before }

        context 'config days: [10, 2]' do
          let(:config_10_2) { { days: [10, 2] } }
          let(:condition) { build(:condition, timing: timing, config: config_10_2) }


          let(:membership_expiry) { DateTime.new(2020, 12, 1, 6) }

          let(:mock_not_member) { instance_double("User", current_member?: false) }
          let(:mock_member1) { instance_double("User", membership_expire_date: membership_expiry, current_member?: true) }
          let(:mock_member2) { instance_double("User", membership_expire_date: membership_expiry, current_member?: true) }

          before(:each) do
            allow(subject).to receive(:entities_to_check).and_return([mock_not_member,
                                                                      mock_member1,
                                                                      mock_member2])
            allow(mock_not_member).to receive(:payments_current?).and_return(false)
            allow(mock_member1).to receive(:current_member?).and_return(true)
            allow(mock_member1).to receive(:payments_current?).and_return(true)
            allow(mock_member2).to receive(:current_member?).and_return(true)
            allow(mock_member2).to receive(:payments_current?).and_return(true)
          end

          context '10 days before expiration date' do
            let(:testing_today) { membership_expiry - 10.days }

            it 'sends out alerts to members whose membership expiry is in 10 days' do

              allow(subject).to receive(:entities_to_check).and_return([mock_not_member,
                                                                        mock_member1,
                                                                        mock_member2])

              expect(subject).to receive(:send_email)
                                     .with(mock_member1, mock_log)
              expect(subject).to receive(:send_email)
                                     .with(mock_member2, mock_log)
              travel_to testing_today do
                subject.condition_response(condition, mock_log)
              end
            end


            context '11 days before expiration date' do
              let(:testing_today) { membership_expiry - 11.days }

              it 'no emails are sent' do
                expect(subject).not_to receive(:send_email)
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
end

