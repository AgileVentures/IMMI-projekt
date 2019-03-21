require 'rails_helper'
require 'email_spec/rspec'


RSpec.describe HBrandingFeeWillExpireAlert do

  subject  { described_class.instance }


  let(:jan_1) { Date.new(2018, 1, 1) }

  let(:nov_29) { Date.new(2018, 11, 29) }
  let(:nov_30) { Date.new(2018, 11, 30) }
  let(:dec_1)  { Date.new(2018, 12, 1) }
  let(:dec_2)  { Date.new(2018, 12, 2) }
  let(:dec_3)  { Date.new(2018, 12, 3) }
  let(:dec_5)  { Date.new(2018, 12, 5) }

  let(:nov_30_last_year) { Date.new(2017, 11, 30) }
  let(:dec_2_last_year) { Date.new(2017, 12, 2) }
  let(:dec_3_last_year) { Date.new(2017, 12, 3) }

  let(:user) { create(:user, email: FFaker::InternetSE.disposable_email) }

  let(:company) { create(:company) }


  let(:config) { { days: [1, 7, 15, 30] } }
  let(:timing) { HBrandingFeeWillExpireAlert::TIMING_BEFORE }
  let(:condition) { create(:condition, timing, config) }


  # All examples assume today is 1 December, 2018
  around(:each) do |example|
    Timecop.freeze(dec_1)
    example.run
    Timecop.return
  end


  describe '.send_alert_this_day?(config, user)' do

    context 'h-branding fee has not expired' do

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
               expire_date: Company.expire_date_for_start_date(jan_1))
        member
      }

      let(:paid_member_co) { paid_member.companies.first }

      context 'has current members' do

        it 'true when the day is in the config list of days to send the alert' do

          hbrand_expiry_date = paid_member_co.branding_expire_date
          config[:days].each do | days_before_expiry |

            Timecop.freeze(hbrand_expiry_date - days_before_expiry) do
              expect(subject.send_alert_this_day?(timing, config, paid_member_co)).to be_truthy
            end
          end
        end

        it 'false when the day  is not in the config list of days to send the alert' do
          Timecop.freeze(paid_member_co.branding_expire_date - 999) do
            expect(subject.send_alert_this_day?(timing, config, paid_member_co)).to be_falsey
          end
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


    context 'h-branding fee is not paid - always false' do

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


      context 'h-branding fee has never been paid - always false' do

        it 'false when the day is in the config list of days to send the alert' do
          paid_members_co
          member_paid_dec_3

          expect(paid_members_co.branding_license?).to be_falsey

          Timecop.freeze(Time.utc(2019, 11, 28)) do
            expect(subject.send_alert_this_day?(timing, { days: [1] }, paid_members_co)).to be_falsey
          end

        end

        it 'false when the day  is not in the config list of days to send the alert' do
          paid_members_co
          member_paid_dec_3

          expect(subject.send_alert_this_day?(timing, { days: [999] }, paid_members_co)).to be_falsey
        end

      end


      context 'h-branding fee has been paid but is expired' do

        let(:hbrandpay_nov_30_last_year) do

          Timecop.freeze(nov_30_last_year) do
            create(:h_branding_fee_payment,
                   :successful,
                   user:        member_paid_dec_3,
                   company:     paid_members_co,
                   start_date:  nov_30_last_year,
                   expire_date: Company.expire_date_for_start_date(nov_30_last_year))
          end
        end


        it 'false when the day is in the config list of days to send the alert' do

          paid_members_co
          member_paid_dec_3
          hbrandpay_nov_30_last_year

          expect(paid_members_co.branding_expire_date).to eq nov_29

          expect(paid_members_co.branding_license?).to be_falsey

          Timecop.freeze(Time.utc(2019, 11, 28)) do
            expect(subject.send_alert_this_day?(timing, { days: [1] }, paid_members_co)).to be_falsey
          end

        end

        it 'false when the day  is not in the config list of days to send the alert' do
          paid_members_co
          member_paid_dec_3
          hbrandpay_nov_30_last_year

          expect(subject.send_alert_this_day?(timing, { days: [999] }, paid_members_co)).to be_falsey
        end
      end
    end

  end # describe '.send_alert_this_day?(config, user)'


  it '.mailer_method' do
    expect(subject.mailer_method).to eq :h_branding_fee_will_expire
  end


  describe 'delivers emails to all current company members' do

    LOG_DIR      = 'tmp'
    LOG_FILENAME = 'testlog.txt'

    after(:all) do
      tmpfile = File.join(Rails.root, LOG_DIR, LOG_FILENAME)
      File.delete(tmpfile) if File.exist?(tmpfile)
    end

    let(:filepath) { File.join(Rails.root, LOG_DIR, LOG_FILENAME) }
    let(:log) { ActivityLogger.open(filepath, 'TEST', 'open', false) }

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


    it 'emails sent to all members and logged' do
      paid_member1
      paid_member2
      paid_member_co

      expect(paid_member_co.current_members.size).to eq 2

      Timecop.freeze(jan_1) do
        subject.send_email(paid_member_co, log)
      end

      expect(ActionMailer::Base.deliveries.size).to eq 2
      expect(File.read(filepath)).to include("[info] HBrandingFeeWillExpireAlert email sent to user id: #{paid_member1.id} email: #{paid_member1.email} company id: #{paid_member_co.id} name: #{paid_member_co.name}.")
      expect(File.read(filepath)).to include("[info] HBrandingFeeWillExpireAlert email sent to user id: #{paid_member2.id} email: #{paid_member2.email} company id: #{paid_member_co.id} name: #{paid_member_co.name}.")
    end

  end

end
