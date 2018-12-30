require 'rails_helper'

RSpec.describe RequirementsForRevokingMembership, type: :model do

  let(:subject) { RequirementsForRevokingMembership }


  let(:user) { create(:user) }

  let(:member) { create(:member_with_membership_app) }


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

    it 'user.member? == true' do
      expect(subject.requirements_met?({user: member})).to be_truthy
    end

    it 'user.member? == false' do
      expect(subject.requirements_met?({user: user})).to be_falsey
    end

  end


  describe '.satisfied?' do

    it '.has_expected_arguments? is true and requirements_met? is true' do
      expect(subject.satisfied?({ user: member })).to be_truthy
    end

    it '.has_expected_arguments? is true and requirements_met? is false' do
      expect(subject.satisfied?({ user: user })).to be_falsey
    end

    it '.has_expected_arguments? is false and requirements_met? is true' do
      expect(subject.satisfied?({ not_user: member })).to be_falsey
    end

    it '.has_expected_arguments? is false and requirements_met? is false' do
      expect(subject.satisfied?({ not_user: user })).to be_falsey
    end

  end

end
