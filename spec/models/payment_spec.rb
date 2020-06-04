require 'rails_helper'

require 'shared_examples/scope_updated_in_date_range'


RSpec.describe Payment, type: :model do

  let(:success) { Payment::ORDER_PAYMENT_STATUS['successful'] }
  let(:created) { Payment::ORDER_PAYMENT_STATUS[nil] }

  let(:member_pymt1) do
    create(:payment, status: success, expire_date: Time.zone.today + 1.day)
  end
  let(:member_pymt2) do
    create(:payment, status: created, expire_date: Time.zone.today + 1.year)
  end
  let(:member_pymt3) do
    create(:payment, status: success, expire_date: Time.zone.today + 1.year)
  end
  let(:member_pymt4) do
    create(:payment, status: success, expire_date: Time.zone.today - 1.day)
  end

  let(:brand_pymt1) do
    create(:payment, status: success, expire_date: Time.zone.today + 1.day,
           payment_type: Payment::PAYMENT_TYPE_BRANDING)
  end
  let(:brand_pymt2) do
    create(:payment, status: created, expire_date: Time.zone.today + 1.year,
           payment_type: Payment::PAYMENT_TYPE_BRANDING)
  end
  let(:brand_pymt3) do
    create(:payment, status: success, expire_date: Time.zone.today + 1.year,
           payment_type: Payment::PAYMENT_TYPE_BRANDING)
  end

  describe 'Factory' do
    it 'has a valid factory' do
      expect(build(:payment)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :user_id }
    it { is_expected.to have_db_column :company_id }
    it { is_expected.to have_db_column :payment_type }
    it { is_expected.to have_db_column :status }
    it { is_expected.to have_db_column :start_date }
    it { is_expected.to have_db_column :expire_date }
    it { is_expected.to have_db_column :notes }
  end

  describe 'Associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:company).optional }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :payment_type }
    it { is_expected.to validate_presence_of :status }
    it { is_expected.to validate_inclusion_of(:status)
                            .in_array(Payment::ORDER_PAYMENT_STATUS.values) }
    it { is_expected.to validate_presence_of :start_date }
    it { is_expected.to validate_presence_of :expire_date }
  end

  describe 'Scopes' do
    describe 'scope: completed' do

      it 'returns all completed payments' do
        expect(Payment.completed).to contain_exactly(member_pymt3, member_pymt1)
      end
    end

    describe 'scope: Payment::PAYMENT_TYPE_MEMBER' do

      it 'returns all member fee payments' do
        expect(Payment.send(Payment::PAYMENT_TYPE_MEMBER))
            .to contain_exactly(member_pymt3, member_pymt2, member_pymt1)
      end
    end

    describe 'scope: Payment::PAYMENT_TYPE_BRANDING' do

      it 'returns all branding fee payments' do
        expect(Payment.send(Payment::PAYMENT_TYPE_BRANDING))
            .to contain_exactly(brand_pymt3, brand_pymt2, brand_pymt1)
      end
    end

    describe 'scope: unexpired' do
      it 'returns all unexpired payments' do
        expect(Payment.unexpired)
            .to contain_exactly(member_pymt1, member_pymt2, member_pymt3,
                                brand_pymt1, brand_pymt2, brand_pymt3)
      end
    end

    describe 'updated_in_date_range(start_date, end_date)' do
      it_behaves_like 'it_has_updated_in_date_range_scope', :payment
    end


    describe '.covering_year' do
      let(:year) { 2020 }

      let(:start_year_01_01) { Time.new(year, 1, 1) }
      let(:payment_starts_year_01_01) do
        create(:payment, status: success,
               start_date: start_year_01_01,
               expire_date: User.expire_date_for_start_date(start_year_01_01))
      end
      let(:payment_expires_year_01_01_minus_1sec) do
        create(:payment, status: success,
               start_date: User.start_date_for_expire_date(start_year_01_01 - 1.second),
               expire_date: (start_year_01_01 - 1.second))
      end
      let(:payment_expires_year_01_01) do
        create(:payment, status: success,
               start_date: User.start_date_for_expire_date(start_year_01_01),
               expire_date: start_year_01_01)
      end


      let(:start_year_06_30) { Time.new(year, 06, 30) }
      let(:payment_starts_year_06_30) do
        create(:payment, status: success,
               start_date: start_year_06_30,
               expire_date: User.expire_date_for_start_date(start_year_06_30))
      end
      let(:payment_expires_year_06_30) do
        create(:payment, status: success,
               start_date: User.start_date_for_expire_date(start_year_06_30),
               expire_date: start_year_06_30)
      end

      let(:start_year_last_second) { DateTime.new(year, 1, 1).end_of_year }
      let(:payment_starts_year_last_second) do
        create(:payment, status: success,
               start_date: start_year_last_second,
               expire_date: User.expire_date_for_start_date(start_year_last_second))
      end
      let(:payment_expires_year_last_second) do
        create(:payment, status: success,
               start_date: User.start_date_for_expire_date(start_year_last_second),
               expire_date: start_year_last_second)
      end

      let(:end_of_year_plus_1_sec) { DateTime.new(year, 1, 1).end_of_year + 1.second }
      let(:payment_starts_at_end_of_year_plus_1_sec) do
        create(:payment, status: success,
               start_date: end_of_year_plus_1_sec,
               expire_date: User.expire_date_for_start_date(end_of_year_plus_1_sec))
      end
      let(:payment_expires_at_end_of_year_plus_1_sec) do
        create(:payment, status: success,
               start_date: User.start_date_for_expire_date(end_of_year_plus_1_sec),
               expire_date: end_of_year_plus_1_sec)
      end

      let(:payment_start_1sec_before_expire_1sec_after) do
        create(:payment, status: success,
               start_date: (DateTime.new(year, 1, 1) - 1.second),
               expire_date: end_of_year_plus_1_sec)
      end

      let(:payment_start_2years_before_expire_2years_after) do
        create(:payment, status: success,
               start_date: (DateTime.new(year - 2, 1, 1) ),
               expire_date: DateTime.new(year + 2, 1, 1) )
      end

      let(:payment_start_2years_before_expire_06_30) do
        create(:payment, status: success,
               start_date: (DateTime.new(year - 2, 1, 1) ),
               expire_date: DateTime.new(year, 06, 30) )
      end


      it 'includes all payments that started in that year' do
        # explicitly create the payments needed for this test
        payment_starts_year_01_01
        payment_starts_year_06_30
        payment_starts_year_last_second
        payment_starts_at_end_of_year_plus_1_sec

        result = described_class.covering_year(year)
        expect(result.count).to eq 3
        expect(result.to_a).to match_array([payment_starts_year_01_01,
                                            payment_starts_year_06_30,
                                            payment_starts_year_last_second])
      end

      it 'includes all payments that expire in that year' do
        # explicitly create the payments needed for this test
        payment_expires_year_01_01
        payment_expires_year_06_30
        payment_expires_year_last_second
        payment_starts_at_end_of_year_plus_1_sec

        result = described_class.covering_year(year)
        expect(result.count).to eq 3
        expect(result.to_a).to match_array([payment_expires_year_01_01,
                                            payment_expires_year_06_30,
                                            payment_expires_year_last_second])
      end

      it 'includes all payments that span that year (multi-year payment)' do
        # start before the year and end after the year
        payment_start_1sec_before_expire_1sec_after

        result = described_class.covering_year(year)
        expect(result.count).to eq 1
        expect(result.to_a).to match_array([payment_start_1sec_before_expire_1sec_after])
      end

      it 'All the distinct payments (OR-ed) that should be included (no duplicates)' do
        # explicitly create the payments needed for this test
        payment_expires_year_01_01_minus_1sec # This should not be in the result
        payment_starts_year_01_01
        payment_starts_year_06_30
        payment_starts_year_last_second
        payment_starts_at_end_of_year_plus_1_sec # this should not be in the result
        payment_expires_year_01_01
        payment_expires_year_06_30
        payment_expires_year_last_second
        payment_expires_at_end_of_year_plus_1_sec
        payment_start_1sec_before_expire_1sec_after
        payment_start_2years_before_expire_2years_after
        payment_start_2years_before_expire_06_30

        result = described_class.covering_year(year)
        expect(result.count).to eq 10
        expect(result.to_a).to match_array([payment_starts_year_01_01,
                                            payment_starts_year_06_30,
                                            payment_starts_year_last_second,
                                            payment_expires_year_01_01,
                                            payment_expires_year_06_30,
                                            payment_expires_year_last_second,
                                            payment_expires_at_end_of_year_plus_1_sec,
                                            payment_start_1sec_before_expire_1sec_after,
                                            payment_start_2years_before_expire_2years_after,
                                            payment_start_2years_before_expire_06_30
                                           ])
      end
    end


  end

  describe '.order_to_payment_status' do
    it "returns payment status 'created' for nil order status" do
      expect(described_class.order_to_payment_status(nil)).to eq 'skapad'
    end

    it "returns payment status 'pending' for 'pending' order status" do
      expect(described_class.order_to_payment_status('pending')).to eq 'avvaktan'
    end

    it "returns payment status 'paid' for 'successful' order status" do
      expect(described_class.order_to_payment_status('successful')).to eq 'betald'
    end

    it "returns payment status 'expired' for 'expired' order status" do
      expect(described_class.order_to_payment_status('expired')).to eq 'utgånget'
    end

    it "returns payment status 'awaiting payments' for 'awaiting_payments' order status" do
      expect(described_class.order_to_payment_status('awaiting_payments'))
          .to eq 'Väntar på betalning'
    end
  end

  describe '#successfully_completed' do

    context 'member fee' do

      it 'status is SUCCESSFUL' do
        expect(member_pymt2.status).to eq Payment::CREATED
        member_pymt2.successfully_completed
        expect(member_pymt2.status).to eq Payment::SUCCESSFUL
      end

      it 'notifies MembershipStatusUpdater (observer)' do
        membership_updater_dbl = double("membership_updater")
        expect(MembershipStatusUpdater).to receive(:instance) { membership_updater_dbl }
        expect(membership_updater_dbl).to receive :payment_made
        member_pymt2.successfully_completed
      end

    end

    context 'branding fee' do

      it 'status is SUCCESSFUL' do
        expect(brand_pymt2.status).to eq Payment::CREATED
        brand_pymt2.successfully_completed
        expect(brand_pymt2.status).to eq Payment::SUCCESSFUL
      end

      it 'notifies MembershipStatusUpdater (observer)' do
        membership_updater_dbl = double("membership_updater")
        expect(MembershipStatusUpdater).to receive(:instance) { membership_updater_dbl }
        expect(membership_updater_dbl).to receive :payment_made
        brand_pymt2.successfully_completed
      end

    end

  end


  describe 'note_payor_deleted' do

    let(:time_pattern) { '\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d UTC' }

    describe "deleted payor info = <payor_type> <payor_email> for this payment was deleted on <deleted_time>" do

      context 'defaults' do

        it 'payor_type: User' do
          expect(subject.notes).to be_nil
          subject.note_payor_deleted
          expect(subject.notes).to match(/^User /)
        end

        it 'payor_email: <email unknown>' do
          expect(subject.notes).to be_nil
          subject.note_payor_deleted
          expect(subject.notes).to match(/^\w+ <email unknown>/)
        end

        it 'deleted_time: Time.zone.now' do
          expect(subject.notes).to be_nil
          tz_now = Time.zone.now
          Timecop.freeze(tz_now) do
            subject.note_payor_deleted
            expect(subject.notes).to match(/#{tz_now}$/)
          end
        end
      end

      it 'record the info passed in' do
        expect(subject.notes).to be_nil
        time_deleted = Time.now.utc
        subject.note_payor_deleted('Some class', 'some-email@example.com', time_deleted)
        expect(subject.notes).to match(/^Some class some-email@example.com for this payment was deleted on #{time_deleted}/)
      end
    end

    context 'notes is nil' do
      it 'notes is now just the deleted payor info' do
        expect(subject.notes).to be_nil
        subject.note_payor_deleted
        expect(subject.notes).to match(/^User <email unknown> for this payment was deleted on #{time_pattern}/)
      end
    end

    context 'notes is not nil' do
      it 'the deleted payor info is appended to the existing notes' do
        orig_notes = 'original notes'
        subject.update(notes: orig_notes)
        expect(subject.notes).to eq orig_notes

        subject.note_payor_deleted
        expect(subject.notes).to match(/^#{orig_notes}; User <email unknown> for this payment was deleted on #{time_pattern}/)
      end

    end
  end
end
