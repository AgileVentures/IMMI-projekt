require 'rails_helper'

RSpec.describe AdminPolicy do

  let(:user_1) { create(:user, email: 'user@random.com') }
  let(:member) { create(:member_with_membership_app, email: 'member@random.com', company_number: '5562728336')}
  let(:admin)  { create(:user, email: 'admin@shf.com', admin: true) }

  describe 'For admin' do
    subject { described_class.new(admin).authorized? }

    it { is_expected.to be_truthy }

  end

  describe 'For a member that is a part of a company' do
    let(:members_company) { Company.find_by_company_number('5562728336')}
    subject { described_class.new(admin).authorized? }

    it { is_expected.to be_truthy }

  end

  describe 'For a member that is not part of a company' do
    subject { described_class.new(admin).authorized? }

    it { is_expected.to be_truthy }

  end

  describe 'For a user (logged in)' do
    subject { described_class.new(admin).authorized? }

    it { is_expected.to be_truthy }

  end

  describe 'For a visitor (not logged in)' do
    subject { described_class.new(admin).authorized? }

    it { is_expected.to be_truthy }

  end
end
