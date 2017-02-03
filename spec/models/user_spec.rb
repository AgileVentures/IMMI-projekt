require 'rails_helper'

RSpec.describe User, type: :model do

  before(:all) do
    BusinessCategory.delete_all
    Company.delete_all
    MembershipApplication.delete_all
    User.delete_all
  end

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
      subject { create(:user) }
      it { expect(subject.is_member?).to be_falsey }
    end

    describe 'user: 1 new application' do
      subject { create(:user_with_membership_app) }
      it { expect(subject.is_member?).to be_falsey }
    end

    describe 'user: 2 new applications ' do
      subject { create(:user_with_2_membership_apps) }
      it { expect(subject.is_member?).to be_falsey }
    end

    describe 'member with 1 accepted app' do
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

  describe '#is_in_company_numbered?(company_num)' do

    default_co_number = '5562728336'
    describe 'not yet a member, so not in any full companies' do

      describe 'user: no applications, so not in any companies' do
        subject { create(:user, is_member: false) }
        it { expect(subject.is_in_company_numbered?(default_co_number)).to be_falsey }
      end

      describe 'user: 1 saved application' do
        subject { create(:user_with_membership_app) }
        it { expect(subject.is_in_company_numbered?(default_co_number)).to be_falsey }
      end

      describe 'user: 2 application' do
        subject { create(:user_with_2_membership_apps) }
        it { expect(subject.is_in_company_numbered?(default_co_number)).to be_falsey }
      end
    end

    describe 'is a member, so is in companies' do

      describe 'member with 1 app' do
        let(:member) { create(:member_with_membership_app) }
        it { expect(member.is_in_company_numbered?(default_co_number)).to be_truthy }
      end

      describe 'member with 2 apps, both with same (1) company' do
        let(:member) do
          m = create(:member_with_membership_app)
          app2 = create(:membership_application, :accepted, company_number: m.membership_applications.first.company_number)
          m.membership_applications << app2
          m
        end
        it { expect(member.is_in_company_numbered?(default_co_number)).to be_truthy }
      end

      describe 'member with 2 apps, 2 different companies' do
        let(:member) do
          m = create(:member_with_membership_app, company_number: '5562252998')
          app2 = create(:membership_application, :accepted, company_number: '2120000142')
          m.membership_applications << app2
          m
        end
        it { expect(member.is_in_company_numbered?('5562252998')).to be_truthy }
        it { expect(member.is_in_company_numbered?('2120000142')).to be_truthy }
      end


      describe 'member with 0 apps (should not happen)' do
        let(:member) { create(:user) }
        it { expect(member.is_in_company_numbered?(default_co_number)).to be_falsey }
      end

    end

    describe 'admin is not in any companies' do
      subject { create(:user, admin: true) }
      it { expect(subject.is_in_company_numbered?(default_co_number)).to be_falsey }
      it { expect(subject.is_in_company_numbered?('5712213304')).to be_falsey }
    end
  end

  describe '#companies' do
    describe 'not yet a member, so not in any full companies' do

      describe 'user: no applications, so not in any companies' do
        subject { create(:user, is_member: false) }
        it { expect(subject.companies.size).to eq(0) }
      end

      describe 'user: 1 saved application' do
        subject { create(:user_with_membership_app) }
        it { expect(subject.companies.size).to eq(0) }
      end

      describe 'user: 2 application' do
        subject { create(:user_with_2_membership_apps) }
        it { expect(subject.companies.size).to eq(0) }
      end

    end
    describe 'is a member, so is in companies' do

      describe 'member with 1 app' do
        let(:member) { create(:member_with_membership_app) }
        it { expect(member.companies.size).to eq(1) }
      end

      describe 'member with 2 apps, both with same (1) company' do
        let(:member) do
          m = create(:member_with_membership_app)
          app2 = create(:membership_application, :accepted, company_number: m.membership_applications.first.company_number)
          m.membership_applications << app2
          m
        end
        it { expect(member.companies.size).to eq(1), "found: size: #{member.companies.size} #{member.companies.inspect}" }
      end

      describe 'member with 2 apps, 2 different companies' do
        let(:member) do
          m = create(:member_with_membership_app, company_number: '5562252998')
          app2 = create(:membership_application, :accepted, company_number: '2120000142')
          m.membership_applications << app2
          m
        end
        it { expect(member.companies.size).to eq(2) }
      end

      describe 'member with 2 apps, 2 for the same company, 1 different company' do
        let(:member) do
          m = create(:member_with_membership_app)
          app2 = create(:membership_application, :accepted, company_number: m.membership_applications.first.company_number)
          m.membership_applications << app2
          app3_different_co = create(:membership_application, :accepted, company_number: '2120000142')
          m.membership_applications << app3_different_co
          m
        end
        it { expect(member.companies.size).to eq(2) }
      end

      describe 'member with 0 apps (should not happen)' do
        let(:member) { create(:user) }
        it { expect(member.companies.size).to eq(0) }
      end

    end

    describe 'admin will get all Companies' do
      subject { create(:user, admin: true) }
      it do
        create(:company, company_number: '0000000000')
        create(:company, company_number: '5560360793')
        create(:company, company_number: '2120000142')
        num_companies = Company.all.size
        expect(subject.companies.size).to eq(num_companies)
      end
    end
  end

  describe '#admin?' do
    describe 'user: no application' do
      subject { create(:user, is_member: false) }
      it { expect(subject.admin?).to be_falsey }
    end

    describe 'member with 1 app' do
      let(:member) { create(:member_with_membership_app) }
      it { expect(member.admin?).to be_falsey }
    end

    describe 'admin' do
      subject { create(:user, admin: true) }
      it { expect(subject.admin?).to be_truthy }
    end
  end
end
