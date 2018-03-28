require 'rails_helper'

RSpec.describe AdminOnly::AppConfigurationPolicy do

  let(:user_1) { create(:user, email: 'user@random.com') }
  let(:member) { create(:member_with_membership_app, email: 'member@random.com', company_number: '5562728336')}
  let(:admin)  { create(:user, email: 'admin@shf.com', admin: true) }
  let(:visitor) { build(:visitor) }

  describe 'Admin is permitted everything' do

    subject { described_class.new(admin, nil) }

    it { is_expected.to permit_action :edit }
    it { is_expected.to permit_action :update }
  end


  describe 'Member is forbidden everything' do
    subject { described_class.new(member, nil) }

    it { is_expected.to forbid_action :edit }
    it { is_expected.to forbid_action :update }
  end


  describe 'User (logged in) is forbidden everything' do
    subject { described_class.new(user_1, nil) }

    it { is_expected.to forbid_action :edit }
    it { is_expected.to forbid_action :update }
  end

  describe 'Visitor (not logged in) is forbidden everything' do
    subject { described_class.new(visitor, nil) }

    it { is_expected.to forbid_action :edit }
    it { is_expected.to forbid_action :update }
  end


end
