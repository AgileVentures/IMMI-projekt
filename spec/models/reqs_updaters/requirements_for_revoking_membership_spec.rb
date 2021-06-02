require 'rails_helper'

RSpec.describe RequirementsForRevokingMembership, type: :model do

  let(:subject) { RequirementsForRevokingMembership }


  describe '.has_expected_arguments?' do

    it 'args has expected :user key' do
      expect(subject.has_expected_arguments?({ user: 'some user' })).to be_truthy
    end

    it 'args does not have expected :user key' do
      expect(subject.has_expected_arguments?({ not_user: 'not some user' })).to be_falsey
    end

    it 'args is nil' do
      expect(subject.has_expected_arguments?(nil)).to be_falsey
    end
  end


  describe '.requirements_met?' do
    let(:yesterday) { Date.current - 1.day }

    context 'user.member? is true' do
      let(:member) { build(:user) }
      before(:each) { allow(member).to receive(:member?).and_return(true) }

      it 'false if member is in good standing (cannot revoke if the member is in good standing)' do
        allow(member).to receive(:member_in_good_standing?).and_return(true)

        expect(subject.requirements_met?({user: member})).to be_falsey
      end

      it 'true if not a member in good standing (should revoke if not in good standing)' do
        allow(member).to receive(:member_in_good_standing?).and_return(false)

        expect(subject.requirements_met?({user: member})).to be_truthy
      end

      it 'uses the given date if there is one' do
        expect(member).to receive(:member_in_good_standing?).with(yesterday)
        subject.requirements_met?({user: member, date: yesterday})
      end
    end


    it 'false if user.member? == false (must be a member in order to revoke membership)' do
      not_a_member = build(:user)
      allow(not_a_member).to receive(:member?).and_return(false)
      expect(subject.requirements_met?({user: not_a_member})).to be_falsey
    end
  end
end
