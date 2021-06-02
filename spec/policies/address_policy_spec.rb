require 'rails_helper'
include PoliciesHelper

RSpec.describe AddressPolicy do

  let(:user_1) { create(:user, email: 'user_1@random.com') }
  let(:member) do
    memb = create(:member_with_membership_app, email: 'member@random.com')
    allow(memb).to receive(:member_in_good_standing?).and_return(true)
    memb
  end
  let(:member_wo_cmpy) do
    memb = create(:user, member: true)
    allow(memb).to receive(:member_in_good_standing?).and_return(true)
    memb
  end
  let(:admin)  { create(:user, email: 'admin@sfh.com', admin: true) }
  let(:visitor) { build(:visitor) }
  let(:company) { create(:company) }

  describe 'For admin' do
    subject { described_class.new(admin, company.addresses.first) }

    it { is_expected.to permit_action :edit }
    it { is_expected.to permit_action :update }
    it { is_expected.to permit_action :new }
    it { is_expected.to permit_action :create }
    it { is_expected.to permit_action :destroy }
  end

  describe 'For a member that is a part of a company' do
    let(:members_company) do
      co_number = member.shf_application.companies.first.company_number
      Company.find_by_company_number(co_number)
    end
    subject { described_class.new(member, members_company.addresses.first) }

    it { is_expected.to permit_action :edit }
    it { is_expected.to permit_action :update }
    it { is_expected.to permit_action :new }
    it { is_expected.to permit_action :create }
    it { is_expected.to permit_action :destroy }
  end

  describe 'For a member that is not part of a company' do
    subject { described_class.new(member_wo_cmpy, company.addresses.first) }

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
