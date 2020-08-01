require 'rails_helper'
require 'email_spec/rspec'

require 'shared_examples/shared_conditions'

require 'shared_context/users'

RSpec.describe MembershipStatusCheck, type: :model do

  include_context 'create users'

  let(:condition) { build(:condition, timing: Backup::TIMING_EVERY_DAY) }
  let(:today) { Time.now.strftime '%Y-%m-%d' }

  let(:mock_log) { instance_double("ActivityLogger") }
  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)
  end


  describe '.condition_response' do

    it_behaves_like 'it validates timings in .condition_response', [:every_day] do
      let(:tested_condition) { condition }
    end

    it 'calls the status_updater for each user to revoke the membership if needed' do
      mock_status_updater = instance_double("MembershipStatusUpdater")
      allow(mock_status_updater).to receive(:payment_made)
      allow(MembershipStatusUpdater).to receive(:instance).and_return(mock_status_updater)

      # instantiate these (from the shared-context/users file)
      user
      member_paid_up
      member_expired

      expect(mock_status_updater).to receive(:revoke_user_membership).with(member_expired)
      expect(mock_status_updater).to receive(:revoke_user_membership).with(member_paid_up)

      described_class.condition_response(condition, mock_log)
    end

    it 'Log each revoked membership, but not for non-revoked' do
      status_updater = instance_double("MembershipStatusUpdater")
      allow(status_updater).to receive(:revoke_user_membership)

      # instantiate these (from the shared-context/users file)
        user
        member_paid_up
        member_expired

      expect(mock_log).to receive(:info).with("User #{member_expired.id} (#{member_expired.email}) membership revoked.")
      expect(mock_log).not_to receive(:info).with(/User #{user.id}/)
      expect(mock_log).not_to receive(:info).with(/User #{member_paid_up.id}/)

      described_class.condition_response(condition, mock_log)
      end

    end
  end
