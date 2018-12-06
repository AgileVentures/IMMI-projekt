require 'rails_helper'
require 'email_spec/rspec'

RSpec.describe MembershipExpireAlert, type: :model do
  let(:user) { create(:user) }
  let(:membership_will_expire_condition) do
    create(:condition, class_name: 'MembershipExpireAlert',
                       name: 'membership_will_expire',
                       timing: 'before',
                       config: { days: [10, 5, 2] })
  end

  let(:payment_date_2018_11_21) { Time.zone.local(2018, 11, 21) }
  let(:success) { Payment.order_to_payment_status('successful') }

  let(:member_payment1) do
    start_date, expire_date = User.next_membership_payment_dates(user.id)
    create(:payment, user: user, status: success,
           payment_type: Payment::PAYMENT_TYPE_MEMBER,
           notes: 'these are notes for member payment1',
           start_date: start_date,
           expire_date: expire_date)
  end
  let(:filepath) { File.join(Rails.root, 'tmp', 'testfile') }
  let(:log)      { ActivityLogger.open(filepath, 'TEST', 'open', false) }

  describe '.condition_response' do

    before(:each) do
      member_payment1.update_attribute(:expire_date, payment_date_2018_11_21)

      File.delete(filepath) if File.file?(filepath)
    end

    after(:all) do
      File.delete(File.join(Rails.root, 'tmp', 'testfile'))
    end

    context 'membership_will_expire' do

      it 'sends alert email to user and logs a message' do

        user.update_attribute(:email, FFaker::InternetSE.disposable_email)

        expect(MemberMailer).to receive(:membership_expiration_reminder).with(user)
          .exactly(membership_will_expire_condition.config[:days].length).times

        membership_will_expire_condition.config[:days].each do |days_until|

          Timecop.freeze(payment_date_2018_11_21 - days_until.days)

          MembershipExpireAlert.condition_response(membership_will_expire_condition, log)

          Timecop.return

          expect(File.read(filepath)).to include "[info] Expire alert sent to #{user.email}"
        end
      end

      it 'does not send email if days-before does not include today' do

        expect(MemberMailer).not_to receive(:membership_expiration_reminder)

        days_ago = membership_will_expire_condition.config[:days].max + 1

        Timecop.freeze(payment_date_2018_11_21 - days_ago.days)

        MembershipExpireAlert.condition_response(membership_will_expire_condition, log)

        Timecop.return

        expect(File.read(filepath)).not_to include "[info] Expire alert sent to #{user.email}"
      end
    end
  end
end
