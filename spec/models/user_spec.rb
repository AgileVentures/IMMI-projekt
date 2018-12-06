require 'rails_helper'
require 'email_spec/rspec'

RSpec.describe User, type: :model do

  let(:user) { create(:user) }
  let(:user_with_app) { create(:user_with_membership_app) }
  let(:member) { create(:member_with_membership_app) }

  let(:with_short_proof_of_membership_url) do
    create(:user, short_proof_of_membership_url: 'http://www.tinyurl.com/proofofmembership')
  end

  let(:application) do
    create(:shf_application, user: user, state: :accepted)
  end

  let(:complete_co) do
    create(:company, name: 'Complete Company', company_number: '4268582063')
  end

  let(:success) { Payment.order_to_payment_status('successful') }
  let(:payment_date_2017_10_01) { Time.zone.local(2017, 10, 1) }
  let(:payment_date_2018_11_21) { Time.zone.local(2018, 11, 21) }
  let(:payment_date_2020_03_15) { Time.zone.local(2020, 3, 15) }

  let(:member_payment1) do
    start_date, expire_date = User.next_membership_payment_dates(user.id)
    create(:payment, user: user, status: success,
           payment_type: Payment::PAYMENT_TYPE_MEMBER,
           notes: 'these are notes for member payment1',
           start_date: start_date,
           expire_date: expire_date)
  end
  let(:member_payment2) do
    start_date, expire_date = User.next_membership_payment_dates(user.id)
    create(:payment, user: user, status: success,
           payment_type: Payment::PAYMENT_TYPE_MEMBER,
           notes: 'these are notes for member payment2',
           start_date: start_date,
           expire_date: expire_date)
  end
  let(:branding_payment1) do
    start_date, expire_date = Company.next_branding_payment_dates(complete_co.id)
    create(:payment, user: user, status: success, company: complete_co,
           payment_type: Payment::PAYMENT_TYPE_BRANDING,
           notes: 'these are notes for branding payment1',
           start_date: start_date,
           expire_date: expire_date)
  end
  let(:branding_payment2) do
    start_date, expire_date = Company.next_branding_payment_dates(complete_co.id)
    create(:payment, user: user, status: success, company: complete_co,
           payment_type: Payment::PAYMENT_TYPE_BRANDING,
           notes: 'these are notes for branding payment2',
           start_date: start_date,
           expire_date: expire_date)
  end


  describe 'Factory' do
    it 'has valid factories' do
      expect(create(:user)).to be_valid
      expect(create(:user_without_first_and_lastname)).to be_valid
      expect(create(:user_with_membership_app)).to be_valid
      expect(create(:user_with_membership_app)).to be_valid
      expect(create(:member_with_membership_app)).to be_valid
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
    it { is_expected.to have_one(:shf_application).dependent(:destroy) }
    it { is_expected.to have_many(:payments).dependent(:nullify) }
    it { is_expected.to accept_nested_attributes_for(:payments) }
    it { is_expected.to have_attached_file(:member_photo) }
    it { is_expected.to have_many(:companies).through(:shf_application) }
    it { is_expected.to accept_nested_attributes_for(:shf_application)
      .allow_destroy(false).update_only(true) }
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

  describe 'destroy or nullify associated records when user is destroyed' do

    it 'member_photo' do
      expect(user.member_photo).not_to be_nil
      expect(user.member_photo.exists?).to be true

      user.destroy

      expect(user.destroyed?).to be true
      expect(user.member_photo.exists?).to be false
    end

    context 'membership application' do
      it 'user with application' do
        expect { user_with_app }.to change(ShfApplication, :count).by(1)
        expect { user_with_app.destroy }.to change(ShfApplication, :count).by(-1)
      end

      it 'member' do
        expect { member }.to change(ShfApplication, :count).by(1)
        expect { member.destroy }.to change(ShfApplication, :count).by(-1)
      end
    end

    context 'nullify user_id in associated payment records' do
      it 'membership payments' do
        user_id = user.id

        expect { member_payment1; member_payment2 }.to change(Payment, :count).by(2)

        expect { user.destroy }.not_to change(Payment, :count)
        expect(Payment.find_by_user_id(user_id)).to be_nil
      end

      it 'h-branding payments' do
        company_id = complete_co.id
        user_id = user.id

        expect { branding_payment1; branding_payment2 }.to change(Payment, :count).by(2)

        expect { user.destroy }.not_to change(Payment, :count)
        expect(Payment.find_by_company_id(company_id)).not_to be_nil
        expect(Payment.find_by_user_id(user_id)).to be_nil
      end
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


=begin
  This is now the responsibility of the MembershipStatusUpdater class

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
=end

  context 'payment and membership period' do

    describe '#membership_expire_date' do
      it 'returns date for latest completed payment' do
        member_payment1
        expect(user.membership_expire_date).to eq member_payment1.expire_date
        member_payment2
        expect(user.membership_expire_date).to eq member_payment2.expire_date
      end
    end

    describe '#membership_payment_notes' do
      it 'returns notes for latest completed payment' do
        member_payment1
        expect(user.membership_payment_notes).to eq member_payment1.notes
        member_payment2
        expect(user.membership_payment_notes).to eq member_payment2.notes
      end
    end

    describe '#most_recent_membership_payment' do
      it 'returns latest completed payment' do
        member_payment1
        expect(user.most_recent_membership_payment).to eq member_payment1
        member_payment2
        expect(user.most_recent_membership_payment).to eq member_payment2
      end
    end

    describe '.self.next_membership_payment_dates' do

      around(:each) do |example|
        Timecop.freeze(payment_date_2018_11_21)
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
        member_payment1
        expect(User.next_membership_payment_dates(user.id)[0])
          .to eq Time.zone.today + 1.year
      end

      it 'returns one year later for second payment expire date' do
        member_payment1
        expect(User.next_membership_payment_dates(user.id)[1])
          .to eq Time.zone.today + 1.year + 1.year - 1.day
      end

      context 'if next payment occurs after prior payment expire date' do

        it 'returns actual payment date for start date' do
          # User renews membership (pays fee) *after* the prior payment has expired.
          # In this case, the new payment period starts on the day of payment (2020/03/15).
          member_payment1
          Timecop.freeze(payment_date_2020_03_15)

          payment_start_date = User.next_membership_payment_dates(user.id)[0]

          expect(payment_start_date).to eq payment_date_2020_03_15
        end

        it 'returns payment date + 1 year for expire date' do
          # User renews membership (pays fee) *after* the prior payment has expired.
          # In this case, the new payment period expires one year after
          # the day of payment (expire date should be 2021/03/14).
          member_payment1
          Timecop.freeze(payment_date_2020_03_15)

          payment_expire_date = User.next_membership_payment_dates(user.id)[1]

          expect(payment_expire_date).to eq payment_date_2020_03_15 + 1.year - 1.day
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

=begin
This is now the responsibility of the MembershipStatusUpdater class

    describe '#check_memberstatus' do
      it 'does nothing if not a member' do
        user.check_member_status
        expect(user.member).to be false
      end

      it 'does nothing if a member and payment not expired' do
        member_payment1
        user.update(member: true)

        user.check_member_status
        expect(user.member).to be true
      end

      it 'revokes membership if a member and payment has expired' do
        Timecop.freeze(payment_date_2018_11_21)

        member_payment1
        user.update(member: true)

        Timecop.freeze(Time.zone.today + 1.year)

        user.check_member_status
        expect(user.member).to be false

        Timecop.return
      end

    end
=end

  end

  describe '#get_short_proof_of_membership_url' do
    context 'there is already a shortened url in the table' do
      it 'returns shortened url' do
        url = 'http://localhost:3000/anvandare/0/company_h_brand?company_id=1'
        expect(with_short_proof_of_membership_url.get_short_proof_of_membership_url(url)).to eq('http://www.tinyurl.com/proofofmembership')
      end
    end

    context 'there is no shortened url in the table and ShortenUrl.short is called' do
      it 'saves the result if the result is not nil and returns shortened url' do
        url = 'http://localhost:3000/anvandare/0/company_h_brand?company_id=1'
        allow(ShortenUrl).to receive(:short).with(url).and_return('http://tinyurl.com/proofofmembership2')
        expect(user.get_short_proof_of_membership_url(url)).to eq(ShortenUrl.short(url))
        expect(user.short_proof_of_membership_url).to eq(ShortenUrl.short(url))
      end
      it 'does not save anything if the result is nil and returns unshortened url' do
        url = 'http://localhost:3000/anvandare/0/company_h_brand?company_id=1'
        allow(ShortenUrl).to receive(:short).with(url).and_return(nil)
        expect(user.get_short_proof_of_membership_url(url)).to eq(url)
        expect(user.short_proof_of_membership_url).to eq(nil)
      end
    end
  end
end
