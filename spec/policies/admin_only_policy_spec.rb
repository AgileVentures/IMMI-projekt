require 'rails_helper'

RSpec.describe AdminOnly::AdminOnlyPolicy do

  let(:user_1) { create(:user, email: 'user@random.com') }
  let(:member) { create(:member_with_membership_app, email: 'member@random.com', company_number: '5562728336')}
  let(:admin)  { create(:user, email: 'admin@shf.com', admin: true) }
  let(:visitor) { build(:visitor) }

  let(:simple_record) { create(:business_category) }

  describe 'Admin is permitted everything' do

    subject { described_class.new(admin, simple_record) }

    it { is_expected.to permit_action :index }
    it { is_expected.to permit_action :show }
    it { is_expected.to permit_action :edit }
    it { is_expected.to permit_action :update }
    it { is_expected.to permit_action :destroy }
    it { is_expected.to permit_action :new }
    it { is_expected.to permit_action :create }

  end


  describe 'Member is forbidden everything' do
    subject { described_class.new(member, simple_record) }

    it { is_expected.to forbid_action :index }
    it { is_expected.to forbid_action :show }
    it { is_expected.to forbid_action :edit }
    it { is_expected.to forbid_action :update }
    it { is_expected.to forbid_action :destroy }
    it { is_expected.to forbid_action :new }
    it { is_expected.to forbid_action :create }

  end


  describe 'User (logged in) is forbidden everything' do
    subject { described_class.new(user_1, simple_record) }

    it { is_expected.to forbid_action :index }
    it { is_expected.to forbid_action :show }
    it { is_expected.to forbid_action :edit }
    it { is_expected.to forbid_action :update }
    it { is_expected.to forbid_action :destroy }
    it { is_expected.to forbid_action :new }
    it { is_expected.to forbid_action :create }


  end

  describe 'Visitor (not logged in) is forbidden everything' do
    subject { described_class.new(visitor, simple_record) }

    it { is_expected.to forbid_action :index }
    it { is_expected.to forbid_action :show }
    it { is_expected.to forbid_action :edit }
    it { is_expected.to forbid_action :update }
    it { is_expected.to forbid_action :destroy }
    it { is_expected.to forbid_action :new }
    it { is_expected.to forbid_action :create }

  end


end
