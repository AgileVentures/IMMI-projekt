require 'rails_helper'

RSpec.describe User, type: :model do

  before(:all) do
    expect(BusinessCategory.count).to eq(0)
    expect(Company.count).to eq(0)
    expect(MembershipApplication.count).to eq(0)
    expect(User.count).to eq(0)
  end

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:user)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :first_name }
    it { is_expected.to have_db_column :last_name }
    it { is_expected.to have_db_column :membership_number }
    it { is_expected.to have_db_column :email }
    it { is_expected.to have_db_column :admin }
    it { is_expected.to have_db_column :member }
  end

  describe 'Validations' do
    it { is_expected.to(validate_presence_of :first_name) }
    it { is_expected.to(validate_presence_of :last_name) }
    it { is_expected.to validate_uniqueness_of :membership_number }
  end

  describe 'Associations' do
    it { is_expected.to have_many :membership_applications }
    it { is_expected.to have_many :payments }
  end

  describe 'Admin' do
    subject { create(:user, admin: true) }

    it { is_expected.to be_admin }
    it { is_expected.not_to be_member }
  end

  describe 'User' do
    subject { create(:user, admin: false) }

    it { is_expected.not_to be_admin }
    it { is_expected.not_to be_member }
  end


  describe '#has_membership_application?' do

    describe 'user: no application' do
      subject { create(:user) }
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
      let(:member) { create(:user) }
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
      subject { create(:user) }
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
      let(:member) { create(:user) }
      it { expect(member.has_company?).to be_falsey }
    end

    describe 'admin' do
      subject { create(:user, admin: true) }
      it { expect(subject.has_company?).to be_falsey }
    end
  end

  describe '#membership_application' do

    describe 'user: no application' do
      subject { create(:user) }
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
      let(:member) { create(:user) }
      it { expect(member.membership_application).to be_falsey }
    end

    describe 'admin' do
      subject { create(:user, admin: true) }
      it { expect(subject.membership_application).to be_falsey }
    end
  end

  describe '#company' do
    describe 'user: no application' do
      subject { create(:user) }
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
      let(:member) { create(:user) }
      it { expect(member.company).to be_nil }
    end

    describe 'admin' do
      subject { create(:user, admin: true) }
      it { expect(subject.company).to be_nil }
    end
  end

  describe '#is_member_or_admin?' do

    describe 'user: no application' do
      subject { create(:user) }
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
        subject { create(:user) }
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
        subject { create(:user) }
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
      subject { create(:user) }
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

  describe '#full_name' do
    let(:user) { build(:user, first_name: 'first', last_name: 'last') }
    context '@first_name=first @last_name=last' do
      it { expect(user.full_name).to eq('first last') }
    end
  end


  describe '#issue_membership_number' do

    it 'does not overwrite an existing membership_number' do
      existing_number = 'SHF00042'
      subject.membership_number = existing_number
      subject.issue_membership_number
      expect(subject.membership_number).to eq(existing_number)
    end

    it 'generates sequential membership_numbers' do
      subject.issue_membership_number
      first_number = subject.membership_number.to_i

      subject.membership_number = nil
      subject.issue_membership_number
      second_number = subject.membership_number.to_i

      expect(second_number).to eq(first_number+1)
    end

  end

  context 'payment and membership period' do
    let(:user) { create(:user) }
    let(:success) { Payment.order_to_payment_status('successful') }
    let(:application) do
      create(:membership_application, user: user, state: :accepted)
    end

    let(:payment1) do
      create(:payment, user: user, status: success,
             notes: 'these are notes for payment1',
             expire_date: Date.new(2018, 1, 1))
    end
    let(:payment2) do
      create(:payment, user: user, status: success,
             notes: 'these are notes for payment2',
             expire_date: Date.new(2018, 7, 1))
    end

    describe '#membership_expire_date' do
      it 'returns date for latest completed payment' do
        payment1
        expect(user.membership_expire_date).to eq payment1.expire_date
        payment2
        expect(user.membership_expire_date).to eq payment2.expire_date
      end
    end

    describe '#payment_notes' do
      it 'returns notes for latest completed payment' do
        payment1
        expect(user.payment_notes).to eq payment1.notes
        payment2
        expect(user.payment_notes).to eq payment2.notes
      end
    end

    describe '#most_recent_payment' do
      it 'returns latest completed payment' do
        payment1
        expect(user.most_recent_payment).to eq payment1
        payment2
        expect(user.most_recent_payment).to eq payment2
      end
    end

    describe '.self.next_payment_dates' do

      context 'start_date' do

        it 'returns today if no prior payment' do
          expect(User.next_payment_dates(user.id)[0]).to eq Date.today
        end

        it 'returns prior-payment-expire_date plus one day if prior payment' do
          payment1
          expect(User.next_payment_dates(user.id)[0])
            .to eq payment1.expire_date + 1.day
        end
      end

      context 'expire_date' do
        after(:each) do
          Timecop.return
        end

        describe 'during the year 2017' do

          it 'returns January 1, 2018' do
            Timecop.freeze(Date.new(2017, 10, 1))
            expect(User.next_payment_dates(user.id)[1])
              .to eq Date.new(2018, 12, 31)
          end
        end

        describe 'after year 2017' do
          it 'returns prior expire_date plus one year' do
            Timecop.freeze(Date.new(2018, 7, 1))
            payment1
            expect(User.next_payment_dates(user.id)[1])
              .to eq payment1.expire_date + 1.year
          end
        end
      end
    end

    describe '#allow_pay_member_fee?' do
      it 'returns true if user is a member' do
        user.member = true
        user.save
        expect(user.allow_pay_member_fee?).to eq true
      end

      it 'returns true if user has app in "accepted" state' do
        application
        expect(user.allow_pay_member_fee?).to eq true
      end
    end
  end
end
