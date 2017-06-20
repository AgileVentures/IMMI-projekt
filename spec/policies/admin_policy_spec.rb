require 'rails_helper'

RSpec.describe AdminPolicy do

  let(:user_1) { create(:user, email: 'user@random.com') }
  let(:member) { create(:member_with_membership_app, email: 'member@random.com', company_number: '5562728336')}
  let(:admin)  { create(:user, email: 'admin@shf.com', admin: true) }
  let(:visitor) { build(:visitor) }

  describe 'For admin' do
    subject { described_class.new(admin).authorized? }

    it { is_expected.to be_truthy }

  end


  describe 'For a member' do
    subject { described_class.new(member).authorized? }

    it { is_expected.to be_falsey }

  end

  describe 'For a user (logged in)' do
    subject { described_class.new(user_1).authorized? }

    it { is_expected.to be_falsey }

  end

  describe 'For a visitor (not logged in)' do
    subject { described_class.new(visitor).authorized? }

    it { is_expected.to be_falsey }

  end
end
