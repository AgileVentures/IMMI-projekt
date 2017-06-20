require 'rails_helper'

RSpec.describe BusinessCategoryPolicy do

  let(:user_1) { create(:user, email: 'user_1@random.com') }
  let(:admin) { create(:user, email: 'admin@sgf.com', admin: true) }
  let(:visitor) { build(:visitor) }
  let(:category) { create(:business_category) }

  describe 'For admin' do
    subject { described_class.new(admin, category) }

    it { is_expected.to permit_action :index }
    it { is_expected.to permit_action :show }
    it { is_expected.to permit_action :edit }
    it { is_expected.to permit_action :update }
    it { is_expected.to permit_action :destroy }
    it { is_expected.to permit_action :new }
    it { is_expected.to permit_action :create }
  end

  describe 'For a user (logged in)' do
    subject { described_class.new(user_1, category) }

    it { is_expected.to forbid_action :index }
    it { is_expected.to permit_action :show }
    it { is_expected.to forbid_action :edit }
    it { is_expected.to forbid_action :update }
    it { is_expected.to forbid_action :destroy }
    it { is_expected.to forbid_action :new }
    it { is_expected.to forbid_action :create }
  end

  describe 'For a visitor (not logged in)' do
    subject { described_class.new(visitor, category) }

    it { is_expected.to forbid_action :index }
    it { is_expected.to permit_action :show }
    it { is_expected.to forbid_action :edit }
    it { is_expected.to forbid_action :update }
    it { is_expected.to forbid_action :destroy }
    it { is_expected.to forbid_action :new }
    it { is_expected.to forbid_action :create }
  end
end
