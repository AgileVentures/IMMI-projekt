require 'rails_helper'
require 'email_spec/rspec'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

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
    it { is_expected.to have_db_column :member_photo_file_name }
    it { is_expected.to have_db_column :member_photo_content_type }
    it { is_expected.to have_db_column :member_photo_file_size }
    it { is_expected.to have_db_column :member_photo_updated_at }
  end

  describe 'Validations' do
    it { is_expected.to(validate_presence_of :first_name) }
    it { is_expected.to(validate_presence_of :last_name) }
    it { is_expected.to validate_uniqueness_of :membership_number }
    it do
      is_expected.to validate_attachment_content_type(:member_photo)
        .allowing('image/png', 'image/jpeg')
        .rejecting('image/gif', 'image/bmp')
    end

    describe 'validates file contents and file type' do
      let(:file_root) { "#{Rails.root}/spec/fixtures/member_photos/" }
      let(:txt_file)  { File.new(file_root + 'text_file.jpg') }
      let(:gif_file)  { File.new(file_root + 'gif_file.jpg') }
      let(:ico_file)  { File.new(file_root + 'ico_file.png') }
      let(:xyz_file)  { File.new(file_root + 'member_with_dog.xyz') }

      it 'rejects if content not jpeg or png' do
        user.member_photo = txt_file
        expect(user).not_to be_valid

        user.member_photo = gif_file
        expect(user).not_to be_valid

        user.member_photo = ico_file
        expect(user).not_to be_valid
      end
      it 'rejects if content OK but file type wrong' do
        user.member_photo = xyz_file
        expect(user).not_to be_valid
      end
    end
  end

  describe 'Associations' do
    it { is_expected.to have_one(:shf_application) }
    it { is_expected.to have_many(:payments) }
    it { is_expected.to accept_nested_attributes_for(:payments) }
    it { is_expected.to have_attached_file(:member_photo) }
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

  describe 'destroy associated records when user is destroyed' do
    it 'member_photo' do
      expect(user.member_photo).not_to be_nil
      expect(user.member_photo.exists?).to be true

      user.destroy

      expect(user.destroyed?).to be true
      expect(user.member_photo.exists?).to be false
    end
  end

  describe 'Scopes' do

    describe 'admins' do

      it 'returns 2 users that are admins and 0 that are not' do
        admin1 = create(:user, admin: true, first_name: 'admin1')
        admin2 = create(:user, admin: true, first_name: 'admin2')
        user1 = create(:user, first_name: 'user1')

        all_admins = described_class.admins

        expect(all_admins.count ).to eq 2
        expect(all_admins).to include admin1
        expect(all_admins).to include admin2
        expect(all_admins).not_to include user1
      end
    end

  end

  describe '#has_shf_application?' do

    describe 'user: no application' do
      subject { create(:user) }
      it { expect(subject.has_shf_application?).to be_falsey }
    end

    describe 'user: 1 saved application' do
      subject { create(:user_with_membership_app) }
      it { expect(subject.has_shf_application?).to be_truthy }
    end

    describe 'user: 1 not yet saved application' do
      let(:user_with_app) { build(:user_with_membership_app) }
      it { expect(subject.has_company?).to be_falsey }
    end

    describe 'member with 1 app' do
      let(:member) { create(:member_with_membership_app) }
      let(:member_app) { create(:shf_application, user: user_with_app) }
      it { expect(member.has_shf_application?).to be_truthy }
    end

    describe 'member with 0 app (should not happen)' do
      let(:member) { create(:user) }
      it { expect(member.has_shf_application?).to be_falsey }
    end

    describe 'admin' do
      subject { create(:user, admin: true) }
      it { expect(subject.has_shf_application?).to be_falsey }
    end

  end

  describe '#has_company?' do

    after(:each) {
      Company.destroy_all
      ShfApplication.destroy_all
      User.destroy_all
    }

    describe 'user: no application' do
      subject { create(:user) }
      it { expect(subject.has_company?).to be_falsey }
    end

    describe 'user: 1 saved application' do
      subject { create(:user_with_membership_app) }
      it { expect(subject.has_company?).to be_truthy }
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

  describe '#shf_application' do

    describe 'user: no application' do
      subject { create(:user) }
      it { expect(subject.shf_application).to be_nil }
    end

    describe 'user: 1 saved application' do
      subject { create(:user_with_membership_app) }
      it { expect(subject.shf_application).not_to be_nil }
    end

    describe 'member with 1 app' do
      let(:member) { create(:member_with_membership_app) }
      it { expect(member.shf_application).to be_truthy }
    end

    describe 'member with 0 apps (should not happen)' do
      let(:member) { create(:user) }
      it { expect(member.shf_application).to be_falsey }
    end

    describe 'admin' do
      subject { create(:user, admin: true) }
      it { expect(subject.shf_application).to be_falsey }
    end
  end


  describe '#member_or_admin?' do

    describe 'user: no application' do
      subject { create(:user) }
      it { expect(subject.member_or_admin?).to be_falsey }
    end

    describe 'user: 1 saved application' do
      subject { create(:user_with_membership_app) }
      it { expect(subject.member_or_admin?).to be_falsey }
    end

    describe 'member with 1 app' do
      let(:member) { create(:member_with_membership_app) }
      it { expect(member.member_or_admin?).to be_truthy }
    end

    describe 'member with 0 apps (should not happen)' do
      let(:member) { create(:user) }
      it { expect(member.member_or_admin?).to be_falsey }
    end

    describe 'admin' do
      subject { create(:user, admin: true) }
      it { expect(subject.member_or_admin?).to be_truthy }
    end
  end

  describe '#in_company_numbered?(company_num)' do

    default_co_number = '5562728336'
    describe 'not yet a member, so not in any full companies' do

      describe 'user: no applications, so not in any companies' do
        subject { create(:user) }
        it { expect(subject.in_company_numbered?(default_co_number)).to be_falsey }
      end

      describe 'user: 1 saved application' do
        subject { create(:user_with_membership_app) }
        it { expect(subject.in_company_numbered?(default_co_number)).to be_falsey }
      end
    end

    describe 'is a member, so is in companies' do
      let(:co_number) { member.shf_application&.companies&.first&.company_number }

      describe 'member with 1 app' do
        let(:member) { create(:member_with_membership_app) }
        it { expect(member.in_company_numbered?(co_number)).to be_truthy }
      end

      describe 'member with 0 apps (should not happen)' do
        let(:member) { create(:user) }
        it { expect(member.in_company_numbered?(co_number)).to be_falsey }
      end

    end

    describe 'admin is not in any companies' do
      subject { create(:user, admin: true) }
      it { expect(subject.in_company_numbered?(default_co_number)).to be_falsey }
      it { expect(subject.in_company_numbered?('5712213304')).to be_falsey }
    end
  end

  describe '#companies' do
    describe 'not yet a member, so not in any full companies' do

      describe 'user: 1 saved application' do
        subject { create(:user_with_membership_app) }
        it { expect(subject.companies.size).to eq(1) }
      end
    end

    describe 'is a member, so is in companies' do

      describe 'member with 1 app' do
        let(:member) { create(:member_with_membership_app) }
        it { expect(member.companies.size).to eq(1) }
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


  describe '#grant_membership' do

    it 'sets the member field for the user' do
      # mock the MemberMailer so we don't try to send emails
      expect(MemberMailer).to receive(:membership_granted).with(subject).and_return( double('MemberMailer', deliver: true))

      subject.grant_membership
      expect(subject.member).to be_truthy
    end

    it 'does not overwrite an existing membership_number' do
      # mock the MemberMailer so we don't try to send emails
      expect(MemberMailer).to receive(:membership_granted).with(subject).and_return( double('MemberMailer', deliver: true))

      existing_number = 'SHF00042'
      subject.membership_number = existing_number
      subject.grant_membership
      expect(subject.membership_number).to eq(existing_number)
    end

    it 'generates sequential membership_numbers' do
      # mock the MemberMailer so we don't try to send emails
      expect(MemberMailer).to receive(:membership_granted).with(subject).twice.and_return( double('MemberMailer', deliver: true))

      subject.grant_membership
      first_number = subject.membership_number.to_i

      subject.membership_number = nil
      subject.grant_membership
      second_number = subject.membership_number.to_i

      expect(second_number).to eq(first_number+1)
    end

    it 'sends emails out by default' do
      expect_any_instance_of(MemberMailer).to receive(:membership_granted).with(subject)
      subject.grant_membership
    end

    it 'send_email: true sends email to the member to let them know they are now a member' do
      expect_any_instance_of(MemberMailer).to receive(:membership_granted).with(subject)
      subject.grant_membership(send_email:true)
    end

    it 'send_email: false does not send email to the member to let them know they are now a member' do
      expect_any_instance_of(MemberMailer).not_to receive(:membership_granted).with(subject)
      subject.grant_membership(send_email: false)
    end

  end

  context 'payment and membership period' do
    let(:user) { create(:user) }
    let(:success) { Payment.order_to_payment_status('successful') }
    let(:application) do
      create(:shf_application, user: user, state: :accepted)
    end

    let(:payment_date_2017) { Time.zone.local(2017, 10, 1) }

    let(:payment_date_2018) { Time.zone.local(2018, 11, 21) }

    let(:payment1) do
      start_date, expire_date = User.next_membership_payment_dates(user.id)
      create(:payment, user: user, status: success,
             payment_type: Payment::PAYMENT_TYPE_MEMBER,
             notes: 'these are notes for member payment1',
             start_date: start_date,
             expire_date: expire_date)
    end
    let(:payment2) do
      start_date, expire_date = User.next_membership_payment_dates(user.id)
      create(:payment, user: user, status: success,
             payment_type: Payment::PAYMENT_TYPE_MEMBER,
             notes: 'these are notes for member payment2',
             start_date: start_date,
             expire_date: expire_date)
    end

    describe '#membership_expire_date' do
      it 'returns date for latest completed payment' do
        payment1
        expect(user.membership_expire_date).to eq payment1.expire_date
        payment2
        expect(user.membership_expire_date).to eq payment2.expire_date
      end
    end

    describe '#membership_payment_notes' do
      it 'returns notes for latest completed payment' do
        payment1
        expect(user.membership_payment_notes).to eq payment1.notes
        payment2
        expect(user.membership_payment_notes).to eq payment2.notes
      end
    end

    describe '#most_recent_membership_payment' do
      it 'returns latest completed payment' do
        payment1
        expect(user.most_recent_membership_payment).to eq payment1
        payment2
        expect(user.most_recent_membership_payment).to eq payment2
      end
    end

    describe '.self.next_membership_payment_dates' do

      context 'during the year 2017' do

        around(:each) do |example|
          Timecop.freeze(payment_date_2017)
          example.run
          Timecop.return
        end

        it "returns today's date for first payment start date" do
          expect(User.next_membership_payment_dates(user.id)[0])
            .to eq Time.zone.today
        end

        it 'returns Dec 31, 2018 for first payment expire date' do
          expect(User.next_membership_payment_dates(user.id)[1])
            .to eq Time.zone.local(2018, 12, 31)
        end

        it 'returns Jan 1, 2019 for second payment start date' do
          payment1
          expect(User.next_membership_payment_dates(user.id)[0])
            .to eq Time.zone.local(2019, 1, 1)
        end

        it 'returns Dec 31, 2019 for second payment expire date' do
          payment1
          expect(User.next_membership_payment_dates(user.id)[1])
            .to eq Time.zone.local(2019, 12, 31)
        end
      end

      context 'after the year 2017' do

        around(:each) do |example|
          Timecop.freeze(payment_date_2018)
          example.run
          Timecop.return
        end

        it "returns today's date for first payment start date" do
          expect(User.next_membership_payment_dates(user.id)[0]).to eq Time.zone.today
        end

        it 'returns one year later for first payment expire date' do
          expect(User.next_membership_payment_dates(user.id)[1])
            .to eq Time.zone.today + 1.year - 1.day
        end

        it 'returns date-after-expiration for second payment start date' do
          payment1
          expect(User.next_membership_payment_dates(user.id)[0])
            .to eq Time.zone.today + 1.year
        end

        it 'returns one year later for second payment expire date' do
          payment1
          expect(User.next_membership_payment_dates(user.id)[1])
            .to eq Time.zone.today + 1.year + 1.year - 1.day
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

    describe '#check_member_status' do
      it 'does nothing if not a member' do
        user.check_member_status
        expect(user.member).to be false
      end

      it 'does nothing if a member and payment not expired' do
        payment1
        user.update(member: true)

        user.check_member_status
        expect(user.member).to be true
      end

      it 'revokes membership if a member and payment has expired' do
        Timecop.freeze(payment_date_2018)

        payment1
        user.update(member: true)

        Timecop.freeze(Time.zone.today + 1.year)

        user.check_member_status
        expect(user.member).to be false

        Timecop.return
      end
    end
  end
end
