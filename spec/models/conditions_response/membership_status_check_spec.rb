require 'rails_helper'
require 'email_spec/rspec'

require 'shared_examples/shared_conditions'

RSpec.describe MembershipStatusCheck, type: :model do
  let(:condition) { build(:condition, timing: Backup::TIMING_EVERY_DAY) }
  let(:mock_log) { instance_double("ActivityLogger") }
  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
  end

  describe '.condition_response' do

    it_behaves_like 'it validates timings in .condition_response', [:every_day] do
      let(:tested_condition) { condition }
    end

    context 'condition timing is valid' do
      before(:each) { allow(described_class).to receive(:confirm_correct_timing).and_return(true) }

      let(:admin1) { build(:admin) }
      let(:admin2) { build(:admin) }
      let(:member1) { build(:user) }
      let(:member2) { build(:user) }
      let(:user1) { build(:user) }

      it 'gets all the current members' do
        expect(User).to receive(:current_member).and_return([])
        described_class.condition_response(condition, mock_log)
      end

      it 'calls update_membership_status for each current member that is not an admin' do
        allow(User).to receive(:current_member).and_return([user1, member1, member2])

        expect(MembershipStatusUpdater.instance).to receive(:update_membership_status)
                                                      .with(user1)
        expect(MembershipStatusUpdater.instance).to receive(:update_membership_status)
                                                      .with(member1)
        expect(MembershipStatusUpdater.instance).to receive(:update_membership_status)
                                                      .with(member2)
        described_class.condition_response(condition, mock_log)
      end

      it 'does not call update_membership_status if the user is an admin' do
        allow(User).to receive(:current_member).and_return([user1, admin1, admin2])

        expect(MembershipStatusUpdater.instance).to receive(:update_membership_status)
                                                      .with(user1)
        described_class.condition_response(condition, mock_log)
      end
    end
  end
end
