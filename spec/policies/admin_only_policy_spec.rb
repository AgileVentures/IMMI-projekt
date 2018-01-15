require 'rails_helper'

RSpec.describe AdminOnly::AdminOnlyPolicy do

  let(:user_1) { create(:user, email: 'user@random.com') }
  let(:member) { create(:member_with_membership_app, email: 'member@random.com', company_number: '5562728336')}
  let(:admin)  { create(:user, email: 'admin@shf.com', admin: true) }
  let(:visitor) { build(:visitor) }

  let(:simple_record) { create(:business_category) }

  CRUD_ACTIONS = [:index, :show, :new, :create, :edit, :update, :destroy]


  describe 'Admin is permitted everything' do
    subject { described_class.new(admin, simple_record) }

    CRUD_ACTIONS.each do | action |
      it { is_expected.to permit_action action }
    end

  end


  describe 'Member is forbidden everything' do
    subject { described_class.new(member, simple_record) }

    CRUD_ACTIONS.each do | action |
      it { is_expected.to forbid_action action }
    end

  end


  describe 'User (logged in) is forbidden everything' do
    subject { described_class.new(user_1, simple_record) }

    CRUD_ACTIONS.each do | action |
      it { is_expected.to forbid_action action }
    end

  end


  describe 'Visitor (not logged in) is forbidden everything' do
    subject { described_class.new(visitor, simple_record) }

    CRUD_ACTIONS.each do | action |
      it { is_expected.to forbid_action action }
    end

  end


end
