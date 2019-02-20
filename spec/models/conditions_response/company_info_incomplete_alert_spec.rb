require 'rails_helper'
require 'email_spec/rspec'


RSpec.describe CompanyInfoIncompleteAlert do

  subject  { described_class.instance }

  let(:nov_2_last_year)  { Date.new(2017, 11, 2) }
  let(:nov_28_last_year)  { Date.new(2017, 11, 28) }

  let(:nov_1)  { Date.new(2018, 11, 1) }
  let(:nov_29)  { Date.new(2018, 11, 29) }

  let(:dec_1)  { Date.new(2018, 12, 1) }
  let(:dec_2)  { Date.new(2018, 12, 2) }
  let(:dec_5)  { Date.new(2018, 12, 5) }
  let(:dec_8)  { Date.new(2018, 12, 8) }
  let(:dec_31)  { Date.new(2018, 12, 31) }

  let(:user) { create(:user, email: FFaker::InternetSE.disposable_email) }

  let(:config) { { days: [1, 7, 30] } }
  let(:timing) { CompanyInfoIncompleteAlert::TIMING_AFTER }
  let(:condition) { create(:condition, timing, config) }


  describe '.send_alert_this_day?(config, user)' do

    context 'false if the company info is complete' do

      it 'false when the day is in the config list of days to send the alert' do
        complete_company = Timecop.freeze(dec_1) do
          create(:company, region: create(:region))
        end

        alert_days = [dec_2, dec_8, dec_31]
        alert_days.each do | alert_day |
          Timecop.freeze(alert_day) do
            expect(subject.send_alert_this_day?(timing, config, complete_company)).to be_falsey
          end
        end
      end

      it 'false when the day is NOT in the config list of days to send the alert' do

        complete_company = Timecop.freeze(dec_1) do
          create(:company, region: create(:region))
        end

        Timecop.freeze(dec_2) do
          expect(subject.send_alert_this_day?(timing, { days: [999] }, complete_company)).to be_falsey
        end
      end
    end


    context 'the company info is incomplete' do


      let(:incomplete_company_dec1) do
        Timecop.freeze(dec_1) do
          create(:company, name: '')
        end
      end


      context 'company has current members' do

        let(:member1_paid_dec1) {
          dec_1_member = Timecop.freeze(dec_1) do
            member = create(:member_with_membership_app)
            create(:membership_fee_payment,
                   :successful,
                   user:        member,
                   start_date:  dec_2,
                   expire_date: User.expire_date_for_start_date(dec_2))
            member
          end
          dec_1_member
        }

        let(:incomplete_co) do
          co = member1_paid_dec1.shf_application.companies.first
          co.name = ''
          co
        end

        let(:member2_paid_dec2) {
          member = create(:member_with_membership_app, company_number: incomplete_co.company_number)
          create(:membership_fee_payment,
                 :successful,
                 user:        member,
                 start_date:  dec_1,
                 expire_date: User.expire_date_for_start_date(dec_1))
          member
        }


        it 'true when the day is in the config list of days to send the alert' do
          member1_paid_dec1
          incomplete_co
          member2_paid_dec2
          alert_days = [dec_2, dec_8, dec_31]
          alert_days.each do | alert_day |
            Timecop.freeze(alert_day) do
              expect(subject.send_alert_this_day?(timing, config, incomplete_co)).to be_truthy
            end
          end
        end

        it 'false when the day is NOT in the config list of days to send the alert' do
          member1_paid_dec1
          incomplete_co
          member2_paid_dec2
          Timecop.freeze(dec_2) do
            expect(subject.send_alert_this_day?(timing, { days: [999] }, incomplete_co)).to be_falsey
          end
        end

      end

      context 'company does not have current members' do

        context 'no members: false' do

          it 'false when the day is in the config list of days to send the alert' do

            alert_days = [dec_2, dec_8, dec_31]
            alert_days.each do | alert_day |
              Timecop.freeze(alert_day) do
                expect(subject.send_alert_this_day?(timing, config, incomplete_company_dec1)).to be_falsey
              end
            end
          end

          it 'false when the day is NOT in the config list of days to send the alert' do
            Timecop.freeze(dec_2) do
              expect(subject.send_alert_this_day?(timing, { days: [999] }, incomplete_company_dec1)).to be_falsey
            end
          end
        end


        context 'all memberships have expired: false' do

          let(:member1_exp_nov1) {
            dec_1_member = Timecop.freeze(dec_1) do
              member = create(:member_with_membership_app)
              create(:membership_fee_payment,
                     :successful,
                     user:        member,
                     start_date:  nov_2_last_year,
                     expire_date: User.expire_date_for_start_date(nov_2_last_year))
              member
            end
            dec_1_member
          }

          let(:incomplete_co) do
            co = member1_exp_nov1.shf_application.companies.first
            co.name = ''
            co
          end

          let(:member2_exp_nov29) {
            member = create(:member_with_membership_app, company_number: incomplete_co.company_number)
            create(:membership_fee_payment,
                   :successful,
                   user:        member,
                   start_date:  nov_28_last_year,
                   expire_date: User.expire_date_for_start_date(nov_28_last_year))
            member
          }

          it 'false when the day is in the config list of days to send the alert' do
            member1_exp_nov1
            incomplete_co
            member2_exp_nov29
            expect(incomplete_co.current_members).to be_empty

            alert_days = [dec_2, dec_8, dec_31]
            alert_days.each do | alert_day |
              Timecop.freeze(alert_day) do
                expect(subject.send_alert_this_day?(timing, config, incomplete_company_dec1)).to be_falsey
              end
            end
          end

          it 'false when the day is NOT in the config list of days to send the alert' do
            Timecop.freeze(dec_2) do
              expect(subject.send_alert_this_day?(timing, { days: [999] }, incomplete_company_dec1)).to be_falsey
            end
          end

        end
      end


    end

  end # describe '.send_alert_this_day?(config, user)'


  it '.mailer_method' do
    expect(subject.mailer_method).to eq :company_info_incomplete
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
             start_date:  dec_2,
             expire_date: User.expire_date_for_start_date(dec_2))
      member
    }

    let(:incomplete_co) do
      co = paid_member1.shf_application.companies.first
      co.name = ''
      co
    end

    let(:paid_member2) {
      member = create(:member_with_membership_app, company_number: incomplete_co.company_number)
      create(:membership_fee_payment,
             :successful,
             user:        member,
             start_date:  dec_2,
             expire_date: User.expire_date_for_start_date(dec_2))
      member
    }


    it 'emails sent to all members and logged' do
      paid_member1
      incomplete_co
      paid_member2

      expect(incomplete_co.current_members.size).to eq 2

      Timecop.freeze(dec_31) do
        subject.send_email(incomplete_co, log)
      end

      expect(ActionMailer::Base.deliveries.size).to eq 2
      expect(File.read(filepath)).to include("[info] CompanyInfoIncompleteAlert email sent to user id: #{paid_member1.id} email: #{paid_member1.email} company id: #{incomplete_co.id} name: #{incomplete_co.name}.")
      expect(File.read(filepath)).to include("[info] CompanyInfoIncompleteAlert email sent to user id: #{paid_member2.id} email: #{paid_member2.email} company id: #{incomplete_co.id} name: #{incomplete_co.name}.")
    end

  end

end
