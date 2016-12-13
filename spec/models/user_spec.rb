require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:user)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :email }
    it { is_expected.to have_db_column :admin }
    it { is_expected.to have_db_column :is_member }
  end

  describe 'Associations' do
    it { is_expected.to have_many :membership_applications }
  end

  describe 'Admin' do
    subject { create(:user, admin: true) }

    it { is_expected.to be_admin }
  end

  describe 'User' do
    subject { create(:user, admin: false) }

    it { is_expected.not_to be_admin }
    it { expect(subject.is_member).to be_falsey }
  end


  describe '#has_membership_application?' do

    describe 'user: no application' do
      subject { create(:user, is_member: false) }
      it { expect(subject.has_membership_application?).to be_falsey }
    end

    describe 'user: 1 saved application' do
      subject { create(:user_with_membership_app) }
      it { expect(subject.has_membership_application?).to be_truthy }
    end

    describe 'user: 1 not yet saved application' do
      let(:user_with_app) { build(:user_with_membership_app) }
      it { expect(subject.has_company?).to be_falsey }
    end

    describe 'member with 1 app' do
      let(:member) { create(:member_with_membership_app) }
      let(:member_app) { create(:membership_application, user: user_with_app) }
      it { expect(member.has_membership_application?).to be_truthy }
    end

    describe 'member with 0 app (should not happen)' do
      let(:member) { create(:user, is_member: true) }
      it { expect(member.has_membership_application?).to be_falsey }
    end

    describe 'admin' do
      subject { create(:user, admin: true) }
      it { expect(subject.has_membership_application?).to be_falsey }
    end

  end

  describe '#has_company?' do

    after(:each) {
      Company.delete_all
      MembershipApplication.delete_all
      User.delete_all
    }

    describe 'user: no application' do
      subject { create(:user, is_member: false) }
      it { expect(subject.has_company?).to be_falsey }
    end

    describe 'user: 1 saved application' do
      subject { create(:user_with_membership_app) }
      it { expect(subject.has_company?).to be_falsey }
    end

    describe 'user: 2 application' do
      subject { create(:user_with_2_membership_apps) }
      it { expect(subject.has_company?).to be_falsey }
    end

    describe 'member with 1 app' do
      let(:member) { create(:member_with_membership_app) }
      it { expect(member.has_company?).to be_truthy }
    end

    describe 'member with 0 apps (should not happen)' do
      let(:member) { create(:user, is_member: true) }
      it { expect(member.has_company?).to be_falsey }
    end

    describe 'admin' do
      subject { create(:user, admin: true) }
      it { expect(subject.has_company?).to be_falsey }
    end
  end

  describe '#membership_application' do

    describe 'user: no application' do
      subject { create(:user, is_member: false) }
      it { expect(subject.membership_application).to be_nil }
    end

    describe 'user: 1 saved application' do
      subject { create(:user_with_membership_app) }
      it { expect(subject.membership_application).not_to be_nil }
    end
    describe 'user: 2 application' do
      subject { create(:user_with_2_membership_apps) }
      it { expect(subject.membership_application).not_to be_nil }
      it { expect(subject.membership_applications.size).to eq(2) }
    end

    describe 'member with 1 app' do
      let(:member) { create(:member_with_membership_app) }
      it { expect(member.membership_application).to be_truthy }
    end

    describe 'member with 0 apps (should not happen)' do
      let(:member) { create(:user, is_member: true) }
      it { expect(member.membership_application).to be_falsey }
    end

    describe 'admin' do
      subject { create(:user, admin: true) }
      it { expect(subject.membership_application).to be_falsey }
    end
  end

  describe '#company' do
    describe 'user: no application' do
      subject { create(:user, is_member: false) }
      it { expect(subject.company).to be_nil }
    end

    describe 'user: 1 saved application' do
      subject { create(:user_with_membership_app) }
      it { expect(subject.company).to be_nil }
    end
    describe 'user: 2 application' do
      subject { create(:user_with_2_membership_apps) }
      it { expect(subject.company).to be_nil }
    end

    describe 'member with 1 app' do
      let(:member) { create(:member_with_membership_app) }
      it { expect(member.company).not_to be_nil }
    end

    describe 'member with 0 apps (should not happen)' do
      let(:member) { create(:user, is_member: true) }
      it { expect(member.company).to be_nil }
    end

    describe 'admin' do
      subject { create(:user, admin: true) }
      it { expect(subject.company).to be_nil }
    end
  end

  describe '#is_member?' do
    describe 'user: no application' do
      subject { create(:user, is_member: false) }
      it { expect(subject.is_member?).to be_falsey }
    end

    describe 'user: 1 saved application' do
      subject { create(:user_with_membership_app) }
      it { expect(subject.is_member?).to be_falsey }
    end
    describe 'user: 2 application' do
      subject { create(:user_with_2_membership_apps) }
      it { expect(subject.is_member?).to be_falsey }
    end

    describe 'member with 1 app' do
      let(:member) { create(:member_with_membership_app) }
      it { expect(member.is_member?).to be_truthy }
    end

    describe 'member with 0 apps (should not happen)' do
      let(:member) { create(:user) }
      it { expect(member.is_member?).to be_falsey }
    end

    describe 'admin' do
      subject { create(:user, admin: true) }
      it { expect(subject.is_member?).to be_falsey }
    end
  end

  describe '#is_member_or_admin?' do

    describe 'user: no application' do
      subject { create(:user, is_member: false) }
      it { expect(subject.is_member_or_admin?).to be_falsey }
    end

    describe 'user: 1 saved application' do
      subject { create(:user_with_membership_app) }
      it { expect(subject.is_member_or_admin?).to be_falsey }
    end
    describe 'user: 2 application' do
      subject { create(:user_with_2_membership_apps) }
      it { expect(subject.is_member_or_admin?).to be_falsey }
    end

    describe 'member with 1 app' do
      let(:member) { create(:member_with_membership_app) }
      it { expect(member.is_member_or_admin?).to be_truthy }
    end

    describe 'member with 0 apps (should not happen)' do
      let(:member) { create(:user) }
      it { expect(member.is_member_or_admin?).to be_falsey }
    end

    describe 'admin' do
      subject { create(:user, admin: true) }
      it { expect(subject.is_member_or_admin?).to be_truthy }
    end
  end
end
