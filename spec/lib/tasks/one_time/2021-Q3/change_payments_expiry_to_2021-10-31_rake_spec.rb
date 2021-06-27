require 'rails_helper'
require 'shared_context/rake'

RSpec.describe 'one_time/2021-Q3/change_payments_expiry_to_2021-10-31 shf:one_time:change_payments_expire_date_to_2021_10_31', type: :task do

  include_context 'rake'

  # The rake context should define 'subject' as this rake (Rake.application) task, but it's not.
  #   So we define it explicitly here:
  let(:this_task) { rake['shf:one_time:change_payments_expire_date_to_2021_10_31'] }


  let(:task_name) { 'change_payments_expire_date_to_2021_10_31' }
  let(:new_expire_date) { Date.new(2021,10,31) }
  let(:time_range) { Date.new(2021,1,1)..Date.new(2021,10,30) }

  let(:mock_log) { instance_double("ActivityLogger") }

  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)
  end


  describe 'payments_to_change' do

    it 'gets all completed payments with expire_date 2021-01-01 to 2021-10-30 (inclusive)' do

      membership_fee_expiry_2020_12_31 = create(:membership_fee_payment, expire_date: Date.new(2020, 12, 31))
      membership_fee_expiry_2021_10_31 = create(:membership_fee_payment, expire_date: Date.new(2021, 10, 31))
      membership_fee_pending_2021_01_02 = create(:membership_fee_payment, :pending, expire_date: (Date.new(2021,1,2)))

      membership_fee_2021_01_01 = create(:membership_fee_payment, expire_date: Date.new(2021, 1, 1))
      membership_fee_2021_10_30 = create(:membership_fee_payment, expire_date: Date.new(2021, 10, 30))
      membership_fee_2021_01_02 = create(:membership_fee_payment, expire_date: Date.new(2021, 1, 2))

      h_branding_fee_expiry_2020_12_31 = create(:h_branding_fee_payment, expire_date: Date.new(2020, 12, 31))
      h_branding_fee_expiry_2021_10_31 = create(:h_branding_fee_payment, expire_date: Date.new(2021, 10, 31))
      h_branding_fee_pending_2021_01_02 = create(:h_branding_fee_payment, :pending, expire_date: (Date.new(2021,1,2)))

      h_branding_fee_2021_01_01 = create(:h_branding_fee_payment, expire_date: Date.new(2021, 1, 1))
      h_branding_fee_2021_10_30 = create(:h_branding_fee_payment, expire_date: Date.new(2021, 10, 30))
      h_branding_fee_2021_01_02 = create(:h_branding_fee_payment, expire_date: Date.new(2021, 1, 2))

      results = payments_to_change(time_range)

      expect(results.include?(membership_fee_expiry_2020_12_31)).to be_falsey
      expect(results.include?(membership_fee_expiry_2021_10_31)).to be_falsey
      expect(results.include?(membership_fee_pending_2021_01_02)).to be_falsey

      expect(results.include?(h_branding_fee_expiry_2020_12_31)).to be_falsey
      expect(results.include?(h_branding_fee_expiry_2021_10_31)).to be_falsey
      expect(results.include?(h_branding_fee_pending_2021_01_02)).to be_falsey

      expect(results).to match_array([membership_fee_2021_01_01,
                                      membership_fee_2021_10_30,
                                      membership_fee_2021_01_02,
                                      h_branding_fee_2021_01_01,
                                      h_branding_fee_2021_10_30,
                                      h_branding_fee_2021_01_02])
    end

  end


  describe 'change_payment_expire_day_and_notes' do

    it 'expire_date is updated to the given new 1' do
      membership_fee_expiry_2021_01_01  = create(:membership_fee_payment, expire_date: Date.new(2021, 1, 1))
      changed_payment = change_payment_expire_day_and_notes(membership_fee_expiry_2021_01_01, new_expire_date, task_name)
      expect(changed_payment.expire_date).to eq(new_expire_date)
    end


    it 'notes has info about the expire_date change appended after any existing notes text' do
      original_notes = 'Original note text'
      original_date = Date.new(2021, 1, 1)
      membership_fee_expiry_2021_01_01  = create(:membership_fee_payment, expire_date: original_date,
                                                 notes: original_notes)
      changed_payment = change_payment_expire_day_and_notes(membership_fee_expiry_2021_01_01, new_expire_date, task_name)
      expected_change_msg = "Payment expire_date changed to #{new_expire_date.iso8601}. Original expire_date was #{original_date.iso8601}"
      expect(changed_payment.notes).to match(/#{original_notes} \| Changed by rake task #{task_name} on (.*) : #{expected_change_msg}/)
    end

  end


  describe 'the task selects the payments to change then updates the expire_date and notes' do

    describe 'for each payment processed, it' do

      it 'changes the expire_date and appends info to the notes for each payment processed' do
        only_payment_processed = create(:membership_fee_payment, expire_date: Date.new(2021, 1, 2))
        allow(MembershipStatusUpdater.instance).to receive(:payment_made)

        this_task.invoke
        expect(only_payment_processed.reload.expire_date).to eq(new_expire_date)
        expect(only_payment_processed.reload.notes).to match(/(.*) \| Changed by rake task (.)* Payment expire_date changed to #{new_expire_date.iso8601}. Original expire_date was /)
      end

      it 'calls MembershipStatusUpdater.payment_made (send_email: false) for each payment processed' do
        only_payment_processed = create(:membership_fee_payment, expire_date: Date.new(2021, 1, 2))
        expect(MembershipStatusUpdater.instance).to receive(:payment_made)
                                                      .with(only_payment_processed, send_email: false)
        this_task.invoke
      end
    end
  end
end
