require 'rails_helper'
require 'email_spec/rspec'
require 'shared_context/unstub_paperclip_all_run_commands'
require 'shared_context/users'
require 'shared_context/named_dates'

# TODO use the users already defined/created in the shared_context/users

# ================================================================================

RSpec.describe User, type: :model do

  # These are required to get the content type and validate it
  include_context 'unstub Paperclip all run commands'

  include_context 'create users'
  include_context 'named dates'

  before(:each) do
    allow_any_instance_of(Paperclip::Attachment).to receive(:post_process_file)
                                                        .with(any_args)
                                                        .and_call_original
  end

  let(:user) { create(:user) }
  let(:user_with_member_photo) { create(:user, :with_member_photo) }

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

  # --------
  # These are used to test if a user belongs to a company and if a user has an application with a company
  given_co_num = '5562728336'
  other_co_num1 = '7532246258'
  other_co_num2 = '8681197987'

  # Create these companies if they don't already exist:
  #   (Helps to keep tests faster; don't have to keep creating and deleting)
  let(:given_co) do
    (co = Company.find_by(company_number: given_co_num)).nil? ? create(:company, company_number: given_co_num) : co
  end

  let(:other_co1) do
    (co = Company.find_by(company_number: other_co_num1)).nil? ? create(:company, company_number: other_co_num1) : co
  end

  let(:other_co2) do
    (co = Company.find_by(company_number: other_co_num2)).nil? ? create(:company, company_number: other_co_num2) : co
  end
  # --------


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
    it { is_expected.to have_db_column :short_proof_of_membership_url }
    it { is_expected.to have_db_column :date_membership_packet_sent }
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
      let(:txt_file) { File.new(file_root + 'text_file.jpg') }
      let(:gif_file) { File.new(file_root + 'gif_file.jpg') }
      let(:ico_file) { File.new(file_root + 'ico_file.png') }
      let(:xyz_file) { File.new(file_root + 'member_with_dog.xyz') }

      it 'rejects if content not jpeg or png' do

        user_with_member_photo.member_photo = txt_file
        expect(user_with_member_photo).not_to be_valid

        user_with_member_photo.member_photo = gif_file
        expect(user_with_member_photo).not_to be_valid

        user_with_member_photo.member_photo = ico_file
        expect(user_with_member_photo).not_to be_valid
      end

      it 'rejects if content OK but file type wrong' do
        user_with_member_photo.member_photo = xyz_file
        expect(user_with_member_photo).not_to be_valid
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
      expect(user_with_member_photo.member_photo).not_to be_nil
      expect(user_with_member_photo.member_photo.exists?).to be true
      member_photo = user_with_member_photo.member_photo

      user_with_member_photo.destroy

      expect(member_photo.exists?).to be_falsey
      expect(user_with_member_photo.destroyed?).to be_truthy
      expect(user_with_member_photo.member_photo.exists?).to be_falsey
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

    context 'payments are NOT deleted if a user is deleted' do

      context 'membership payments' do

        before(:each) do
          # create the payments
          member_payment1
          member_payment2
        end

        it 'user (id) is set to nil' do
          user_id = user.id
          expect(Payment.where(user_id: nil).count).to eq 0
          expect { user.destroy }.not_to change(Payment, :count)

          expect(Payment.find_by_user_id(user_id)).to be_nil
          expect(Payment.where(user_id: nil).count).to eq 2
        end
      end


      context 'h-branding (h-markt licensing) payments' do

        it 'user (id) is set to nil' do
          company_id = complete_co.id
          user_id = user.id

          # create the payments
          expect { branding_payment1; branding_payment2 }.to change(Payment, :count).by(2)
          expect(Payment.where(user_id: nil).count).to eq 0

          expect { user.destroy }.not_to change(Payment, :count)
          expect(Payment.find_by_company_id(company_id)).not_to be_nil
          expect(Payment.find_by_user_id(user_id)).to be_nil
          expect(Payment.where(user_id: nil).count).to eq 2
        end
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

        expect(all_admins.count).to eq 2
        expect(all_admins).to include admin1
        expect(all_admins).to include admin2
        expect(all_admins).not_to include user1
      end
    end


    describe 'members' do

      it 'returns those with member = true' do
        user_member1 = create(:member_with_membership_app, first_name: 'Member 1')
        user_member2 = create(:member_with_membership_app, first_name: 'Member 2')

        user_has_app_not_member = create(:user_with_membership_app, first_name: 'App')
        visitor = create(:user, first_name: 'Visitor')
        admin = create(:user, admin: true, first_name: 'Admin')

        members = described_class.members

        expect(members.count).to eq 2
        expect(members).to include user_member1
        expect(members).to include user_member2
        expect(members).not_to include admin
        expect(members).not_to include visitor
        expect(members).not_to include user_has_app_not_member

      end

    end


    describe 'current_members' do

      # set today to January 1 for every example run
      around(:each) do |example|
        Timecop.freeze(jan_1)
        example.run
        Timecop.return
      end

      let(:user_no_app) { create(:user) }
      let(:user_app_not_accepted) { create(:user_with_membership_app) }

      let(:member_exp_jan1_today) { create(:member_with_expiration_date, expiration_date: jan_1) }
      let(:member_current_exp_jan2) { create(:member_with_expiration_date, expiration_date: jan_2) }
      let(:member_current_exp_jan3) { create(:member_with_expiration_date, expiration_date: jan_3) }


      it 'all applications are accepted' do
        user_no_app
        user_app_not_accepted
        member_exp_jan1_today
        member_current_exp_jan2
        member_current_exp_jan3
        in_scope = User.current_members
        app_states = in_scope.map { |member| member.shf_application.state }.uniq
        expect(app_states).to match_array([ShfApplication::STATE_ACCEPTED.to_s])
      end

      it 'all have a successful membership payment' do
        user_no_app
        user_app_not_accepted
        member_exp_jan1_today
        member_current_exp_jan2
        member_current_exp_jan3
        in_scope = User.current_members
        payment_states = in_scope.map { |member| member.most_recent_membership_payment.status }.uniq
        expect(payment_states).to match_array([Payment::SUCCESSFUL])
      end

      it 'the membership payment expires after today (.future?)' do
        user_no_app
        user_app_not_accepted
        member_exp_jan1_today
        member_current_exp_jan2
        member_current_exp_jan3
        in_scope = User.current_members
        expires_dates = in_scope.map { |member| member.most_recent_membership_payment.expire_date }.uniq
        payments_expire_today_or_before = expires_dates.select { |date| date <= Date.current }
        payments_expire_after_today = expires_dates.select { |date| date > Date.current }

        expect(payments_expire_today_or_before).to be_empty
        expect(payments_expire_after_today).to match_array([jan_2, jan_3])
      end

    end


    describe 'expiration dates' do

      # set today to January 1, 2019 for every example run
      around(:each) do |example|
        Timecop.freeze(Date.new(2019, 1, 1))
        example.run
        Timecop.return
      end

      JAN_01 = Date.new(2019, 1, 1)
      DEC_31_2018 = JAN_01 - 1
      JAN_02 = JAN_01 + 1

      JUN_01 = JAN_01 + 151


      describe 'membership_expires_in_x_days' do

        it 'x = 1 day, 0 days, -1 days' do

          # branding fees paid (only)
          member_only_branding_fees_exp_jan02 = create(:member_with_membership_app, first_name: 'Only Branding fees exp Jan 02')
          create(:h_branding_fee_payment, :successful,
                 user: member_only_branding_fees_exp_jan02,
                 expire_date: JAN_02)


          # both branding fee and membership fee paid on Jan 2:
          both_exp_jan02_1 = create(:member_with_membership_app, first_name: 'Both fees Exp jan02 1')
          create(:membership_fee_payment, :successful,
                 user: both_exp_jan02_1,
                 expire_date: JAN_02)
          create(:h_branding_fee_payment, :successful,
                 user: both_exp_jan02_1,
                 expire_date: JAN_02)

          # membership fees paid for a member
          create(:member_with_expiration_date, expiration_date: DEC_31_2018)
          create(:member_with_expiration_date, expiration_date: DEC_31_2018)
          create(:member_with_expiration_date, expiration_date: JAN_01)
          create(:member_with_expiration_date, expiration_date: JAN_02)
          create(:member_with_expiration_date, expiration_date: JAN_02)


          membership_expires_in_1_day = User.membership_expires_in_x_days(1)
          expect(membership_expires_in_1_day.count).to eq 3
          uniq_payment_types = membership_expires_in_1_day.pluck(:payment_type).uniq
          expect(uniq_payment_types.first).to eq Payment::PAYMENT_TYPE_MEMBER

          membership_expires_today = User.membership_expires_in_x_days(0)
          expect(membership_expires_today.count).to eq 1
          uniq_payment_types = membership_expires_today.pluck(:payment_type).uniq
          expect(uniq_payment_types.first).to eq Payment::PAYMENT_TYPE_MEMBER

          membership_expired_yesterday = User.membership_expires_in_x_days(-1)
          expect(membership_expired_yesterday.count).to eq 2
          uniq_payment_types = membership_expired_yesterday.pluck(:payment_type).uniq
          expect(uniq_payment_types.first).to eq Payment::PAYMENT_TYPE_MEMBER
        end

        it 'only gets successful membership payments' do

          member_exp_jun_1_all_pay_statuses = create(:member_with_membership_app, first_name: 'Exp Jun 1 all payment statuses')

          # Data to test different payment statuses:
          payment_statuses = Payment::ORDER_PAYMENT_STATUS.values

          # Make 1 of each payment status
          payment_statuses.each do |payment_status|
            create(:h_branding_fee_payment,
                   status: payment_status,
                   user: member_exp_jun_1_all_pay_statuses,
                   expire_date: JUN_01)

            create(:membership_fee_payment,
                   status: payment_status,
                   user: member_exp_jun_1_all_pay_statuses,
                   expire_date: JUN_01)
          end


          expires_today = User.membership_expires_in_x_days(151)
          expect(expires_today.count).to eq 1
          expect(expires_today.pluck(:expire_date).uniq.first).to eq(JUN_01)
          expect(expires_today.pluck(:payment_type).uniq.first).to eq Payment::PAYMENT_TYPE_MEMBER
        end
      end


      describe 'company_hbrand_expires_in_x_days' do

        it 'x = 1 day, 0 days, -1 days' do

          # branding fees paid (only)
          member_only_branding_fees_exp_jan02 = create(:member_with_membership_app, first_name: 'Only Branding fees exp Jan 02')
          create(:h_branding_fee_payment, :successful,
                 user: member_only_branding_fees_exp_jan02,
                 expire_date: JAN_02)


          # both branding fee and membership fee paid on Jan 2:
          both_exp_jan02_1 = create(:member_with_membership_app, first_name: 'Both fees Exp jan02 1')
          create(:membership_fee_payment, :successful,
                 user: both_exp_jan02_1,
                 expire_date: JAN_02)
          create(:h_branding_fee_payment, :successful,
                 user: both_exp_jan02_1,
                 expire_date: JAN_02)

          # membership fees paid for a member
          create(:member_with_expiration_date, expiration_date: DEC_31_2018)
          create(:member_with_expiration_date, expiration_date: DEC_31_2018)
          create(:member_with_expiration_date, expiration_date: JAN_01)
          create(:member_with_expiration_date, expiration_date: JAN_02)
          create(:member_with_expiration_date, expiration_date: JAN_02)


          membership_expires_in_1_day = User.membership_expires_in_x_days(1)
          expect(membership_expires_in_1_day.count).to eq 3
          uniq_payment_types = membership_expires_in_1_day.pluck(:payment_type).uniq
          expect(uniq_payment_types.first).to eq Payment::PAYMENT_TYPE_MEMBER

          membership_expires_today = User.membership_expires_in_x_days(0)
          expect(membership_expires_today.count).to eq 1
          uniq_payment_types = membership_expires_today.pluck(:payment_type).uniq
          expect(uniq_payment_types.first).to eq Payment::PAYMENT_TYPE_MEMBER

          membership_expired_yesterday = User.membership_expires_in_x_days(-1)
          expect(membership_expired_yesterday.count).to eq 2
          uniq_payment_types = membership_expired_yesterday.pluck(:payment_type).uniq
          expect(uniq_payment_types.first).to eq Payment::PAYMENT_TYPE_MEMBER
        end

        it 'only gets successful h-branding fee payments' do

          member_exp_jun_1_all_pay_statuses = create(:member_with_membership_app, first_name: 'Exp Jun 1 all payment statuses')

          # Data to test different payment statuses:
          payment_statuses = Payment::ORDER_PAYMENT_STATUS.values

          # Make 1 of each payment status
          payment_statuses.each do |payment_status|
            create(:h_branding_fee_payment,
                   status: payment_status,
                   user: member_exp_jun_1_all_pay_statuses,
                   expire_date: JUN_01)

            create(:membership_fee_payment,
                   status: payment_status,
                   user: member_exp_jun_1_all_pay_statuses,
                   expire_date: JUN_01)
          end


          brandingfees_expires_in_151d = User.company_hbrand_expires_in_x_days(151)
          expect(brandingfees_expires_in_151d.count).to eq 1
          expect(brandingfees_expires_in_151d.pluck(:expire_date).uniq.first).to eq(JUN_01)
          expect(brandingfees_expires_in_151d.pluck(:payment_type).uniq.first).to eq Payment::PAYMENT_TYPE_BRANDING
        end
      end
    end

  end # Scopes


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


  describe '#member_fee_payment_due?' do

    describe 'is a member' do

      it 'true if membership is not current' do
        expect(member_expired.member_fee_payment_due?).to be_truthy
      end

      it 'false if membership is current' do
        expect(member_paid_up.member_fee_payment_due?).to be_falsey
      end
    end

    describe 'is not a member' do
      it 'is always false' do
        expect(create(:user).member_fee_payment_due?).to be_falsey
        expect(create(:user_with_membership_app).member_fee_payment_due?).to be_falsey
      end
    end

    describe 'admin' do
      it 'is always false' do
        expect(create(:admin).member_fee_payment_due?).to be_falsey
      end
    end
  end


  describe '#member_or_admin?' do

    it 'false for user: no application' do
      expect(create(:user).member_or_admin?).to be_falsey
    end

    it 'false for user: 1 saved application' do
      expect(create(:user_with_membership_app).member_or_admin?).to be_falsey
    end

    it 'true for member with 1 app' do
      expect(create(:member_with_membership_app).member_or_admin?).to be_truthy
    end

    it 'false for member with 0 apps (should not happen)' do
      expect(create(:user).member_or_admin?).to be_falsey
    end

    it 'true for admin' do
      expect(create(:admin).member_or_admin?).to be_truthy
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


  describe '#allowed_to_pay_hbrand_fee?' do

    it 'true if the admin' do
      admin = create(:admin)
      expect(admin.allowed_to_pay_hbrand_fee?(given_co)).to be_truthy
    end

    describe 'is a member' do

      it 'false if company number not in the app with 2 other companies' do
        member = create(:member_with_membership_app,
                        email: 'member-app-does-not-have-given-company@example.com',
                        company_number: other_co_num1)
        member.shf_application.companies << other_co2

        expect(member.allowed_to_pay_hbrand_fee?(given_co)).to be_falsey
      end

      it 'true if company number is in the app with 2 other companies' do
        member = create(:member_with_membership_app,
                        email: 'member-app-does-not-have-given-company@example.com',
                        company_number: other_co_num1)
        member.shf_application.companies << other_co2
        member.shf_application.companies << given_co

        expect(member.allowed_to_pay_hbrand_fee?(given_co)).to be_truthy
      end

    end


    describe 'not a member' do

      it 'false if no applications' do
        expect(build(:user).allowed_to_pay_hbrand_fee?(given_co)).to be_falsey
      end

      describe 'always false even if company_number in the app, no matter the state of the application' do

        let(:user_with_app) { create(:user, email: 'user-app-doesnt-have-given-co@example.com') }

        ShfApplication.all_states.each do |app_state|

          it "#{app_state} application state" do
            create(:shf_application,
                   user: user_with_app,
                   state: app_state,
                   company_number: given_co.company_number)

            expect(user_with_app.allowed_to_pay_hbrand_fee?(given_co)).to be_falsey
          end
        end
      end
    end
  end


  describe '#has_approved_app_for_company?' do

    describe 'not a member' do

      it 'false if no applications' do
        expect(build(:user).has_approved_app_for_company?(given_co)).to be_falsey
      end

      it 'false if company number not in accepted application (with 2 other companies)' do
        user_with_app = create(:user, email: 'user-app-doesnt-have-given-co@example.com')
        app1 = create(:shf_application,
                      :accepted,
                      user: user_with_app,
                      company_number: other_co_num1)
        app1.companies << other_co2

        expect(user_with_app.has_approved_app_for_company?(given_co)).to be_falsey
      end

      describe 'false if company in app but app not approved' do
        # TODO refactor:DRY up with the other loop that uses not_accepted_states
        # all states except ACCEPTED
        not_accepted_states = ShfApplication.all_states.reject { |state| state == ShfApplication::STATE_ACCEPTED }
        not_accepted_states.each do |app_state|

          it "false for state = #{app_state}" do
            user_with_app = create(:user, email: "user-#{app_state}@example.com")
            build(:shf_application,
                  user: user_with_app,
                  state: app_state,
                  company_number: given_co_num)
            expect(user_with_app.has_approved_app_for_company?(given_co)).to be_falsey
          end
        end
      end

      it 'true if company in app and most recent app is approved' do
        user_with_app = create(:user, email: 'user-app-approved-has-given-co@example.com')
        app1 = create(:shf_application,
                      :accepted,
                      user: user_with_app,
                      company_number: other_co_num1,
                      when_approved: jan_1)
        app1.companies << given_co

        expect(user_with_app.has_approved_app_for_company?(given_co)).to be_truthy
      end
    end


    describe 'is a member' do

      it 'false if company number not in the approved app with 2 other companies' do
        member = create(:member_with_membership_app,
                        email: 'member-app-does-not-have-given-company@example.com',
                        company_number: other_co_num1)
        member.shf_application.companies << other_co2

        expect(member.has_approved_app_for_company?(given_co)).to be_falsey
      end

      it 'false if company not in most recent approved app' do
        skip 'this test will be needed if/when a user has more than 1 application'
      end

      it 'true if company in most recent approved app' do
        member = create(:user, email: 'user-app-approved-has-given-co@example.com')
        app1 = create(:shf_application,
                      :accepted,
                      user: member,
                      company_number: other_co_num1,
                      when_approved: jan_1)
        app1.companies << given_co

        expect(member.has_approved_app_for_company?(given_co)).to be_truthy
      end
    end

  end


  describe '#has_app_for_company?' do

    describe 'not a member' do

      it 'false if no applications' do
        expect(build(:user).has_app_for_company?(given_co)).to be_falsey
      end

      describe 'false if company not in application (with 2 other companies)' do
        let(:user_with_app) { create(:user, email: 'user-app-doesnt-have-given-co@example.com') }

        ShfApplication.all_states.each do |app_state|
          it "#{app_state} application state" do
            app1 = create(:shf_application,
                          user: user_with_app,
                          state: app_state,
                          company_number: other_co_num1)
            app1.companies << other_co2

            expect(user_with_app.has_app_for_company?(given_co)).to be_falsey
          end
        end
      end


      describe 'true if company not in application (with 2 other companies)' do
        let(:user_with_app) { create(:user, email: 'user-app-has-given-company@example.com') }

        ShfApplication.all_states.each do |app_state|
          it "#{app_state} application state" do
            app1 = create(:shf_application,
                          user: user_with_app,
                          state: app_state,
                          company_number: given_co_num)
            app1.companies << other_co1
            app1.companies << other_co2

            expect(user_with_app.has_app_for_company?(given_co)).to be_truthy
          end
        end
      end

    end

    describe 'is a member' do

      it 'false if company not in the app with 2 other companies' do
        member = create(:member_with_membership_app,
                        email: 'member-app-does-not-have-given-company@example.com',
                        company_number: other_co_num1)
        member.shf_application.companies << other_co2

        expect(member.has_app_for_company?(given_co)).to be_falsey
      end

      it 'true if company is in the app with 2 other companies' do
        member = create(:member_with_membership_app,
                        email: 'member-app-does-not-have-given-company@example.com',
                        company_number: other_co_num1)
        member.shf_application.companies << other_co2
        member.shf_application.companies << given_co

        expect(member.has_app_for_company?(given_co)).to be_truthy
      end
    end

  end


  describe '#has_app_for_company_number?' do

    describe 'not a member' do

      it 'false if no applications' do
        expect(build(:user).has_app_for_company_number?(given_co_num)).to be_falsey
      end

      describe 'false if company number not in application (with 2 other companies)' do
        let(:user_with_app) { create(:user, email: 'user-app-doesnt-have-given-co@example.com') }

        ShfApplication.all_states.each do |app_state|
          it "#{app_state} application state" do
            app1 = create(:shf_application,
                          user: user_with_app,
                          state: app_state,
                          company_number: other_co_num1)
            app1.companies << other_co2

            expect(user_with_app.has_app_for_company_number?(given_co_num)).to be_falsey
          end
        end
      end


      describe 'true if company number not in application (with 2 other companies)' do
        let(:user_with_app) { create(:user, email: 'user-app-has-given-company@example.com') }

        ShfApplication.all_states.each do |app_state|
          it "#{app_state} application state" do
            app1 = create(:shf_application,
                          user: user_with_app,
                          state: app_state,
                          company_number: given_co_num)
            app1.companies << other_co1
            app1.companies << other_co2

            expect(user_with_app.has_app_for_company_number?(given_co_num)).to be_truthy
          end
        end
      end

    end

    describe 'is a member' do

      it 'false if company number not in the app with 2 other companies' do
        member = create(:member_with_membership_app,
                        email: 'member-app-does-not-have-given-company@example.com',
                        company_number: other_co_num1)
        member.shf_application.companies << other_co2

        expect(member.has_app_for_company_number?(given_co_num)).to be_falsey
      end

      it 'true if company number is in the app with 2 other companies' do
        member = create(:member_with_membership_app,
                        email: 'member-app-does-not-have-given-company@example.com',
                        company_number: other_co_num1)
        member.shf_application.companies << other_co2
        member.shf_application.companies << given_co

        expect(member.has_app_for_company_number?(given_co_num)).to be_truthy
      end
    end

  end


  describe '#apps_for_company' do

  end


  describe '#apps_for_company_number' do

    it 'empty list if no application' do
      expect(build(:user).apps_for_company_number(given_co_num)).to be_empty
    end

    it 'empty list if no applications have the company number' do
      user_with_app = create(:user, email: 'user-app-doesnt-have-given-co@example.com')
      app1 = create(:shf_application,
                    user: user_with_app,
                    state: :new,
                    company_number: other_co_num1)
      app1.companies << other_co2
      expect(user_with_app.apps_for_company_number(given_co_num)).to be_empty
    end

    it 'list of applications with the company number' do
      user_with_app = create(:user, email: 'user-app-doesnt-have-given-co@example.com')
      app1 = create(:shf_application,
                    user: user_with_app,
                    state: :new,
                    company_number: other_co_num1)
      app1.companies << given_co
      expect(user_with_app.apps_for_company_number(given_co_num).to_a).to match_array([app1])
    end
  end


  describe '#sort_apps_by_when_approved' do

    it 'apps are sorted by when_approved date, furthest in the future is first' do
      app_approved_jan1 = create(:shf_application, :accepted, when_approved: jan_1)
      app_approved_jan2 = create(:shf_application, :accepted, when_approved: jan_2)
      app_approved_jan3 = create(:shf_application, :accepted, when_approved: jan_3)

      apps = [app_approved_jan1, app_approved_jan2, app_approved_jan3]
      sorted_apps = apps.sort(&subject.sort_apps_by_when_approved)
      expect(sorted_apps.first.when_approved).to eq jan_3
      expect(sorted_apps.last.when_approved).to eq jan_1
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


  describe '#has_full_name?' do

    it 'true if both first and last name are present' do
      expect(build(:user, first_name: 'First', last_name: 'Last').has_full_name?).to be_truthy
    end

    it 'false if first name is blank or nil' do
      expect(build(:user, first_name: '', last_name: 'Last').has_full_name?).to be_falsey
      expect(build(:user, first_name: nil, last_name: 'Last').has_full_name?).to be_falsey
    end

    it 'false if last name is blank or nil' do
      expect(build(:user, first_name: 'First', last_name: '').has_full_name?).to be_falsey
      expect(build(:user, first_name: 'First', last_name: nil).has_full_name?).to be_falsey
    end
  end


  context 'payment and membership period' do

    describe '#membership_start_date' do
      it 'returns the start_date for latest completed payment' do
        member_payment1
        expect(user.membership_start_date).to eq member_payment1.start_date
        member_payment2
        expect(user.membership_start_date).to eq member_payment2.start_date
      end
    end


    describe '#membership_expire_date' do
      it 'returns the expire_date for latest completed payment' do
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


    describe '.next_membership_payment_date' do

      around(:each) do |example|
        Timecop.freeze(payment_date_2018_11_21)
        example.run
        Timecop.return
      end

      it "returns today's date for first payment start date" do
        expect(User.next_membership_payment_date(user.id)).to eq Time.zone.today
      end

      it 'returns date-after-expiration for second payment start date' do
        member_payment1
        expect(User.next_membership_payment_date(user.id))
            .to eq Time.zone.today + 1.year
      end


      context 'if next payment occurs after prior payment expire date' do

        it 'returns actual payment date for start date' do
          # User renews membership (pays fee) *after* the prior payment has expired.
          # In this case, the new payment period starts on the day of payment (2020/03/15).
          member_payment1
          Timecop.freeze(payment_date_2020_03_15)

          payment_start_date = User.next_membership_payment_date(user.id)

          expect(payment_start_date).to eq payment_date_2020_03_15
        end

      end
    end


    describe '.next_membership_payment_dates' do

      around(:each) do |example|
        Timecop.freeze(payment_date_2018_11_21)
        example.run
        Timecop.return
      end

      it "returns today's date for first payment start date" do
        expect(User.next_membership_payment_dates(user.id)[0]).to eq Time.zone.today
      end

      # FIXME it returns one year MINUS 1 DAY
      it 'returns one year later for first payment expire date' do
        expect(User.next_membership_payment_dates(user.id)[1])
            .to eq Time.zone.today + 1.year - 1.day
      end

      it 'returns date-after-expiration for second payment start date' do
        member_payment1
        expect(User.next_membership_payment_dates(user.id)[0])
            .to eq Time.zone.today + 1.year
      end

      # FIXME returns one year MINUS 1 DAY
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

  end


  describe '#allowed_to_pay_member_fee?' do

    it 'false if the user is an admin' do
      expect(create(:admin).allowed_to_pay_member_fee?).to be_falsey
    end

    context 'not an admin' do

      it 'true if is a member' do
        user.member = true
        user.save
        expect(user.allowed_to_pay_member_fee?).to be_truthy
      end

      describe 'not a member == is a user (is an applicant)' do

        context 'does not have to agree to membership guidelines' do

          context 'has not agreed to all membership guidelines' do

            it 'true if user has app in "accepted" state' do
              allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?).and_return(true)

              expect(applicant_approved_no_payments.allowed_to_pay_member_fee?).to be_truthy
            end

            describe 'false for an application in any other state' do

              ShfApplication.all_states.reject { |s| s == ShfApplication::STATE_ACCEPTED }.each do |app_state|
                it "#{app_state} is false" do
                  allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?).and_return(false)

                  app = create(:shf_application, state: app_state)
                  expect(app.user.allowed_to_pay_member_fee?).to be_falsey
                end
              end
            end
          end
        end


        context 'does have to agree to membership guidelines' do

          context 'has agreed to all membership guidelines' do

            let(:user_agreed_to_guidelines) do
              u = create(:user)
              create(:membership_guidelines_master_checklist)
              AdminOnly::UserChecklistFactory.create_member_guidelines_checklist_for(u)
              UserChecklistManager.membership_guidelines_list_for(u).set_complete_including_children
              u
            end

            it 'true if user has app in "accepted" state' do
              allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?).and_return(true)

              create(:shf_application, :accepted, user: user_agreed_to_guidelines)
              expect(user_agreed_to_guidelines.allowed_to_pay_member_fee?).to be_truthy
            end

            describe 'false for an application in any other state' do

              ShfApplication.all_states.reject { |s| s == ShfApplication::STATE_ACCEPTED }.each do |app_state|
                it "#{app_state} is false" do
                  allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?).and_return(true)

                  app = create(:shf_application, state: app_state, user: user_agreed_to_guidelines)
                  expect(app.user.allowed_to_pay_member_fee?).to be_falsey
                end
              end
            end
          end

          context 'has not agreed to all membership guidelines' do

            describe 'false for all application states (even accepted)' do
              ShfApplication.all_states.each do |app_state|
                it "#{app_state} is false" do
                  allow(UserChecklistManager).to receive(:must_complete_membership_guidelines_checklist?).and_return(true)

                  app = create(:shf_application, state: app_state)
                  expect(app.user.allowed_to_pay_member_fee?).to be_falsey
                end
              end
            end
          end
        end
      end

    end
  end


  describe 'membership_current? just checks membership payment status' do

    context 'membership payments have not expired yet' do

      let(:paid_member) {
        member = create(:member_with_membership_app)
        create(:membership_fee_payment,
               :successful,
               user: member,
               start_date: jan_1,
               expire_date: User.expire_date_for_start_date(jan_1))
        member
      }

      it 'true if today = dec 1, start = jan 1, expire = dec 31' do
        Timecop.freeze(dec_1) do
          expect(paid_member.membership_expire_date).to eq dec_31
          expect(paid_member.membership_current?).to be_truthy
        end # Timecop
      end

    end


    context 'testing dates right before, on, and after expire_date' do

      let(:paid_expires_today_member) {
        member = create(:member_with_membership_app)
        create(:membership_fee_payment,
               :successful,
               user: member,
               start_date: lastyear_dec_3,
               expire_date: User.expire_date_for_start_date(lastyear_dec_3))
        member
      }

      it 'true if today = nov 30, start = dec 3 last year, expire = dec 2' do
        Timecop.freeze(nov_30) do
          expect(paid_expires_today_member.membership_expire_date).to eq dec_2
          expect(paid_expires_today_member.membership_current?).to be_truthy
        end # Timecop
      end

      it 'true if today = dec 1, start = dec 3 last year, expire = dec 2' do
        Timecop.freeze(dec_1) do
          expect(paid_expires_today_member.membership_expire_date).to eq dec_2
          expect(paid_expires_today_member.membership_current?).to be_truthy
        end # Timecop
      end

      it 'false if today = dec 2, start = dec 3 last year, expire = dec 2' do
        Timecop.freeze(dec_2) do
          expect(paid_expires_today_member.membership_expire_date).to eq dec_2
          expect(paid_expires_today_member.membership_current?).to be_falsey
        end # Timecop
      end

      it 'false today = dec 3, start = dec 3 last year, expire = dec 2' do
        Timecop.freeze(dec_3) do
          expect(paid_expires_today_member.membership_expire_date).to eq dec_2
          expect(paid_expires_today_member.membership_current?).to be_falsey
        end # Timecop
      end

    end

  end


  describe 'membership_current_as_of? checks membership payment status as of a given date' do

    it 'is false if nil is the given date' do
      expect((create :user).membership_current_as_of?(nil)).to be_falsey
    end


    context 'membership payments have not expired yet' do

      let(:paid_member) {
        member = create(:member_with_membership_app)
        create(:membership_fee_payment,
               :successful,
               user: member,
               start_date: jan_1,
               expire_date: User.expire_date_for_start_date(jan_1))
        member
      }

      it 'true as of dec 1, start = jan 1, expire = dec 31' do
        expect(paid_member.membership_expire_date).to eq dec_31
        expect(paid_member.membership_current_as_of?(dec_1)).to be_truthy
      end

    end


    context 'testing dates right before, on, and after expire_date' do

      let(:paid_expires_today_member) {
        member = create(:member_with_membership_app)
        create(:membership_fee_payment,
               :successful,
               user: member,
               start_date: lastyear_dec_3,
               expire_date: User.expire_date_for_start_date(lastyear_dec_3))
        member
      }

      it 'true as of nov 30, start = dec 3 last year, expire = dec 2' do
        expect(paid_expires_today_member.membership_expire_date).to eq dec_2
        expect(paid_expires_today_member.membership_current_as_of?(nov_30)).to be_truthy
      end

      it 'true as of dec 1, start = dec 3 last year, expire = dec 2' do
        expect(paid_expires_today_member.membership_expire_date).to eq dec_2
        expect(paid_expires_today_member.membership_current_as_of?(dec_1)).to be_truthy
      end

      it 'false as of dec 2, start = dec 3 last year, expire = dec 2' do
        expect(paid_expires_today_member.membership_expire_date).to eq dec_2
        expect(paid_expires_today_member.membership_current_as_of?(dec_2)).to be_falsey
      end

      it 'false today = dec 3, start = dec 3 last year, expire = dec 2' do
        expect(paid_expires_today_member.membership_expire_date).to eq dec_2
        expect(paid_expires_today_member.membership_current_as_of?(dec_3)).to be_falsey
      end

    end

  end


  describe 'membership_app_and_payments_current?  checks both application and membership payment status' do

    context 'has an approved application' do

      context 'membership payments have not expired yet' do

        let(:paid_member) {
          member = create(:member_with_membership_app)
          create(:membership_fee_payment,
                 :successful,
                 user: member,
                 start_date: jan_1,
                 expire_date: User.expire_date_for_start_date(jan_1))
          member
        }

        context 'today is dec 1' do

          it 'true if start = jan 1, expire = dec 3' do
            Timecop.freeze(dec_1) do
              expect(paid_member.membership_expire_date).to eq dec_31
              expect(paid_member.membership_app_and_payments_current?).to be_truthy
            end
          end

          it 'is == membership_current?' do
            Timecop.freeze(dec_1) do
              expect(paid_member.membership_app_and_payments_current?).to eq(paid_member.membership_current?)
            end
          end

        end # context 'today is dec 1'

      end


      context 'testing dates right before, on, and after expire_date' do

        let(:paid_expires_today_member) {
          member = create(:member_with_membership_app)
          create(:membership_fee_payment,
                 :successful,
                 user: member,
                 start_date: lastyear_dec_3,
                 expire_date: User.expire_date_for_start_date(lastyear_dec_3))
          member
        }

        context 'today is nov 30' do
          it 'true if today = nov 30, start = dec 3 last year, expire = dec 2' do
            Timecop.freeze(nov_30) do
              expect(paid_expires_today_member.membership_expire_date).to eq dec_2
              expect(paid_expires_today_member.membership_app_and_payments_current?).to be_truthy
            end # Timecop
          end
          it 'is == membership_current?' do
            Timecop.freeze(nov_30) do
              expect(paid_expires_today_member.membership_app_and_payments_current?).to eq(paid_expires_today_member.membership_current?)
            end
          end
        end # context 'today is nov 30'

        context 'today is dec 1' do
          it 'true if today = dec 1, start = dec 3 last year, expire = dec 2' do
            Timecop.freeze(dec_1) do
              expect(paid_expires_today_member.membership_expire_date).to eq dec_2
              expect(paid_expires_today_member.membership_app_and_payments_current?).to be_truthy
            end # Timecop
          end
          it 'is == membership_current?' do
            Timecop.freeze(dec_1) do
              expect(paid_expires_today_member.membership_app_and_payments_current?).to eq(paid_expires_today_member.membership_current?)
            end
          end
        end # context 'today is dec 1'

        context 'today is dec 2' do
          it 'false if today = dec 2, start = dec 3 last year, expire = dec 2' do
            Timecop.freeze(dec_2) do
              expect(paid_expires_today_member.membership_expire_date).to eq dec_2
              expect(paid_expires_today_member.membership_app_and_payments_current?).to be_falsey
            end # Timecop
          end
          it 'is == membership_current?' do
            Timecop.freeze(dec_2) do
              expect(paid_expires_today_member.membership_app_and_payments_current?).to eq(paid_expires_today_member.membership_current?)
            end
          end
        end # context 'today is dec 2'

        context 'today is dec 3' do
          it 'false today = dec 3, start = dec 3 last year, expire = dec 2' do
            Timecop.freeze(dec_3) do
              expect(paid_expires_today_member.membership_expire_date).to eq dec_2
              expect(paid_expires_today_member.membership_app_and_payments_current?).to be_falsey
            end # Timecop
          end
          it 'is == membership_current?' do
            Timecop.freeze(dec_3) do
              expect(paid_expires_today_member.membership_app_and_payments_current?).to eq(paid_expires_today_member.membership_current?)
            end
          end
        end # context 'today is dec 2'

      end # context 'testing dates right before, on, and after expire_date'

    end #  context 'has an approved application'


    context 'does NOT have an approved application - is always FALSE' do

      context 'membership payments have not expired yet' do

        let(:paid_no_app) {
          user = create(:user_with_membership_app) # not approved; not a member Maybe it was later rejected
          create(:membership_fee_payment,
                 :successful,
                 user: user,
                 start_date: jan_1,
                 expire_date: User.expire_date_for_start_date(jan_1))
          user
        }

        it 'false if today = dec 1, start = jan 1, expire = dec 31' do
          Timecop.freeze(dec_1) do
            expect(paid_no_app.membership_expire_date).to eq dec_31
            expect(paid_no_app.membership_app_and_payments_current?).to be_falsey
          end # Timecop
        end

      end


      context 'testing dates right before, on, and after expire_date' do

        let(:no_app_expires_today) {
          user = create(:user_with_membership_app) # not approved; not a member Maybe it was later rejected
          create(:membership_fee_payment,
                 :successful,
                 user: user,
                 start_date: lastyear_dec_3,
                 expire_date: User.expire_date_for_start_date(lastyear_dec_3))
          user
        }

        it 'false if today = nov 30, start = dec 3 last year, expire = dec 2' do
          Timecop.freeze(nov_30) do
            expect(no_app_expires_today.membership_expire_date).to eq dec_2
            expect(no_app_expires_today.membership_app_and_payments_current?).to be_falsey
          end # Timecop
        end

        it 'false if today = dec 1, start = dec 3 last year, expire = dec 2' do
          Timecop.freeze(dec_1) do
            expect(no_app_expires_today.membership_expire_date).to eq dec_2
            expect(no_app_expires_today.membership_app_and_payments_current?).to be_falsey
          end # Timecop
        end

        it 'false if today = dec 2, start = dec 3 last year, expire = dec 2' do
          Timecop.freeze(dec_2) do
            expect(no_app_expires_today.membership_expire_date).to eq dec_2
            expect(no_app_expires_today.membership_app_and_payments_current?).to be_falsey
          end # Timecop
        end

        it 'false today = dec 3, start = dec 3 last year, expire = dec 2' do
          Timecop.freeze(dec_3) do
            expect(no_app_expires_today.membership_expire_date).to eq dec_2
            expect(no_app_expires_today.membership_app_and_payments_current?).to be_falsey
          end # Timecop
        end

      end

    end

  end


  describe 'membership_app_and_payments_current_as_of?  checks both application and membership payment status as of a given date' do

    it 'is false if nil is the given date' do
      expect((create :user).membership_app_and_payments_current_as_of?(nil)).to be_falsey
    end


    context 'has an approved application' do

      context 'membership payments have not expired yet' do

        let(:paid_member) {
          member = create(:member_with_membership_app)
          create(:membership_fee_payment,
                 :successful,
                 user: member,
                 start_date: jan_1,
                 expire_date: User.expire_date_for_start_date(jan_1))
          member
        }

        it 'true if today = dec 1, start = jan 1, expire = dec 31' do
          expect(paid_member.membership_expire_date).to eq dec_31
          expect(paid_member.membership_app_and_payments_current_as_of?(dec_1)).to be_truthy
        end

        it 'is == membership_current_as_of?' do
          expect(paid_member.membership_app_and_payments_current_as_of?(dec_1)).to eq(paid_member.membership_current_as_of?(dec_1))
        end

      end # context 'membership payments have not expired yet'


      context 'testing dates right before, on, and after expire_date' do

        let(:paid_expires_today_member) {
          member = create(:member_with_membership_app)
          create(:membership_fee_payment,
                 :successful,
                 user: member,
                 start_date: lastyear_dec_3,
                 expire_date: User.expire_date_for_start_date(lastyear_dec_3))
          member
        }

        context 'as of nov 30' do
          it 'true if start = dec 3 last year, expire = dec 2' do
            expect(paid_expires_today_member.membership_expire_date).to eq dec_2
            expect(paid_expires_today_member.membership_app_and_payments_current_as_of?(nov_30)).to be_truthy
          end
          it 'is == membership_current_as_of?(nov 30)' do
            expect(paid_expires_today_member.membership_app_and_payments_current_as_of?(nov_30)).to eq(paid_expires_today_member.membership_current_as_of?(nov_30))
          end
        end

        context 'as of dec 1' do
          it 'true if start = dec 3 last year, expire = dec 2' do
            expect(paid_expires_today_member.membership_expire_date).to eq dec_2
            expect(paid_expires_today_member.membership_app_and_payments_current_as_of?(dec_1)).to be_truthy
          end
          it 'is == membership_current_as_of?(dec 1)' do
            expect(paid_expires_today_member.membership_app_and_payments_current_as_of?(dec_1)).to eq(paid_expires_today_member.membership_current_as_of?(dec_1))
          end
        end

        context 'as of dec 2' do
          it 'false if today = dec 2, start = dec 3 last year, expire = dec 2' do
            expect(paid_expires_today_member.membership_expire_date).to eq dec_2
            expect(paid_expires_today_member.membership_app_and_payments_current_as_of?(dec_2)).to be_falsey
          end
          it 'is == membership_current_as_of?(dec 2)' do
            expect(paid_expires_today_member.membership_app_and_payments_current_as_of?(dec_2)).to eq(paid_expires_today_member.membership_current_as_of?(dec_2))
          end
        end

        context 'as of dec 3' do
          it 'false today = dec 3, start = dec 3 last year, expire = dec 2' do
            expect(paid_expires_today_member.membership_expire_date).to eq dec_2
            expect(paid_expires_today_member.membership_app_and_payments_current_as_of?(dec_3)).to be_falsey
          end
          it 'is == membership_current_as_of?(dec 3)' do
            expect(paid_expires_today_member.membership_app_and_payments_current_as_of?(dec_3)).to eq(paid_expires_today_member.membership_current_as_of?(dec_3))
          end
        end


      end # context 'testing dates right before, on, and after expire_date'

    end # context 'has an approved application'


    context 'does NOT have an approved application: is always FALSE' do

      context 'membership payments have not expired yet' do

        let(:paid_no_app) {
          user = create(:user_with_membership_app) # not approved; not a member Maybe it was later rejected
          create(:membership_fee_payment,
                 :successful,
                 user: user,
                 start_date: jan_1,
                 expire_date: User.expire_date_for_start_date(jan_1))
          user
        }

        it 'false as of dec 1, start = jan 1, expire = dec 31' do
          expect(paid_no_app.membership_expire_date).to eq dec_31
          expect(paid_no_app.membership_app_and_payments_current_as_of?(dec_1)).to be_falsey
        end

      end # context 'membership payments have not expired yet'


      context 'testing dates right before, on, and after expire_date' do

        let(:no_app_expires_today) {
          user = create(:user_with_membership_app) # not approved; not a member Maybe it was later rejected
          create(:membership_fee_payment,
                 :successful,
                 user: user,
                 start_date: lastyear_dec_3,
                 expire_date: User.expire_date_for_start_date(lastyear_dec_3))
          user
        }

        it 'false as of nov 30, start = dec 3 last year, expire = dec 2' do
          expect(no_app_expires_today.membership_expire_date).to eq dec_2
          expect(no_app_expires_today.membership_app_and_payments_current_as_of?(nov_30)).to be_falsey
        end

        it 'false as of dec 1, start = dec 3 last year, expire = dec 2' do
          expect(no_app_expires_today.membership_expire_date).to eq dec_2
          expect(no_app_expires_today.membership_app_and_payments_current_as_of?(dec_1)).to be_falsey
        end

        it 'false as of dec 2, start = dec 3 last year, expire = dec 2' do
          expect(no_app_expires_today.membership_expire_date).to eq dec_2
          expect(no_app_expires_today.membership_app_and_payments_current_as_of?(dec_2)).to be_falsey
        end

        it 'false as of dec 3, start = dec 3 last year, expire = dec 2' do
          expect(no_app_expires_today.membership_expire_date).to eq dec_2
          expect(no_app_expires_today.membership_app_and_payments_current_as_of?(dec_3)).to be_falsey
        end

      end # context 'testing dates right before, on, and after expire_date'

    end # context 'does NOT have an approved application - is always FALSE'

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


  describe '#membership_packet_sent?' do

    it 'true if there is a date' do
      user_sent_package = create(:user, date_membership_packet_sent: Date.current)
      expect(user_sent_package.membership_packet_sent?).to be_truthy
    end

    it 'false if there is no date' do
      user_sent_package = create(:user, date_membership_packet_sent: nil)
      expect(user_sent_package.membership_packet_sent?).to be_falsey
    end
  end


  describe '#toggle_membership_packet_status' do

    let(:user_sent_package) { create(:user, date_membership_packet_sent: nil) }

    it 'default date_sent is Timezone now' do

      frozen_time = Time.new(2020, 10, 31, 2, 2, 2)
      Timecop.freeze(frozen_time) do
        user_sent_package.toggle_membership_packet_status
      end

      expect(user_sent_package.date_membership_packet_sent).to eq frozen_time
    end


    it 'can set the date_sent' do
      set_date = Time.new(2020, 02, 02, 2, 2, 2)
      user_sent_package.toggle_membership_packet_status(set_date)
      expect(user_sent_package.date_membership_packet_sent).to eq set_date
    end


    it 'if it has been sent, now it is set to unsent' do
      user_sent_package.update(date_membership_packet_sent: Time.now)
      user_sent_package.toggle_membership_packet_status
      expect(user_sent_package.date_membership_packet_sent).to be_nil
    end


    it 'if it has not been sent, it is set to sent' do
      user_sent_package.update(date_membership_packet_sent: nil)
      user_sent_package.toggle_membership_packet_status
      expect(user_sent_package.date_membership_packet_sent).not_to be_nil
    end

  end

end
