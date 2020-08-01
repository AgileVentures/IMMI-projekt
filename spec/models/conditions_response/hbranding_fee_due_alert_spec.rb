require 'rails_helper'
require 'email_spec/rspec'

require 'shared_context/stub_email_rendering'
require 'shared_context/named_dates'


RSpec.describe HBrandingFeeDueAlert do

  include_context 'named dates'

  subject  { described_class.instance }

  let(:mock_log) { instance_double("ActivityLogger") }

  let(:user) { create(:user, email: FFaker::InternetSE.disposable_email) }

  let(:company) { create(:company) }


  let(:config) { { days: [1, 7, 15, 30] } }
  let(:timing) { HBrandingFeeDueAlert::TIMING_AFTER }
  let(:condition) { create(:condition, timing, config) }

  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)
  end


  # All examples assume today is 1 December, 2018
  around(:each) do |example|
    Timecop.freeze(dec_1)
    example.run
    Timecop.return
  end


  describe '.send_alert_this_day?(config, user)' do

    context 'false if h-branding fee has not expired (none is due)' do

      let(:paid_member) {
        member = create(:member_with_membership_app)
        create(:membership_fee_payment,
               :successful,
               user:        member,
               start_date:  jan_1,
               expire_date: User.expire_date_for_start_date(jan_1))
        create(:h_branding_fee_payment,
               :successful,
               user:        member,
               company:     member.companies.first,
               start_date:  jan_1,
               expire_date: User.expire_date_for_start_date(jan_1))
        member
      }

      let(:paid_member_co) { paid_member.companies.first }

      it 'false when the day is in the config list of days to send the alert' do
        expect(subject.send_alert_this_day?(timing, config, paid_member_co)).to be_falsey
      end

      it 'false when the day  is not in the config list of days to send the alert' do
        expect(subject.send_alert_this_day?(timing, { days: [999] }, paid_member_co)).to be_falsey
      end

    end

    context 'h-branding fee is not paid' do

      let(:paid_members_co) { create(:company, name: 'Co with paid members') }

      let(:member_paid_dec_3) {
        member = create(:member_with_membership_app, company_number: paid_members_co.company_number)
        create(:membership_fee_payment,
               :successful,
               user:        member,
               company:     paid_members_co,
               start_date:  dec_3,
               expire_date: User.expire_date_for_start_date(dec_3))
        member
      }

      let(:member_paid_dec_5) {
        member = create(:member_with_membership_app, company_number: paid_members_co.company_number)
        create(:membership_fee_payment,
               :successful,
               user:        member,
               company:     paid_members_co,
               start_date:  dec_5,
               expire_date: User.expire_date_for_start_date(dec_5))
        member
      }

      let(:condition_config) {  { days: [1, 3, 363, 364] } }
      # day 0 for member_paid_dec_3 = 3 Dec 2018
      # day 1 for member_paid_dec_3 = 4 Dec 2018
      # day 3 for member_paid_dec_3 = 6 Dec 2018
      # day 363 for member_paid_dec_3 = 1 Dec 2019
      # day 364 for member_paid_dec_3 = 2 Dec 2019 == the expiration date, so the membership has expired at the end of this day.

      # day 363 for member_paid_dec_5 = 3 Dec 2019
      # day 364 for member_paid_dec_5 = 4 Dec 2019 == the expiration date, so the membership has expired at the end of this day.

      # Hint: you can do this in IRB to figure out dates:
      #   require 'date'
      #   dec_3 = Date.new(2018, 12, 3)
      #   dec_5 = Date.new(2018, 12, 5)
      #   dec_3 + 363
      #    ==> Sun, 01 Dec 2019


      context 'h-branding fee has never been paid' do

        describe 'the h-branding fee due date changes based on current membership' do

          it 'uses the oldest (first paid) membership fee payment of all of current members as day 0 ' do
            paid_members_co
            member_paid_dec_3
            member_paid_dec_5

            Timecop.freeze(Time.utc(2018, 12, 4)) do
              # update membership status based on today's date
              MembershipStatusUpdater.instance.user_updated(member_paid_dec_3)
              MembershipStatusUpdater.instance.user_updated(member_paid_dec_5)

              expect(paid_members_co.current_members).to match_array [member_paid_dec_3, member_paid_dec_5]
              expect(subject.send_alert_this_day?(timing, condition_config, paid_members_co)).to be_truthy
            end

            Timecop.freeze(Time.utc(2018, 12, 6)) do
              # update membership status based on today's date
              MembershipStatusUpdater.instance.user_updated(member_paid_dec_3)
              MembershipStatusUpdater.instance.user_updated(member_paid_dec_5)

              expect(paid_members_co.current_members).to match_array [member_paid_dec_3, member_paid_dec_5]
              expect(subject.send_alert_this_day?(timing, condition_config, paid_members_co)).to be_truthy
            end

            Timecop.freeze(Time.utc(2019, 12, 4)) do
              # update membership status based on today's date
              MembershipStatusUpdater.instance.user_updated(member_paid_dec_3)
              MembershipStatusUpdater.instance.user_updated(member_paid_dec_5)

              expect(paid_members_co.current_members).to be_empty
              expect(subject.send_alert_this_day?(timing, condition_config, paid_members_co)).to be_falsey
            end

          end


          it 'if the member with oldest paid membership lets thier membership expires, day 0 changes' do

            Timecop.freeze(Time.utc(2019, 12, 3)) do
              # update membership status based on today's date
              MembershipStatusUpdater.instance.user_updated(member_paid_dec_3)
              MembershipStatusUpdater.instance.user_updated(member_paid_dec_5)

              expect(paid_members_co.current_members).to match_array [member_paid_dec_5]
              expect(subject.send_alert_this_day?(timing, condition_config, paid_members_co)).to be_truthy
            end

            Timecop.freeze(Time.utc(2019, 12, 4)) do
              # update membership status based on today's date
              MembershipStatusUpdater.instance.user_updated(member_paid_dec_3)
              MembershipStatusUpdater.instance.user_updated(member_paid_dec_5)

              expect(paid_members_co.current_members).to match_array []
              expect(subject.send_alert_this_day?(timing, condition_config, paid_members_co)).to be_falsey
            end
          end

        end # describe 'day 0 for the h-branding fee due date changes based on current membership'


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

          let(:paid_member_co) { paid_member.companies.first }

          it 'true when the day is in the config list of days to send the alert' do
            Timecop.freeze(Time.utc(2018, 1, 16)) do
              expect(subject.send_alert_this_day?(timing, config, paid_member_co)).to be_truthy
            end
          end

          it 'false when the day is not in the config list of days to send the alert' do
            Timecop.freeze(Time.utc(2018, 1, 17)) do
              expect(subject.send_alert_this_day?(timing, config, paid_member_co)).to be_falsey
            end
          end

        end # context 'membership has not expired yet'

        context 'earliest membership expires on or after the given date to check' do

          context 'membership expires 1 day after today (dec 1); expires dec 2' do

            let(:paid_expires_tomorrow_member) {
              shf_accepted_app = create(:shf_application, :accepted)

              member = shf_accepted_app.user

              create(:membership_fee_payment,
                     :successful,
                     user:        member,
                     start_date:  lastyear_dec_3,
                     expire_date: User.expire_date_for_start_date(lastyear_dec_3))
              member
            }

            let(:paid_member_co) { paid_expires_tomorrow_member.companies.first }

            it 'true if the day is in the config list of days to send the alert (= 1)' do
              Timecop.freeze(Time.utc(2017, 12, 4)) do
                expect(paid_expires_tomorrow_member.membership_expire_date).to eq dec_2
                expect(subject.send_alert_this_day?(timing, { days: [1] }, paid_member_co)).to be_truthy
              end
            end

            it 'false if the day is not in the config list of days to send the alert' do
              expect(subject.send_alert_this_day?(timing, { days: [999] }, paid_member_co)).to be_falsey
            end

          end

          context 'membership expires on the given date (dec 1), expired dec 1' do

            let(:paid_expires_today_member) {
              shf_accepted_app = create(:shf_application, :accepted)
              member           = shf_accepted_app.user

              create(:membership_fee_payment,
                     :successful,
                     user:        member,
                     start_date:  lastyear_dec_2,
                     expire_date: User.expire_date_for_start_date(lastyear_dec_2))
              member
            }

            let(:paid_member_co) { paid_expires_today_member.companies.first }

            it 'false even if the day is in the list of days to send it' do
              expect(paid_expires_today_member.membership_expire_date).to eq dec_1
              expect(subject.send_alert_this_day?(timing, { days: [0] }, paid_member_co)).to be_falsey
            end

          end

        end # context 'membership expiration is on or after the given date'

        context 'membership has expired' do

          let(:paid_expired_member) {
            shf_accepted_app = create(:shf_application, :accepted)
            member           = shf_accepted_app.user
            create(:membership_fee_payment,
                   :successful,
                   user:        member,
                   start_date:  lastyear_nov_30,
                   expire_date: User.expire_date_for_start_date(lastyear_nov_30))
            member
          }

          let(:exp_member_co) { paid_expired_member.companies.first }

          it 'false if the day is in the config list of days to send the alert' do
            expect(subject.send_alert_this_day?(timing, config, exp_member_co)).to be_falsey
          end

          it 'false if the day is not in the config list of days to send the alert' do
            expect(subject.send_alert_this_day?(timing, { days: [999] }, exp_member_co)).to be_falsey
          end

        end

        context 'company has no current members: always false' do

          let(:company) { create(:company) }

          it 'false when the day is in the config list of days to send the alert' do
            expect(subject.send_alert_this_day?(timing, config, company)).to be_falsey
          end

          it 'false when the day is not in the config list of days to send the alert' do
            expect(subject.send_alert_this_day?(timing, { days: [999] }, company)).to be_falsey
          end

        end

      end


      context 'h-branding fee has been paid (but is expired)' do

        context 'today is in the list of configuration days' do

          it 'true if (today - last HBrand expire date) is in the config list of alert days ' do
            paid_members_co
            member_paid_dec_5

            Timecop.freeze(lastyear_nov_30) do
              create(:h_branding_fee_payment,
                     :successful,
                     user:        member_paid_dec_5,
                     company:     paid_members_co,
                     start_date:  lastyear_nov_30,
                     expire_date: Company.expire_date_for_start_date(lastyear_nov_30))
            end

            expect(paid_members_co.branding_license?).to be_falsey
            expect(paid_members_co.branding_expire_date).to eq nov_29

            Timecop.freeze(Time.utc(2019, 12, 3)) do
              expect(subject.send_alert_this_day?(timing, { days: [369] }, paid_members_co)).to be_truthy
              expect(subject.send_alert_this_day?(timing, { days: [368] }, paid_members_co)).to be_falsey
            end

          end

          it 'false if (today - last HBrand expire date ) is NOT in the config list of alert days ' do
            paid_members_co
            member_paid_dec_3

            Timecop.freeze(lastyear_nov_30) do
              create(:h_branding_fee_payment,
                     :successful,
                     user:        member_paid_dec_3,
                     company:     paid_members_co,
                     start_date:  lastyear_nov_30,
                     expire_date: Company.expire_date_for_start_date(lastyear_nov_30))
            end

            expect(paid_members_co.branding_license?).to be_falsey

            Timecop.freeze(Time.utc(2019, 12, 15)) do
              expect(subject.send_alert_this_day?(timing, { days: [369] }, paid_members_co)).to be_falsey
            end

          end


        end

      end
    end

  end # describe '.send_alert_this_day?(config, user)'


  it '.mailer_method' do
    expect(subject.mailer_method).to eq :h_branding_fee_past_due
  end


  describe 'delivers emails to all current company members' do

    include_context 'stub email rendering'


    let(:paid_member1) {
      member = create(:member_with_membership_app)
      create(:membership_fee_payment,
             :successful,
             user:        member,
             start_date:  jan_1,
             expire_date: User.expire_date_for_start_date(jan_1))
      member
    }

    let(:paid_member_co) { paid_member1.companies.first }

    let(:paid_member2) {
      member = create(:member_with_membership_app, company_number: paid_member_co.company_number)
      create(:membership_fee_payment,
             :successful,
             user:        member,
             start_date:  jan_1,
             expire_date: User.expire_date_for_start_date(jan_1))
      member
    }


    before(:each) do
      subject.create_alert_logger(mock_log)
    end


    it 'emails sent to all members and logged' do
      paid_member1
      paid_member2
      paid_member_co

      expect(paid_member_co.current_members.size).to eq 2

      expect(mock_log).to receive(:info).with("HBrandingFeeDueAlert email sent to user id: #{paid_member1.id} email: #{paid_member1.email} company id: #{paid_member_co.id} name: #{paid_member_co.name}.")
      expect(mock_log).to receive(:info).with("HBrandingFeeDueAlert email sent to user id: #{paid_member2.id} email: #{paid_member2.email} company id: #{paid_member_co.id} name: #{paid_member_co.name}.")

      Timecop.freeze(jan_1) do
        paid_member_co.current_members.each do | member |
          subject.send_email(paid_member_co, member, mock_log)
        end
      end

      expect(ActionMailer::Base.deliveries.size).to eq 2
      # expect(File.read(logfilepath)).to include("[info] HBrandingFeeDueAlert email sent to user id: #{paid_member1.id} email: #{paid_member1.email} company id: #{paid_member_co.id} name: #{paid_member_co.name}.")
      # expect(File.read(logfilepath)).to include("[info] HBrandingFeeDueAlert email sent to user id: #{paid_member2.id} email: #{paid_member2.email} company id: #{paid_member_co.id} name: #{paid_member_co.name}.")
    end

  end

end
