require 'rails_helper'
require 'email_spec/rspec'

require 'shared_examples/shared_conditions'

require 'shared_context/activity_logger'
require 'shared_context/users'

RSpec.describe MembershipStatusCheck, type: :model do

  include_context 'create logger'
  include_context 'create users'

  let(:condition) { build(:condition, timing: Backup::TIMING_EVERY_DAY) }
  let(:today) { Time.now.strftime '%Y-%m-%d' }


  describe '.condition_response' do

    it_behaves_like 'it validates timings in .condition_response', [:every_day] do
      let(:tested_condition) { condition }
    end


    context 'revoke membership if requirements met' do

      before(:each) do
        user
        member_paid_up
        member_expired
      end

      it 'Writes to log file for each revoked membership' do
        described_class.condition_response(condition, log)

        msg = "User #{member_expired.id} (#{member_expired.email}) membership revoked."

        expect(File.read(logfilepath)).to include msg
      end

      it 'Does not write to log file for non-revoked members' do
        described_class.condition_response(condition, log)

        expect(File.read(logfilepath)).not_to include "User #{user.id}"
        expect(File.read(logfilepath)).not_to include "User #{member_paid_up.id}"
      end

    end
  end
end
