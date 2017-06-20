require 'rails_helper'

RSpec.describe PagePolicy do

  let(:user_1) { create(:user, email: 'user_1@random.com') }
  let(:member) { create(:member_with_membership_app, email: 'member@random.com')}
  let(:admin)  { create(:user, email: 'admin@sfh.com', admin: true) }
  let(:visitor) { build(:visitor) }
  let (:page) {}

  describe 'For admin' do
    subject { described_class.new(admin, page) }

    it { is_expected.to permit_action :index }
    it { is_expected.to permit_action :show }
    it { is_expected.to permit_action :edit }
    it { is_expected.to permit_action :update }
    it { is_expected.to permit_action :destroy }
    it { is_expected.to permit_action :new }
    it { is_expected.to permit_action :create }
  end

  describe 'For a member' do
    subject { described_class.new(member, page) }

    it { is_expected.to permit_action :index }
    it { is_expected.to permit_action :show }
    it { is_expected.to forbid_action :edit }
    it { is_expected.to forbid_action :update }
    it { is_expected.to forbid_action :destroy }
    it { is_expected.to forbid_action :new }
    it { is_expected.to forbid_action :create }
  end

  describe 'For a user (logged in)' do
    subject { described_class.new(user_1, page) }

    it { is_expected.to forbid_action :index }
    it { is_expected.to forbid_action :show }
    it { is_expected.to forbid_action :edit }
    it { is_expected.to forbid_action :update }
    it { is_expected.to forbid_action :destroy }
    it { is_expected.to forbid_action :new }
    it { is_expected.to forbid_action :create }
  end

  describe 'For a visitor (not logged in)' do
    subject { described_class.new(visitor, page) }

    it { is_expected.to forbid_action :index }
    it { is_expected.to forbid_action :show }
    it { is_expected.to forbid_action :edit }
    it { is_expected.to forbid_action :update }
    it { is_expected.to forbid_action :destroy }
    it { is_expected.to forbid_action :new }
    it { is_expected.to forbid_action :create }
  end
end
