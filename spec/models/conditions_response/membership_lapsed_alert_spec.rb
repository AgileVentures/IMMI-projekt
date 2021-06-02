require 'rails_helper'

RSpec.describe MembershipLapsedAlert, type: :model do

  let(:subject) { described_class.instance }

  # don't write anything to the log
  let(:mock_log) { instance_double("ActivityLogger") }
  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)
  end

  let(:dec_1_2018) { Date.new(2018, 12, 1) }
  let(:dec_2_2018) { Date.new(2018, 12, 2) }
  let(:dec_3_2018) { Date.new(2018, 12, 3) }
  let(:dec_5_2018) { Date.new(2018, 12, 5) }

  let(:dec_1_2017) { Date.new(2017, 12, 1) }

  let(:user) { create(:user) }

  let(:condition) { create(:condition, timing: MembershipLapsedAlert::TIMING_AFTER, config: { days: [1, 3, 5] }) }
  let(:config) { { days: [1, 3, 5] } }
  let(:timing) { MembershipLapsedAlert::TIMING_AFTER }


  describe 'Unit tests' do

    describe '.send_alert_this_day?(config, user)' do

      let(:timing) { described_class.timing_after }
      let(:config) { { days: [1, 3, 5] } }
      let(:condition) { build(:condition, timing: timing, config: config) }

      let(:membership_expiry) { DateTime.new(2020, 6, 6) }
      let(:member1) { instance_double("User", membership_expire_date: membership_expiry) }
      let(:member2) { instance_double("User", membership_expire_date: membership_expiry) }

      describe 'uses RequirementsForMembershipLapsed to see if membership has lapsed' do

        it 'membership has lapsed' do
          allow(described_class).to receive(:days_today_is_away_from)
                                        .and_return(3)
          allow(subject).to receive(:send_on_day_number?)
                                .with(3, config)
                                .and_call_original

          expect(RequirementsForMembershipLapsed).to receive(:requirements_met?)
                                                         .with(user: member1)
                                                         .and_return(true)
          expect(subject.send_alert_this_day?(timing, config, member1)).to be_truthy
        end

        it 'membership has not lapsed' do
          allow(described_class).to receive(:days_today_is_away_from)
                                        .and_return(3)
          allow(subject).to receive(:send_on_day_number?)
                                .with(3, config)
                                .and_call_original

          expect(RequirementsForMembershipLapsed).to receive(:requirements_met?)
                                                         .with(user: member1)
                                                         .and_return(false)
          expect(subject.send_alert_this_day?(timing, config, member1)).to be_falsey
        end
      end

      it 'uses the membership expire date as the basis for calculating the days from today' do
        allow(RequirementsForMembershipLapsed).to receive(:requirements_met?)
                                                      .with(user: member1)
                                                      .and_return(true)
        allow(subject).to receive(:send_on_day_number?)
                              .with(3, config)
                              .and_call_original

        expect(described_class).to receive(:days_today_is_away_from)
                                       .with(membership_expiry, timing)
                                       .and_return(3)
        expect(subject.send_alert_this_day?(timing, config, member1)).to be_truthy
      end

      it 'calls send_on_day_number? with the day to check and the configuration' do
        allow(RequirementsForMembershipLapsed).to receive(:requirements_met?)
                                                      .with(user: member1)
                                                      .and_return(true)
        allow(described_class).to receive(:days_today_is_away_from)
                                      .with(membership_expiry, timing)
                                      .and_return(3)

        expect(subject).to receive(:send_on_day_number?)
                               .with(3, config)
                               .and_call_original
        expect(subject.send_alert_this_day?(timing, config, member1)).to be_truthy
      end


      it 'RequirementsForMembershipLapsed is not satisfied' do
        allow(RequirementsForMembershipLapsed).to receive(:requirements_met?).and_return(false)

        expect(described_class.instance.send_alert_this_day?(timing, config, user)).to be_falsey
      end


      context 'RequirementsForMembershipLapsed is satisfied' do
        let(:lapsed_member) { create(:member, membership_status: :in_grace_period, first_day: dec_1_2017) }

        it 'false when the day is not in the config list of days to send the alert' do
          travel_to(dec_2_2018) do
            expect(described_class.instance.send_alert_this_day?(timing, config, lapsed_member)).to be_falsey
          end
        end

        it 'true when the day is in the config list of days to send the alert' do
          listed_days = [dec_1_2018, dec_3_2018, dec_5_2018]
          listed_days.each do |alert_day|
            travel_to(alert_day) do
              expect(described_class.instance.send_alert_this_day?(timing, config, lapsed_member)).to be_truthy
            end
          end
        end

      end

    end


    it '.mailer_method' do
      expect(described_class.instance.mailer_method).to eq :membership_lapsed
    end
  end


  describe 'Integration tests' do

    describe 'delivers emails to each user whose membership has lapsed' do
      let(:membership_expiry) { DateTime.new(2020, 6, 6) }
      let(:member1) { instance_double("User", membership_expire_date: membership_expiry) }
      let(:member2) { instance_double("User", membership_expire_date: membership_expiry) }
      let(:member_not_expired) { instance_double("User") }

      context 'timing is after' do
        let(:timing) { described_class.timing_after }

        context 'config days: [3, 5]' do
          let(:config) { { days: [3, 5] } }
          let(:condition) { build(:condition, timing: timing, config: config) }


          before(:each) do
            allow(RequirementsForMembershipLapsed).to receive(:requirements_met?)
                                                          .with(user: member1)
                                                          .and_return(true)
            allow(RequirementsForMembershipLapsed).to receive(:requirements_met?)
                                                          .with(user: member2)
                                                          .and_return(true)
            allow(RequirementsForMembershipLapsed).to receive(:requirements_met?)
                                                          .with(user: member_not_expired)
                                                          .and_return(false)

            allow(subject).to receive(:entities_to_check).and_return([member1,
                                                                      member2,
                                                                      member_not_expired])
          end


          context 'today is 5 days after the most recent membership expiry' do
            let(:testing_today) { membership_expiry + 5 } # '+ 5' will match the '5' in config[:days]

            it 'sends email to members whose membership has lapsed' do
              expect(subject).to receive(:send_email)
                                     .with(member1, mock_log)
              expect(subject).to receive(:send_email)
                                     .with(member2, mock_log)
              travel_to testing_today do
                subject.condition_response(condition, mock_log)
              end
            end
          end

          context 'today is 6 days after the most recent membership expiry' do
            let(:testing_today) { membership_expiry + 6 } # '+ 6' will not match anything in config[:days]

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
