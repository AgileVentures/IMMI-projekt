require 'rails_helper'
require 'shared_context/users'
require 'shared_context/companies'

# We use the User class to test most instance methods since it includes the PaymentUtility class
# Note that most specs/test also actually check the Company class since it also includes the PaymentUtility class.

RSpec.describe 'PaymentUtility', type: :model do

  # use the User class to test the behavior of PaymentUtility since it is a concern
  let(:described_class) { User }

  let(:membership_fee) { Payment::PAYMENT_TYPE_MEMBER }
  let(:branding_license_fee) { Payment::PAYMENT_TYPE_BRANDING }

  include_context 'create users'
  include_context 'create companies'

  let(:company_for_user_unsuccessful_this_year) { user_unsuccessful_this_year.shf_application.companies.first }


  # ==================================
  #  Today = DECEMBER 1 for EVERY EXAMPLE
  around(:each) do |example|
    Timecop.freeze(dec_1)
    example.run
    Timecop.return
  end


  describe 'most_recent_payment' do

    it 'if no payments, returns nil' do
      expect(user_no_payments.most_recent_payment(membership_fee)).to be_nil
      expect(user_no_payments.most_recent_payment(branding_license_fee)).to be_nil
    end

    it 'most recent is based on created_date' do
      most_recent_membership_payment = user_pays_every_nov30.most_recent_payment(membership_fee)
      expect(most_recent_membership_payment.created_at).to eq(nov_30)
      most_recent_membership_payment = user_pays_every_nov30.most_recent_payment(branding_license_fee)
      expect(most_recent_membership_payment.created_at).to eq(nov_30)
    end

  end


  describe 'latest_expiring_payment' do
    it 'returns nil if there are no payments' do
      expect(build(:user).latest_expiring_payment).to be_nil
    end

    context 'has payments' do
      it 'is the payment with the expiration farthest in the future' do
        member = create(:member_with_expiration_date, expiration_date: Date.new(2018, 6, 24))
        p2020 = create(:membership_fee_payment, expire_date: Date.new(2020, 6,24), user: member)
        create(:membership_fee_payment, expire_date: Date.new(2019, 6,24), user: member)
        expect(member.latest_expiring_payment).to eq p2020
      end
    end
  end


  describe 'payment_start_date' do

    it 'is nil if no payments' do
      expect(user_no_payments.payment_start_date(membership_fee)).to be_nil
      expect(user_no_payments.payment_start_date(branding_license_fee)).to be_nil
    end

    it 'is the start_date (Date) of the most recent payment' do
      most_recent_membership_payment = user_pays_every_nov30.payment_start_date(membership_fee)
      expect(most_recent_membership_payment).to eq(nov_30)
      most_recent_membership_payment = user_pays_every_nov30.payment_start_date(branding_license_fee)
      expect(most_recent_membership_payment).to eq(nov_30)
    end
  end


  describe 'payment_expire_date' do

    it 'is nil if no payments' do
      expect(user_no_payments.payment_expire_date(membership_fee)).to be_nil
      expect(user_no_payments.payment_expire_date(branding_license_fee)).to be_nil
    end

    it 'is the expire_date (Date) of the most recent payment' do
      most_recent_membership_payment = user_pays_every_nov30.payment_expire_date(membership_fee)
      expect(most_recent_membership_payment).to eq(nextyear_nov_29)
      most_recent_membership_payment = user_pays_every_nov30.payment_expire_date(branding_license_fee)
      expect(most_recent_membership_payment).to eq(nextyear_nov_29)
    end
  end


  describe 'payment_notes' do

    it 'is nil if no payments' do
      expect(user_no_payments.payment_notes(membership_fee)).to be_nil
      expect(user_no_payments.payment_notes(branding_license_fee)).to be_nil
    end

    it 'is the notes of the most recent payment' do
      most_recent_membership_payment = user_pays_every_nov30.payment_notes(membership_fee)
      expect(most_recent_membership_payment).to eq('membership starts 2018-11-30, expires 2019-11-29')
      most_recent_membership_payment = user_pays_every_nov30.payment_notes(branding_license_fee)
      expect(most_recent_membership_payment).to eq('branding license starts 2018-11-30, expires 2019-11-29')
    end
  end


  describe 'payment_term_expired?' do

    it 'false if no payments have been made (there was never any term if no payments were made, so there was nothing to expire)' do
      expect(user_no_payments.payment_term_expired?(membership_fee)).to be_falsey
      expect(user_no_payments.payment_term_expired?).to be_falsey
      expect(user_no_payments.payment_term_expired?(branding_license_fee)).to be_falsey
    end

    it 'true if today is after the latest expire time (expire time < today)' do
      expect(user_paid_lastyear_nov_29.payment_term_expired?(membership_fee)).to be_truthy
      expect(user_paid_lastyear_nov_29.payment_term_expired?).to be_truthy
      u_co = user_paid_lastyear_nov_29.companies.first
      expect(u_co.payment_term_expired?(branding_license_fee)).to be_truthy
      expect(u_co.payment_term_expired?).to be_truthy
    end

    it 'true if today = latest expire time' do
      expect(user_paid_only_lastyear_dec_2.payment_term_expired?(membership_fee)).to be_truthy
      expect(user_paid_only_lastyear_dec_2.payment_term_expired?).to be_truthy
      u_co = user_paid_only_lastyear_dec_2.companies.first
      expect(u_co.payment_term_expired?(branding_license_fee)).to be_truthy
      expect(u_co.payment_term_expired?).to be_truthy
    end

    it 'false if today is before (<) latest expire time' do
      expect(user_membership_expires_EOD_feb1.payment_term_expired?(membership_fee)).to be_falsey
      expect(user_membership_expires_EOD_feb1.payment_term_expired?).to be_falsey
      u_co = user_membership_expires_EOD_feb1.companies.first
      expect(u_co.payment_term_expired?(branding_license_fee)).to be_falsey
      expect(u_co.payment_term_expired?).to be_falsey
    end

  end


  describe 'should_pay_now?' do
    # today = dec_1 per the Timecop.freeze in the around(:each) block for this whole RSpec

    it 'always true if no payments have been made (no matter the dates, cutoff, etc.)' do
      expect(user_no_payments.should_pay_now?).to be_truthy
      expect(build(:company).should_pay_now?).to be_truthy
    end

    it 'always true if the term has expired' do
      expect(user_paid_lastyear_nov_29.should_pay_now?).to be_truthy
      u_co = user_paid_lastyear_nov_29.companies.first
      expect(u_co.should_pay_now?).to be_truthy
    end

    describe 'cutoff date for being "too early" = expiration - cutoff days' do
      # today = dec 1
      # today + 60 days = jan 30

      it 'false if today is before the cutoff date' do
        expect(user_membership_expires_EOD_feb1.should_pay_now?).to be_falsey
        u_co = user_membership_expires_EOD_feb1.companies.first
        expect(u_co.should_pay_now?).to be_falsey
      end

      it 'true if today is on the cutoff date' do
        expect(user_membership_expires_EOD_jan30.should_pay_now?).to be_truthy
        u_co = user_membership_expires_EOD_jan30.companies.first
        expect(u_co.should_pay_now?).to be_truthy
      end

      it 'true if today is after the cutoff date' do
        expect(user_membership_expires_EOD_jan29.should_pay_now?).to be_truthy
        u_co = user_membership_expires_EOD_jan29.companies.first
        expect(u_co.should_pay_now?).to be_truthy
      end

      describe 'can give a cutoff duration to add to Today' do
        # today = dec 1
        # today + 1 week = dec 8

        let(:custom_cutoff_duration) { 1.week }

        it 'always true if no payments have been made (no matter the dates, cutoff, etc.)' do
          expect(user_no_payments.should_pay_now?(should_pay_cutoff: custom_cutoff_duration)).to be_truthy
          expect(build(:company).should_pay_now?(should_pay_cutoff: custom_cutoff_duration)).to be_truthy
        end

        it 'always true of the term has expired' do
          expect(user_paid_lastyear_nov_29.should_pay_now?(should_pay_cutoff: custom_cutoff_duration)).to be_truthy
          u_co = user_paid_lastyear_nov_29.companies.first
          expect(u_co.should_pay_now?(should_pay_cutoff: custom_cutoff_duration)).to be_truthy
        end

        it 'false if before the cutoff date' do
          expect(user_membership_expires_EOD_dec9.should_pay_now?(should_pay_cutoff: custom_cutoff_duration)).to be_falsey
          u_co = user_membership_expires_EOD_dec9.companies.first
          expect(u_co.should_pay_now?(should_pay_cutoff: custom_cutoff_duration)).to be_falsey
        end

        it 'true if on the cutoff date' do
          expect(user_membership_expires_EOD_dec8.should_pay_now?(should_pay_cutoff: custom_cutoff_duration)).to be_truthy
          u_co = user_membership_expires_EOD_dec8.companies.first
          expect(u_co.should_pay_now?(should_pay_cutoff: custom_cutoff_duration)).to be_truthy
        end

        it 'true if after the cutoff date' do
          expect(user_membership_expires_EOD_dec7.should_pay_now?(should_pay_cutoff: custom_cutoff_duration)).to be_truthy
          u_co = user_membership_expires_EOD_dec7.companies.first
          expect(u_co.should_pay_now?(should_pay_cutoff: custom_cutoff_duration)).to be_truthy
        end
      end
    end
  end


  # TODO There should be a more sensible way to do this test in relation to should_pay_now?
  describe 'too_early_to_pay? is the opposite of should_pay_now?' do
    # today = dec_1 per the Timecop.freeze in the around(:each) block for this whole RSpec
    # today = dec 1
    # today + 60 days = jan 30

    it 'always false if no payments have been made' do
      expect(user_no_payments.too_early_to_pay?).to eq(!user_no_payments.should_pay_now?)
      co_no_payments = build(:company)
      expect(co_no_payments.too_early_to_pay?).to eq(!co_no_payments.should_pay_now?)
    end

    it 'always false if the term has expired' do
      expect(user_paid_lastyear_nov_29.too_early_to_pay?).to eq !user_paid_lastyear_nov_29.should_pay_now?
      u_co = user_paid_lastyear_nov_29.companies.first
      expect(u_co.too_early_to_pay?).to eq !u_co.should_pay_now?
    end

    describe 'cutoff date for being "too early" = expiration - cutoff days' do
      # today = dec_1 per the Timecop.freeze in the around(:each) block for this whole RSpec
      # today = dec 1
      # today + 60 days = jan 30

      it 'true if today is before the cutoff date' do
        expect(user_membership_expires_EOD_feb1.too_early_to_pay?).to eq !user_membership_expires_EOD_feb1.should_pay_now?
        u_co = user_membership_expires_EOD_feb1.companies.first
        expect(u_co.too_early_to_pay?).to eq !u_co.should_pay_now?
      end

      it 'false if today is on the cutoff date' do
        expect(user_membership_expires_EOD_jan30.too_early_to_pay?).to eq !user_membership_expires_EOD_jan30.should_pay_now?
        u_co = user_membership_expires_EOD_jan30.companies.first
        expect(u_co.too_early_to_pay?).to eq !u_co.should_pay_now?
      end

      it 'false if today is after the cutoff date' do
        expect(user_membership_expires_EOD_jan29.too_early_to_pay?).to eq !user_membership_expires_EOD_jan29.should_pay_now?
        u_co = user_membership_expires_EOD_jan29.companies.first
        expect(u_co.too_early_to_pay?).to eq !u_co.should_pay_now?
      end
    end
  end


  describe 'payment_due_status' do

    it ':past_due if payment_term_expired?' do
      expect(member_expired.payment_due_status).to eq :past_due
      expect(user_paid_only_lastyear_dec_2.payment_due_status(payment_type: membership_fee)).to eq :past_due
      expect(user_paid_only_lastyear_dec_2.payment_due_status).to eq :past_due
      u_co = user_paid_only_lastyear_dec_2.companies.first
      expect(u_co.payment_due_status(payment_type: branding_license_fee)).to eq :past_due
      expect(u_co.payment_due_status).to eq :past_due
    end

    it ':too_early if too_early_to_pay? is true' do
      expect(user_membership_expires_EOD_feb1.payment_due_status).to eq :too_early
      u_co = user_membership_expires_EOD_feb1.companies.first
      expect(u_co.payment_due_status).to eq :too_early
    end

    it ':due_by if it is before the term expiry but after the too early to pay cutoff' do
      expect(user_membership_expires_EOD_jan30.payment_due_status).to eq :due_by
      u_co = user_membership_expires_EOD_jan30.companies.first
      expect(u_co.payment_due_status).to eq :due_by

      expect(user_membership_expires_EOD_jan29.payment_due_status).to eq :due_by
      u_co = user_membership_expires_EOD_jan29.companies.first
      expect(u_co.payment_due_status).to eq :due_by
    end

    it ':due if no successful payments have been made' do
      expect(user_no_payments.payment_due_status(payment_type: membership_fee)).to  eq :due
      expect(user_no_payments.payment_due_status).to  eq :due
      expect(user_no_payments.payment_due_status(payment_type: branding_license_fee)).to  eq :due

    end
  end


  describe 'admin_can_edit_status?' do

    it 'false if no payments' do
      expect(user_no_payments.admin_can_edit_status?).to be_falsey
    end

    it 'false if no successful payments' do
      u_failed_payments_only = create(:member, first_day: nov_29)
      u_failed_payments_only.payments.member_fee.first.update(status: Payment::EXPIRED)

      expect(u_failed_payments_only.admin_can_edit_status?).to be_falsey
    end

    it 'true if there are any successful payments' do
      expect(user_unsuccessful_this_year.admin_can_edit_status?).to be_truthy
    end
  end


  describe '.next_payment_dates returns an Array of [start_date, expire_date] for the next payment for the given entity id' do

    context 'entity not found raises ActiveRecord::RecordNotFound because it signals a problem in the program logic' do
      it 'User (membership fee and branding fee)' do
        expect { described_class.next_payment_dates(100, membership_fee) }.to raise_error(ActiveRecord::RecordNotFound)
        expect { described_class.next_payment_dates(100, branding_license_fee) }.to raise_error(ActiveRecord::RecordNotFound)
      end
      it 'Company (branding fee)' do
        expect { described_class.next_payment_dates(100, branding_license_fee) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end


    context 'entity found' do

      context 'no payments' do

        describe 'start_date = Today, expire_date = expire_date_for_start_date(start_date)' do

          context 'User (membership fee and branding fee)' do
            it 'start date = today, expire date = calculated based on today' do
              expect(User.next_payment_dates(user_no_payments.id, membership_fee)).to eq [dec_1, nextyear_nov_30]
              expect(User.next_payment_dates(user_no_payments.id, branding_license_fee)).to eq [dec_1, nextyear_nov_30]
            end
          end

          context 'Company (branding fee)' do
            it 'start date = today, expire date = calculated based on today' do
              expect(Company.next_payment_dates(company_no_payments.id, branding_license_fee)).to eq [dec_1, nextyear_nov_30]
            end
          end

        end # describe 'start_date = Today, expire_date = expire_date_for_start_date(start_date)'
      end # context 'no payments'


      context 'has payments' do

        context 'User (membership fee and branding fee)' do

          it 'occurs in the past' do
            expect(User.next_payment_dates(user_paid_only_lastyear_dec_2.id, membership_fee)).to eq [dec_1, nextyear_nov_30]
            expect(User.next_payment_dates(user_paid_only_lastyear_dec_2.id, branding_license_fee)).to eq [dec_1, nextyear_nov_30]
          end

          it 'occurs in the future' do
            expect(User.next_payment_dates(user_pays_every_nov30.id, membership_fee)).to eq [nextyear_nov_30.to_date, Date.new(THIS_YEAR + 2, 11, 29)]
            expect(User.next_payment_dates(user_pays_every_nov30.id, branding_license_fee)).to eq [nextyear_nov_30.to_date, Date.new(THIS_YEAR + 2, 11, 29)]
          end
        end

        context 'Company (branding fee)' do
          it 'occurs in the past' do
            expect(User.next_payment_dates(user_paid_only_lastyear_dec_2.id, branding_license_fee)).to eq [dec_1, nextyear_nov_30]
          end

          it 'occurs in the future' do
            expect(User.next_payment_dates(user_pays_every_nov30.id, branding_license_fee)).to eq [nextyear_nov_30, Date.new(THIS_YEAR + 2, 11, 29)]
          end
        end


        describe 'only uses the successful payments' do

          it 'User membership fee and branding fee' do
            expect(User.next_payment_dates(user_unsuccessful_this_year.id, membership_fee)).to eq [dec_1, nextyear_nov_30]
            expect(User.next_payment_dates(user_unsuccessful_this_year.id, branding_license_fee)).to eq [dec_1, nextyear_nov_30]
          end

          it 'Company branding fee' do
            expect(Company.next_payment_dates(company_for_user_unsuccessful_this_year.id, branding_license_fee)).to eq [dec_1, nextyear_nov_30]
          end

        end

        describe 'what if you pass PAYMENT_TYPE_MEMBER for a Company?' do
          pending
        end

      end
    end
  end


  describe '.expire_date_for_start_date' do

    it 'is 1 calendar year minus 1 day' do
      computed = described_class.expire_date_for_start_date(Time.zone.local(THIS_YEAR, 1, 1))
      expect(computed).to eq Time.zone.local(THIS_YEAR, 12, 31)
    end

    it 'leap year' do
      computed = described_class.expire_date_for_start_date(Time.zone.local(THIS_YEAR + 2, 2, 1))
      expect(computed).to eq Time.zone.local(THIS_YEAR + 3, 1, 31)
    end

  end


  describe 'start_date_for_expire_date' do

    it 'is expire date minus 1 year + 1 day' do
      dec_31_2018 = Date.new(2018, 12, 31)
      expect(described_class.start_date_for_expire_date(dec_31_2018)).to eq (dec_31_2018 - 1.year + 1.day)
    end


    it 'handles leap year' do
      expect(described_class.start_date_for_expire_date(Date.new(2021, 2, 28))).to eq (Date.new(2020, 2, 29))
    end
  end


  describe 'other_date_for_given_date' do

    let(:start_2018_1_1) { Date.new(2018, 1, 1) }
    let(:expire_2018_12_31) { Date.new(2018, 12, 31) }

    it 'is_start_date is true by default' do
      expect(described_class.other_date_for_given_date(start_2018_1_1)).to eq described_class.other_date_for_given_date(start_2018_1_1, is_start_date: true)
    end

    it 'given a start date, calc the expiration' do
      expect(described_class.other_date_for_given_date(start_2018_1_1)).to eq expire_2018_12_31
    end

    it 'given an expiration date, calc the start date' do
      expect(described_class.other_date_for_given_date(expire_2018_12_31, is_start_date: false)).to eq start_2018_1_1
    end

    describe 'handles leap years' do

      let(:start_2020_11_1) { Date.new(2020, 11, 1) }
      let(:expire_2021_10_31) { Date.new(2021, 10, 31) }

      it 'given a start date, calc the expiration' do
        expect(described_class.other_date_for_given_date(start_2020_11_1)).to eq expire_2021_10_31
      end

      it 'given an expiration date, calc the start date' do
        expect(described_class.other_date_for_given_date(expire_2021_10_31, is_start_date: false)).to eq start_2020_11_1
      end
    end

  end


  describe 'record_deleted_payorinfo_in_payment_notes' do

    let(:new_u) do
      new_user = build(:user)
      membership_payment = build(:membership_fee_payment)
      hbranding_payment = build(:h_branding_fee_payment)
      allow(new_user).to receive(:payments).and_return([membership_payment, hbranding_payment])
      new_user
    end

    describe 'defaults' do

      let(:first_payment) { new_u.payments.first }

      it 'payor class: class of the payor' do
        expect(first_payment).to receive(:note_payor_deleted).with(new_u.class, anything, anything)
        new_u.record_deleted_payorinfo_in_payment_notes
      end

      it 'email: email for the payor' do
        expect(first_payment).to receive(:note_payor_deleted).with(anything, new_u.email, anything)
        new_u.record_deleted_payorinfo_in_payment_notes
      end

      it 'time_deleted: Time.zone.now' do
        tz_now = Time.zone.now
        Timecop.freeze(tz_now) do
          expect(first_payment).to receive(:note_payor_deleted).with(anything, anything, tz_now)
          new_u.record_deleted_payorinfo_in_payment_notes
        end
      end
    end

    it 'each payment records info in notes about this payor' do
      new_u.payments.each do | payment |
        expect(payment).to receive(:note_payor_deleted)
      end

      new_u.record_deleted_payorinfo_in_payment_notes
    end

  end
end
