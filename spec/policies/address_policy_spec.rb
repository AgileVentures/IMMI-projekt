require 'rails_helper'
include PoliciesHelper

RSpec.describe AddressPolicy do

  let(:user_1) { create(:user, email: 'user_1@random.com') }
  let(:member) { create(:member_with_membership_app, email: 'member@random.com', company_number: '5562728336')}
  let(:admin)  { create(:user, email: 'admin@sfh.com', admin: true) }
  let(:visitor) { build(:visitor) }
  let(:company) { create(:company, company_number: '5712213304')}

  describe 'For admin' do
    subject { described_class.new(admin, company.addresses.first) }

    it { is_expected.to permit_action :edit }
    it { is_expected.to permit_action :update }
    it { is_expected.to permit_action :new }
    it { is_expected.to permit_action :create }
    it { is_expected.to permit_action :destroy }
  end

  describe 'For a member that is a part of a company' do
    let(:members_company) { Company.find_by_company_number('5562728336') }
    subject { described_class.new(member, members_company.addresses.first) }

    it { is_expected.to permit_action :edit }
    it { is_expected.to permit_action :update }
    it { is_expected.to permit_action :new }
    it { is_expected.to permit_action :create }
    it { is_expected.to permit_action :destroy }
  end

  describe 'For a member that is not part of a company' do
    subject { described_class.new(member, company.addresses.first) }

    it { is_expected.to forbid_action :edit }
    it { is_expected.to forbid_action :update }
    it { is_expected.to forbid_action :new }
    it { is_expected.to forbid_action :create }
    it { is_expected.to forbid_action :destroy }
  end

  describe 'For a user (logged in)' do
    subject { described_class.new(user_1, company.addresses.first) }

    it { is_expected.to forbid_action :edit }
    it { is_expected.to forbid_action :update }
    it { is_expected.to forbid_action :new }
    it { is_expected.to forbid_action :create }
    it { is_expected.to forbid_action :destroy }
  end

  describe 'For a visitor (not logged in)' do
    subject { described_class.new(visitor, company.addresses.first) }

    it { is_expected.to forbid_action :edit }
    it { is_expected.to forbid_action :update }
    it { is_expected.to forbid_action :new }
    it { is_expected.to forbid_action :create }
    it { is_expected.to forbid_action :destroy }
  end
end
