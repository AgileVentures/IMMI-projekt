require 'rails_helper'
require 'email_spec/rspec'
require 'shared_context/unstub_paperclip_all_run_commands'
require 'shared_context/users'
require 'shared_context/named_dates'

# ================================================================================

# TODO stub, mock, and use doubles as much as possible.  Ex: AdminOnly::FileDeliveryMethod, Address, etc.

RSpec.describe User, type: :model do

  # These are required to get the content type and validate it
  include_context 'unstub Paperclip all run commands'

  include_context 'create users'
  include_context 'named dates'

  before(:each) do
    allow_any_instance_of(Paperclip::Attachment).to receive(:post_process_file)
                                                      .with(any_args)
                                                      .and_call_original

    # ensure this isn't mocked/stubbed to some odd length by default
    # so that all calulations and expectations are correct
    allow(Membership).to receive(:term_length).and_return(1.year)

    # don't generate or send any emails when membership status is changed
    allow(Memberships::MembershipActions).to receive(:do_send_email)
                                              .and_return(false)
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

  describe 'Factories' do
    it 'has valid factories' do
      expect(build(:user)).to be_valid
      expect(build(:user_without_first_and_lastname)).to be_valid
      expect(build(:user_with_membership_app)).to be_valid
      expect(build(:user_with_membership_app)).to be_valid
      expect(build(:member)).to be_valid
      expect(build(:member_with_membership_app)).to be_valid
      expect(build(:member_with_expiration_date)).to be_valid
    end


    describe 'member_with_membership_app' do
      it 'creates the application, a membership, ethical guidelines checklist, and sets membership_status to current_member' do
        orig_num_memberships = Membership.count
        orig_num_shf_apps = ShfApplication.count

        new_member = create(:member_with_membership_app)

        expect(Membership.count).to eq(orig_num_memberships + 1)
        expect(ShfApplication.count).to eq(orig_num_shf_apps + 1)
        expect(new_member.current_member?).to be_truthy
      end

      describe 'member_with_expiration_date' do
        it 'creates a membership with last day = expiration date' do
          expiry = Date.current + 100
          new_member = create(:member_with_expiration_date, expiration_date: expiry)
          expect(MembershipsManager.new.most_recent_membership(new_member).last_day).to eq(expiry)
        end

        it 'sets membership status to current_member if the member has a Membership that covers Date.current' do
          expiry = Date.current  - 1
          new_member = create(:member_with_expiration_date, expiration_date: expiry)
          expect(new_member.current_member?).to be_falsey
        end

        it 'creates an uploaded file for the current membership term (default)' do
          member = create(:member_with_expiration_date)
          expect(member.uploaded_files.size > 0).to be_truthy
          expect(member.shf_application.uploaded_files_count).to eq 0  # The file was not associated with an ShfApplication
        end

        context 'has_uploaded_docs is false' do
          it 'does not create an uploaded file for the current membership term' do
            member = create(:member_with_expiration_date, has_uploaded_docs: false)
            expect(member.uploaded_files.size > 0).to be_falsey
            expect(member.shf_application.uploaded_files_count).to eq 0  # The file was not associated with an ShfApplication
          end
        end
      end
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
    it { is_expected.to have_db_column :membership_status }
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
    it { is_expected.to have_many :uploaded_files }
    it { is_expected.to have_one(:shf_application).dependent(:destroy) }
    it { is_expected.to have_many(:payments).dependent(:nullify) }
    it { is_expected.to accept_nested_attributes_for(:payments) }
    it { is_expected.to have_attached_file(:member_photo) }
    it { is_expected.to have_many(:companies).through(:shf_application) }
    it { is_expected.to accept_nested_attributes_for(:shf_application)
                          .allow_destroy(false).update_only(true) }
    it { is_expected.to have_many :memberships }
  end

  describe 'Admin' do
    subject { create(:user, admin: true) }

    it { is_expected.to be_admin }
    it { is_expected.not_to be_member }
  end

  describe 'User' do
    subject { build(:user, admin: false) }

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

    describe 'membership application' do
      it 'user with application' do
        expect { user_with_app }.to change(ShfApplication, :count).by(1)
        expect { user_with_app.destroy }.to change(ShfApplication, :count).by(-1)
      end

      it 'member' do
        expect { member }.to change(ShfApplication, :count).by(1)
        expect { member.destroy }.to change(ShfApplication, :count).by(-1)
      end
    end

    describe 'payments are NOT deleted if a user is deleted' do

      describe 'membership payments' do
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

      describe 'h-branding (h-markt licensing) payments' do

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


    it 'memberships are archived before they are deleted' do
      member = create(:member_with_membership_app)
      expect(MembershipsManager).to receive(:create_archived_memberships_for)
                                              .with(member)
      member.destroy
    end
  end


  describe 'Scopes' do

    context 'with known user info' do
      let!(:user_no_app) { create(:user) }
      let!(:user_app_not_accepted) { create(:user_with_membership_app) }

      let!(:user_app_guidelines_not_agreed) { create(:user_with_ethical_guidelines_checklist) }

      let!(:user_app_guidelines_agreed) do
        u = create(:user_with_ethical_guidelines_checklist)
        UserChecklistManager.membership_guidelines_list_for(u).set_complete_including_children
        u
      end

      let!(:member_exp_jan1_today) { create(:member, expiration_date: jan_1) }
      let!(:member_current_exp_jan2) { create(:member, expiration_date: jan_2) }
      let!(:member_current_exp_jan3) { create(:member, expiration_date: jan_3) }

      it 'application_accepted' do
        in_scope = described_class.application_accepted
        app_states = in_scope.map { |member| member.shf_application.state }.uniq
        expect(app_states).to match_array([ShfApplication::STATE_ACCEPTED.to_s])
      end

      it 'membership_payment_current' do
        travel_to(jan_1) do
          in_scope = described_class.membership_payment_current
          expires_dates = in_scope.map { |member| member.most_recent_membership_payment.expire_date }.uniq
          payments_expire_today_or_before = expires_dates.select { |date| date <= Date.current }
          payments_expire_after_today = expires_dates.select { |date| date > Date.current }

          expect(payments_expire_today_or_before).to be_empty
          expect(payments_expire_after_today).to match_array([jan_2, jan_3])
        end
      end

      it 'agreed_to_membership_guidelines' do
        in_scope = described_class.agreed_to_membership_guidelines
        expect(in_scope.count).to eq(4)
        expect(in_scope.map(&:email)).to match_array([user_app_guidelines_agreed.email,
                                                      member_exp_jan1_today.email,
                                                      member_current_exp_jan2.email,
                                                      member_current_exp_jan3.email])
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

    it 'returns one year - 1 day later for first payment expire date' do
      expect(User.next_membership_payment_dates(user.id)[1])
        .to eq Time.zone.today + 1.year - 1.day
    end

    it 'returns date-after-expiration for second payment start date' do
      member_payment1
      expect(User.next_membership_payment_dates(user.id)[0])
        .to eq Time.zone.today + 1.year
    end


    it 'returns one year - 1 day later for second payment expire date' do
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


  describe 'current_membership' do
    it 'calls MembershipsManager to get the oldest membership covering Date.current (today)' do
      expect(user.memberships_manager).to receive(:membership_on)
                                            .with(user, Date.current)
      user.current_membership
    end
  end


  describe 'proof-of-membership JPG cache management' do
    let(:user2) { create(:user) }

    before(:each) { Rails.cache.clear(user.cache_key('pom')) }

    it { expect(user.cache_key('pom')).to eq "user_#{user.id}_cache_pom" }

   describe 'proof_of_membership_jpg' do
      it 'returns nil if no cached image' do
        expect(user.proof_of_membership_jpg).to be_nil
      end

      it 'returns cached image if present' do
        Rails.cache.write(user.cache_key('pom'), file_fixture('image.png'))
        expect(user.proof_of_membership_jpg).to_not be_nil
        expect(user.proof_of_membership_jpg).to eq file_fixture('image.png')
      end
    end

   describe 'proof_of_membership_jpg=' do
      it 'caches image' do
        expect(user.proof_of_membership_jpg).to be_nil
        user.proof_of_membership_jpg = file_fixture('image.png')
        expect(user.proof_of_membership_jpg).to_not be_nil
        expect(user.proof_of_membership_jpg).to eq file_fixture('image.png')
      end
    end

   describe 'clear_proof_of_membership_jpg_cache' do
      it 'clears cache' do
        user.proof_of_membership_jpg = file_fixture('image.png')
        expect(user.proof_of_membership_jpg).to_not be_nil
        user.clear_proof_of_membership_jpg_cache
        expect(user.proof_of_membership_jpg).to be_nil
      end
    end

    describe '.clear_all_proof_of_membership_jpg_caches' do
      it 'clears image cache for all users' do
        user.proof_of_membership_jpg = file_fixture('image.png')
        user2.proof_of_membership_jpg = file_fixture('image.png')
        expect(user.proof_of_membership_jpg).to_not be_nil
        expect(user2.proof_of_membership_jpg).to_not be_nil
        User.clear_all_proof_of_membership_jpg_caches
        expect(user.proof_of_membership_jpg).to be_nil
        expect(user2.proof_of_membership_jpg).to be_nil
      end
    end

    describe 'after_update :clear_proof_of_membership_jpg_cache' do
      it 'is called if member_photo_file_name changes' do
        expect(user).to receive(:clear_proof_of_membership_jpg_cache).once
        user.update_attributes(member_photo_file_name: 'new_file_name.jpg')
      end
      it 'is called if first_name changes' do
        expect(user).to receive(:clear_proof_of_membership_jpg_cache).once
        user.update_attributes(first_name: 'fred')
      end
      it 'is called if last_name changes' do
        expect(user).to receive(:clear_proof_of_membership_jpg_cache).once
        user.update_attributes(last_name: 'flintstone')
      end
      it 'is called if membership_number changes' do
        expect(user).to receive(:clear_proof_of_membership_jpg_cache).once
        user.update_attributes(membership_number: 1000)
      end
      it 'is not called if other attribute changes' do
        expect(user).not_to receive(:clear_proof_of_membership_jpg_cache)
        user.update_attributes(email: 'new@mail.com',
                               date_membership_packet_sent: Date.current)
      end
    end
  end

 describe 'has_shf_application?' do

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

 describe 'shf_application' do

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

 describe 'member_fee_payment_due?' do

    describe 'is a member' do

      it 'true if membership is not current_member' do
        expect(member_expired.member_fee_payment_due?).to be_truthy
      end

      it 'false if membership is current_member' do
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

 describe 'member_or_admin?' do

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


  describe 'has_company_in_good_standing?' do

    it 'false if no companies' do
      expect(build(:user).has_company_in_good_standing?).to be_falsey
    end

    context 'has at least 1 company' do
      let(:user_1_good_company) { create(:user, email: 'user_1_good_company@example.com') }
      let(:user_1_app) do
        app = create(:shf_application,
                     :accepted,
                     user: user_1_good_company,
                     company_number: other_co_num1)
        app.companies << other_co2
        app
      end

      let(:app_co_1) { user_1_app.companies.find{|co| co.company_number == other_co_num1} }


      it 'true if at least one company is in good standing' do
        allow_any_instance_of(Company).to receive(:in_good_standing?).and_return(true)
        user_1_app # ensure this ShfApp is created with the companies

        expect(user_1_good_company.has_company_in_good_standing?).to be_truthy
      end

      it 'false if no companies are in good standing' do
        allow_any_instance_of(Company).to receive(:in_good_standing?).and_return(false)
        user_1_app # ensure this ShfApp is created with the companies

        expect(user_1_good_company.has_company_in_good_standing?).to be_falsey
      end
    end

  end

  describe 'in_company_numbered?(company_num)' do

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

 describe 'allowed_to_pay_hbrand_fee?' do

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

 describe 'has_app_for_company?' do

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

 describe 'has_app_for_company_number?' do

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

  describe 'apps_for_company' do
    it 'gets all SHF applications for the company number of the given company' do
      co = create(:company)
      u = create(:user_with_membership_app, company_number: co.company_number, email: 'user_with_co@example.com')
      expect(u).to receive(:apps_for_company_number).with(co.company_number)
      u.apps_for_company(co)
    end
  end


  describe 'apps_for_company_number' do

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

 describe 'sort_apps_by_when_approved' do

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

 describe 'admin?' do
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

 describe 'full_name' do
    let(:user) { build(:user, first_name: 'first', last_name: 'last') }
    context '@first_name=first @last_name=last' do
      it { expect(user.full_name).to eq('first last') }
    end
  end

 describe 'has_full_name?' do

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


  describe 'membership_status aasm events, transitions' do
    let(:expired_member) { create(:member, expiration_date: Date.current) }

    it 'date: is passed on to the event, and on to the MembershipAction(s)' do
      expect(Memberships::IndividualMembershipEnterGracePeriodActions).to receive(:for_user)
                                                                            .with(expired_member,
                                                                                  first_day: Date.current + 2,
                                                                                  send_email: true)
      expired_member.start_grace_period!(date: Date.current + 2)
    end

    it 'can pass in send_email: and it will be passed on to the event, and on to the MembershipAction(s)' do
      expired_member = create(:member, expiration_date: Date.current)

      expect(Memberships::IndividualMembershipEnterGracePeriodActions).to receive(:for_user)
                                                                           .with(expired_member,
                                                                                 first_day: Date.current,
                                                                                 send_email: false)
      expired_member.start_grace_period!(date: Date.current, send_email: false)
    end
  end


  describe 'start_membership_on' do
    it 'calls Memberships::NewIndividualMembershipActions for the user and the first_day' do
      given_user = build(:user)
      given_first_day = Date.current
      expect(Memberships::NewIndividualMembershipActions).to receive(:for_user)
                                                               .with(given_user,
                                                                     first_day: given_first_day,
                                                                     send_email: true)
      given_user.start_membership_on(date: given_first_day)
    end
  end


  describe 'renew_membership_on' do
    it 'calls Memberships::RenewIndividualMembershipActions for the user and the first_day' do
      given_user = build(:user)
      given_first_day = Date.current
      expect(Memberships::RenewIndividualMembershipActions).to receive(:for_user)
                                                               .with(given_user,
                                                                     first_day: given_first_day,
                                                                     send_email: true)
      given_user.renew_membership_on(date: given_first_day)
    end
  end


  describe 'enter_grace_period' do
    it 'calls Memberships::IndividualMembershipEnterGracePeriodActions for the user and the first_day' do
      given_user = build(:user)
      # expect(Memberships::IndividualMembershipEnterGracePeriodActions).to receive(:for_user)
      #                                                            .with(given_user)
      given_user.enter_grace_period
    end
  end


  describe 'become_former_member' do
    it 'calls Memberships::BecomeFormerIndividualMemberActions for the user and the first_day' do
      given_user = build(:user)
      # expect(Memberships::BecomeFormerIndividualMemberActions).to receive(:for_user)
      #                                                            .with(given_user)
      given_user.become_former_member
    end
  end


  describe 'membership_start_date' do

    context 'is a current member' do
      it 'returns the first day for the current membership' do
        current_member = create(:member)
        expect(current_member.membership_start_date).to eq Date.current
      end
    end

    it 'nil if is not a current member' do
      expect(build(:user).membership_start_date).to be_nil
    end
  end


  describe 'membership_expire_date' do
    context 'is a current member' do
      it 'returns the first day for the current membership' do
        current_member = create(:member)
        expect(current_member.membership_expire_date).to eq(Membership.last_day_from_first(Date.current))
      end
    end

    it 'nil if is not a current member' do
      expect(build(:user).membership_expire_date).to be_nil
    end
  end


  describe 'membership_payment_notes' do
    it 'returns notes for latest completed payment' do
      member_payment1
      expect(user.membership_payment_notes).to eq member_payment1.notes
      member_payment2
      expect(user.membership_payment_notes).to eq member_payment2.notes
    end
  end


  describe 'payment and membership period' do

    describe 'most_recent_membership_payment' do
      it 'returns latest completed payment' do
        member_payment1
        expect(user.most_recent_membership_payment).to eq member_payment1
        member_payment2
        expect(user.most_recent_membership_payment).to eq member_payment2
      end
    end


  end


  describe 'allowed_to_pay_member_fee?' do
    let(:u) { build(:user) }

    it 'false if the user is an admin' do
      expect(build(:admin).allowed_to_pay_member_fee?).to be_falsey
    end

    context 'not an admin' do
      before(:each) { allow(u).to receive(:admin?).and_return(false) }

      context 'is a current member' do
        before(:each) do
          allow(u).to receive(:current_member?).and_return(true)
          allow(u).to receive(:in_grace_period?).and_return(false)
        end

        it 'is the result of whether the user can pay a renewal membership fee' do
          expect(u).to receive(:allowed_to_pay_renewal_member_fee?)
          u.allowed_to_pay_member_fee?
        end
      end

      context 'is in the renewal grace period' do
        before(:each) do
          allow(u).to receive(:current_member?).and_return(false)
          allow(u).to receive(:in_grace_period?).and_return(true)
        end

        it 'is the result of whether the user can pay a renewal membership fee' do
          expect(u).to receive(:allowed_to_pay_renewal_member_fee?)
          u.allowed_to_pay_member_fee?
        end
      end

      context 'not a current member or in the renewal grace period' do
        before(:each) do
          allow(u).to receive(:current_member?).and_return(false)
          allow(u).to receive(:in_grace_period?).and_return(false)
        end

        it 'is the result of whether the user can pay a new membership fee' do
          expect(u).to receive(:allowed_to_pay_new_membership_fee?)
          u.allowed_to_pay_member_fee?
        end
      end
    end
  end


  describe 'allowed_to_pay_renewal_member_fee?' do
    let(:u) { build(:user) }

    it 'false if user is an admin' do
      expect(build(:admin).allowed_to_pay_renewal_member_fee?).to be_falsey
    end

    context 'is a current member' do
      before(:each) { allow(u).to receive(:current_member?).and_return(true) }

      it 'returns the value of RequirementsForRenewal.requirements_excluding_payments_met?(self)' do
        expect(RequirementsForRenewal).to receive(:requirements_excluding_payments_met?)
                                            .with(u)
                                            .and_return(true)
        expect(u.allowed_to_pay_renewal_member_fee?).to be_truthy
      end
    end

    context 'is in the renewal grace period' do
      before(:each) { allow(u).to receive(:in_grace_period?).and_return(true) }

      it 'returns the value of RequirementsForRenewal.requirements_excluding_payments_met?(self)' do
        expect(RequirementsForRenewal).to receive(:requirements_excluding_payments_met?)
                                               .with(u)
                                               .and_return(true)
        expect(u.allowed_to_pay_renewal_member_fee?).to be_truthy
      end
    end

    context 'is not a current member or in the renewal grace period' do
      it 'always false' do
        allow(u).to receive(:current_member?).and_return(false)
        allow(u).to receive(:in_grace_period?).and_return(false)
        expect(u.allowed_to_pay_renewal_member_fee?).to be_falsey
      end
    end
  end


  describe 'allowed_to_pay_new_membership_fee?' do
    it 'false if user is an admin' do
      expect(build(:admin).allowed_to_pay_new_membership_fee?).to be_falsey
    end

    context 'not an admin' do
      let(:member) { build(:user) }

      context 'not_a_member? is true (is not a member)' do
        before(:each) { allow(member).to receive(:not_a_member?).and_return(true) }

        it 'returns the value of RequirementsForMembership.requirements_excluding_payments_met?(self)' do
          expect(RequirementsForMembership).to receive(:requirements_excluding_payments_met?)
                                                 .with(member)
                                                 .and_return(true)
          expect(member.allowed_to_pay_new_membership_fee?).to be_truthy
        end
      end

      context 'former_member? is true (is a former member)' do
        before(:each) { allow(member).to receive(:former_member?).and_return(true) }

        it 'returns the value of RequirementsForMembership.requirements_excluding_payments_met?(self)' do
          expect(RequirementsForMembership).to receive(:requirements_excluding_payments_met?)
                                                 .with(member)
                                                 .and_return(true)
          expect(member.allowed_to_pay_new_membership_fee?).to be_truthy
        end
      end

      context 'not not a member and not a former member' do
        it 'always false' do
          allow(member).to receive(:not_a_member?).and_return(false)
          allow(member).to receive(:former_member?).and_return(false)
          expect(member.allowed_to_pay_new_membership_fee?).to be_falsey
        end
      end
    end
  end


  # describe 'membership_status' do
  #
  #   it 'default date = Date.current' do
  #     u = create(:user)
  #     expect(u).to receive(:payments_current_as_of?).at_least(1).times.with(Date.current)
  #                                                     .and_return(true)
  #     u.membership_status
  #   end
  #
  #   context 'payments are current' do
  #     let(:current_member) do
  #       u = build(:user)
  #       allow(u).to receive(:payments_current_as_of?).and_return(true)
  #       u
  #     end
  #
  #     it 'uses current_or_expires_soon_status to return the status' do
  #       given_date = Date.current - 1.day
  #       expect(current_member).to receive(:current_or_expires_soon_status).with(given_date, include_expires_soon: true)
  #       current_member.membership_status(given_date, include_expires_soon: true)
  #     end
  #
  #     it 'default is to include expires_soon as a status' do
  #       expect(current_member).to receive(:current_or_expires_soon_status).with(anything, include_expires_soon: true)
  #       current_member.membership_status
  #     end
  #
  #     context 'also include expires_soon as a status' do
  #
  #       it 'uses current_or_expires_soon_status to return the status' do
  #         given_date = Date.current - 1.day
  #         expect(current_member).to receive(:current_or_expires_soon_status).with(given_date, include_expires_soon: true)
  #         current_member.membership_status(given_date, include_expires_soon: true)
  #       end
  #
  #       it 'membership expires soon if it expires soon' do
  #         expect(current_member).to receive(:expires_soon?).and_return(true)
  #         expect(current_member.membership_status(include_expires_soon: true)).to eq :expires_soon
  #       end
  #
  #       it 'membership is current if it does not expire soon' do
  #         expect(current_member).to receive(:expires_soon?).and_return(false)
  #         expect(current_member.membership_status(include_expires_soon: true)).to eq :current
  #       end
  #     end
  #
  #     context 'do not include expires_soon as a status' do
  #       it 'membership is current and whether it expires soon is never checked' do
  #         expect(current_member).not_to receive(:expires_soon?)
  #         expect(current_member.membership_status(include_expires_soon: false)).to eq :current
  #       end
  #     end
  #   end
  #
  #   it 'membership is in the grace period for renewal' do
  #     u = create(:user)
  #     allow(u).to receive(:membership_current_as_of?).and_return(false)
  #     allow(u).to receive(:membership_expired_in_grace_period?).and_return(true)
  #
  #     expect(u.membership_status).to eq 'in_grace_period'
  #   end
  #
  #   it 'is a former member' do
  #     u = create(:user)
  #     allow(u).to receive(:membership_current_as_of?).and_return(false)
  #     allow(u).to receive(:membership_expired_in_grace_period?).and_return(false)
  #     allow(u).to receive(:payment_term_expired?).and_return(true)
  #
  #     expect(u.membership_status).to eq 'former_member'
  #   end
  #
  #   describe 'not a member' do
  #     it 'if no payments ever made' do
  #       expect(create(:user).membership_status).to eq 'not_a_member'
  #     end
  #
  #     it 'not a member if no other status is true ( = fallback)' do
  #       u = create(:user)
  #       allow(u).to receive(:membership_current_as_of?).and_return(false)
  #       allow(u).to receive(:membership_expired_in_grace_period?).and_return(false)
  #       allow(u).to receive(:payment_term_expired?).and_return(false)
  #
  #       expect(u.membership_status).to eq 'not_a_member'
  #     end
  #   end
  # end


  describe 'member_in_good_standing?' do

    it 'RequirementsForMembership is checked with the user and given date' do
      given_date = Date.current - 1
      u = build(:user)
      expect(RequirementsForMembership).to receive(:requirements_met?).with(user: u, date: given_date)
      u.member_in_good_standing?(given_date)
    end

    it 'default date is Date.current' do
      u = build(:user)
      expect(RequirementsForMembership).to receive(:requirements_met?).with(user: u, date: Date.current)
      u.member_in_good_standing?
    end
  end


  describe 'payments_current? only checks membership payment status  (was membership_current?; aliased method) ' do

    context 'membership payments have not expired yet' do

      let(:paid_member) {
        member = create(:member, first_day: jan_1)
        # create(:membership_fee_payment,
        #        :successful,
        #        user: member,
        #        start_date: jan_1,
        #        expire_date: User.expire_date_for_start_date(jan_1))
        # member
      }

      it 'true if today = dec 1, start = jan 1, expire = dec 31' do
        Timecop.freeze(dec_1) do
          expect(paid_member.membership_expire_date).to eq dec_31
          expect(paid_member.payments_current?).to be_truthy
        end
      end

    end


    context 'testing dates right before, on, and after expire_date' do
      let(:paid_expires_today_member) { create(:member, first_day: lastyear_dec_3) }

      it 'true if today = nov 30, start = dec 3 last year, expire = dec 2' do
        Timecop.freeze(nov_30) do
          expect(paid_expires_today_member.membership_expire_date).to eq dec_2
          expect(paid_expires_today_member.payments_current?).to be_truthy
        end # Timecop
      end

      it 'true if today = dec 1, start = dec 3 last year, expire = dec 2' do
        Timecop.freeze(dec_1) do
          expect(paid_expires_today_member.membership_expire_date).to eq dec_2
          expect(paid_expires_today_member.payments_current?).to be_truthy
        end # Timecop
      end

      it 'false if today = dec 2, start = dec 3 last year, expire = dec 2' do
        Timecop.freeze(dec_2) do
          expect(paid_expires_today_member.membership_expire_date).to eq dec_2
          expect(paid_expires_today_member.payments_current?).to be_falsey
        end # Timecop
      end

      it 'false today = dec 3, start = dec 3 last year, expire = dec 2' do
        Timecop.freeze(dec_3) do
          expect(paid_expires_today_member.membership_expire_date).to eq dec_2
          expect(paid_expires_today_member.payments_current?).to be_falsey
        end # Timecop
      end

    end

  end

  describe 'payments_current_as_of? checks membership payment status as of a given date' do

    it 'is false if nil is the given date' do
      expect((create :user).payments_current_as_of?(nil)).to be_falsey
    end

    context 'membership payments have not expired yet' do

      let(:paid_member) { create(:member, first_day: jan_1) }

      it 'true as of dec 1, start = jan 1, expire = dec 31' do
        expect(paid_member.membership_expire_date).to eq dec_31
        expect(paid_member.payments_current_as_of?(dec_1)).to be_truthy
      end

    end

    context 'testing dates right before, on, and after expire_date' do

      let(:paid_expires_today_member) { create(:member, first_day: lastyear_dec_3) }

      it 'true as of nov 30, start = dec 3 last year, expire = dec 2' do
        expect(paid_expires_today_member.membership_expire_date).to eq dec_2
        expect(paid_expires_today_member.payments_current_as_of?(nov_30)).to be_truthy
      end

      it 'true as of dec 1, start = dec 3 last year, expire = dec 2' do
        expect(paid_expires_today_member.membership_expire_date).to eq dec_2
        expect(paid_expires_today_member.payments_current_as_of?(dec_1)).to be_truthy
      end

      it 'false as of dec 2, start = dec 3 last year, expire = dec 2' do
        expect(paid_expires_today_member.membership_expire_date).to eq dec_2
        expect(paid_expires_today_member.payments_current_as_of?(dec_2)).to be_falsey
      end

      it 'false today = dec 3, start = dec 3 last year, expire = dec 2' do
        expect(paid_expires_today_member.membership_expire_date).to eq dec_2
        expect(paid_expires_today_member.payments_current_as_of?(dec_3)).to be_falsey
      end
    end
  end


  describe 'membership_past_grace_period_end?' do
    let(:u) { build(:user) }

    it 'calls membership_manager method' do
      given_date = Date.current + 1.day
      expect(u.memberships_manager).to receive(:date_after_grace_period_end?)
                                           .with(u, given_date)
      u.membership_past_grace_period_end?(given_date)
    end

    it 'default date is Date.current' do
      expect(u.memberships_manager).to receive(:date_after_grace_period_end?)
                                         .with(u, Date.current)
      u.membership_past_grace_period_end?
    end
  end


  describe 'membership_status_incl_informational' do

    context 'the given membership expires soon' do
      it 'is the expires soon status' do
        member = create(:member, expiration_date: Date.current - 1.day)
        mock_memberships_mgr = double(MembershipsManager, membership_on: member.most_recent_membership)
        allow(member).to receive(:memberships_manager).and_return(mock_memberships_mgr)
        allow(mock_memberships_mgr).to receive(:most_recent_membership).and_return(member.memberships.last)

        expect(mock_memberships_mgr).to receive(:expires_soon?).and_return(true)
        expect(member.membership_status_incl_informational).to eq(MembershipsManager.expires_soon_status)
      end
    end

    context 'the given membership does not expire soon' do
      it 'is the membership status of the given membership' do
        member = create(:member, expiration_date: Date.current - 1.day)
        mock_memberships_mgr = double(MembershipsManager, membership_on: member.current_membership)
        allow(member).to receive(:memberships_manager).and_return(mock_memberships_mgr)
        allow(mock_memberships_mgr).to receive(:most_recent_membership).and_return(member.memberships.last)

        expect(mock_memberships_mgr).to receive(:expires_soon?).and_return(false)
        expect(member.membership_status_incl_informational).to eq('not_a_member')
      end
    end
  end



  describe 'membership_expired_in_grace_period?' do
    let(:member) { build(:user) }
    let(:grace_3_days) { ActiveSupport::Duration.days(3) }
    let(:four_days_ago) { Time.zone.now - 4.days }
    let(:three_days_ago) { Time.zone.now - 3.days }
    let(:two_days_ago) { Time.zone.now - 2.days }

    it 'calls memberships_manager method' do
      this_date = Date.new(2020, 1, 10)
      # grace_first_day = Date.new(2020, 1, 1)
      expect(member.memberships_manager).to receive(:membership_in_grace_period?)
                                         .with(member, this_date)
      member.membership_expired_in_grace_period?(this_date)
    end

    it 'false if the given date is nil' do
      expect(member.membership_expired_in_grace_period?(nil)).to be_falsey
    end

    it 'false if the membership has not expired' do
      expect(member.membership_expired_in_grace_period?).to be_falsey
    end
  end


  describe 'today_is_valid_renewal_date?' do
    it 'calls memberships_manager.today_is_valid_renewal_date?' do
      u = build(:user)
      expect(u.memberships_manager).to receive(:today_is_valid_renewal_date?).with(u)
      u.today_is_valid_renewal_date?
    end
  end


  describe 'valid_renewal_date?' do

    it 'calls memberships_manager.valid_renewal_date?' do
      u = build(:user)
      expect(u.memberships_manager).to receive(:valid_renewal_date?).with(u, Date.current)
      u.valid_date_for_renewal?(Date.current)
    end

    it 'always false if membership expiration date is nil' do
      expect(build(:user).valid_date_for_renewal?(Date.current)).to be_falsey
    end
  end


  describe 'ransacker :padded_membership_number' do
    pending
  end


 describe 'get_short_proof_of_membership_url' do
    context 'there is already a shortened url in the table' do
      it 'returns shortened url' do
        expect(with_short_proof_of_membership_url.get_short_proof_of_membership_url('any_url')).to eq('http://www.tinyurl.com/proofofmembership')
      end
    end

    context 'there is no shortened url in the table and ShortenUrl.short is called' do
      it 'saves the result if the result is not nil and returns shortened url' do
        url = 'http://localhost:3000/anvandare/1/proof_of_membership'
        allow(ShortenUrl).to receive(:short).with(url).and_return('http://tinyurl.com/short_url')
        expect(user.get_short_proof_of_membership_url(url)).to eq(ShortenUrl.short(url))
        expect(user.short_proof_of_membership_url).to eq(ShortenUrl.short(url))
      end
      it 'does not save anything if the result is nil and returns unshortened url' do
        url = 'http://localhost:3000/anvandare/1/proof_of_membership'
        allow(ShortenUrl).to receive(:short).with(url).and_return(nil)
        expect(user.get_short_proof_of_membership_url(url)).to eq(url)
        expect(user.short_proof_of_membership_url).to eq(nil)
      end
    end
  end

  describe 'membership_guidelines_checklist_done?' do

    it 'asks the Requirement for Membership [the one place to implement that]' do
      expect(RequirementsForMembership).to receive(:membership_guidelines_checklist_done?)
                                             .with(subject)
      subject.membership_guidelines_checklist_done?
    end
  end

 describe 'membership_packet_sent?' do

    it 'true if there is a date' do
      user_sent_package = create(:user, date_membership_packet_sent: Date.current)
      expect(user_sent_package.membership_packet_sent?).to be_truthy
    end

    it 'false if there is no date' do
      user_sent_package = create(:user, date_membership_packet_sent: nil)
      expect(user_sent_package.membership_packet_sent?).to be_falsey
    end
  end

 describe 'toggle_membership_packet_status' do

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


  describe '.most_recent_upload_method' do
    it 'is the created_at date' do
      expect(described_class.most_recent_upload_method).to eq(:created_at)
    end
  end


  describe 'most_recent_upload_method' do
    it 'calls the class method' do
      expect(described_class).to receive(:most_recent_upload_method) #.and_call_original
      subject.most_recent_upload_method
    end
  end


  describe 'file_uploaded_during_this_membership_term?' do
    let(:u) { build(:user) }
    let(:mock_membership) { double(Membership) }

    it 'false if the user is not a current member AND is not in the renewal grace period' do
      allow(u).to receive(:current_member?).and_return(false)
      allow(u).to receive(:in_grace_period?).and_return(false)
      expect(u.file_uploaded_during_this_membership_term?).to be_falsey
    end

    context 'is in the renewal grace period' do
      before(:each) do
        allow(u).to receive(:in_grace_period?).and_return(true)
      end

      it 'checks using the first day of the most recent membership term' do
        mock_memberships_manager = double(MembershipsManager)
        allow(u).to receive(:memberships_manager).and_return(mock_memberships_manager)
        allow(mock_memberships_manager).to receive(:most_recent_membership)
                                             .with(u)
                                             .and_return(mock_membership)
        allow(mock_membership).to receive(:first_day).and_return(Date.current - 1.year)

        expect(u).to receive(:file_uploaded_on_or_after?)
                       .with(Date.current - 1.year).and_return(true)
        expect(u.file_uploaded_during_this_membership_term?).to be_truthy
      end
    end

    context 'is a current member' do
      before(:each) do
        allow(u).to receive(:current_member?).and_return(true)
        allow(u).to receive(:current_membership).and_return(mock_membership)
      end

      it 'returns result of file_uploaded_on_or_after? for the current membership first day' do
        allow(mock_membership).to receive(:first_day).and_return(Date.current - 1)

        expect(u).to receive(:file_uploaded_on_or_after?)
                       .with(Date.current - 1).and_return(true)
        expect(u.file_uploaded_during_this_membership_term?).to be_truthy
      end

    end
  end


  describe 'file_uploaded_on_or_after?' do
    let(:yesterday) { Date.current - 1.day }
    let(:tomorrow) { Date.current + 1.day }
    let(:faux_file_today) { double('UploadedFile', created_at: Date.current) }
    let(:faux_file_tomorrow) { double('UploadedFile', created_at: tomorrow) }
    let(:faux_file_yesterday) { double('UploadedFile', created_at: yesterday) }
    let(:faux_file_one_week_ago) { double('UploadedFile', created_at: Date.current - 7.days) }

    it 'no uploads' do
      expect(build(:user).file_uploaded_on_or_after?(tomorrow)).to be_falsey
    end

    it 'gets the last uploaded file, ordered by the method to get the most recent upload' do
      u = build(:user)
      allow(u).to receive(:uploaded_files).and_return([faux_file_today])
      expect(u).to receive(:most_recent_upload_method).and_call_original
      expect(u).to receive(:most_recent_uploaded_file).and_return(faux_file_today)
      u.file_uploaded_on_or_after?
    end

    it 'default given date is today' do
      u = build(:user)
      allow(u).to receive(:uploaded_files).and_return([faux_file_today])
      allow(u).to receive(:most_recent_uploaded_file).and_return(faux_file_today)

      expect(u.file_uploaded_on_or_after?).to be_truthy
    end

    it 'true if last upload was after the given date' do
      u = build(:user)
      allow(u).to receive(:uploaded_files).and_return([faux_file_today, faux_file_tomorrow])
      allow(u).to receive(:most_recent_uploaded_file).and_return(faux_file_tomorrow)

      expect(u.file_uploaded_on_or_after?(yesterday)).to be_truthy
    end

    it 'true if last upload was on the given date' do
      u = build(:user)
      allow(u).to receive(:uploaded_files).and_return([faux_file_one_week_ago, faux_file_yesterday])
      allow(u).to receive(:most_recent_uploaded_file).and_return(faux_file_yesterday)

      expect(u.file_uploaded_on_or_after?(yesterday)).to be_truthy
    end

    it 'false if last upload was before the given date' do
      u = build(:user)
      allow(u).to receive(:uploaded_files).and_return([faux_file_one_week_ago, faux_file_yesterday])
      allow(u).to receive(:most_recent_uploaded_file).and_return(faux_file_yesterday)

      expect(u.file_uploaded_on_or_after?(Date.current)).to be_falsey
    end
  end


  describe 'files_uploaded_during_this_membership' do

    it 'empty list if no files uploaded' do
      expect(build(:user).files_uploaded_during_this_membership).to be_empty
    end

    it 'only files uploaded on or after the first day of the current term' do
      member = create(:member)
      current_first_day = member.current_membership.first_day
      create(:membership, user: member, first_day: current_first_day - 30.days, last_day: current_first_day - 1.day)
      uploaded_file1 = member.uploaded_files.first
      uploaded_file2 = create(:uploaded_file, :png, user: member)
      uploaded_file2.update(updated_at: current_first_day)

      uploaded_past_membership = create(:uploaded_file, :jpg, user: member)
      uploaded_past_membership.update(updated_at: current_first_day - 1.day)

      expect(member.files_uploaded_during_this_membership.to_a).to match_array([uploaded_file1, uploaded_file2])
    end
  end


  describe 'most_recent_uploaded_file' do
    let(:yesterday) { Date.current - 1.day }
    let(:tomorrow) { Date.current + 1.day }
    let(:faux_file_today) { double('UploadedFile', created_at: Date.current) }
    let(:faux_file_tomorrow) { double('UploadedFile', created_at: tomorrow) }
    let(:faux_file_yesterday) { double('UploadedFile', created_at: yesterday) }
    let(:faux_file_one_week_ago) { double('UploadedFile', created_at: Date.current - 7.days) }

    it 'nil if there are no uploaded files' do
      expect(build(:user).most_recent_uploaded_file).to be_nil
    end

    it 'returns the most recently created uploaded_file for the user' do
      u = build(:user, uploaded_files: [])
      file1 = create(:uploaded_file, :pdf, user: u)
      file1.update(created_at: Time.zone.now)
      file2 = create(:uploaded_file, :jpg, user: u)
      file2.update(created_at: (Time.zone.now - 1.day))
      u.uploaded_files << file1 << file2

      expect(u).to receive(:uploaded_files).and_call_original
      expect(u.most_recent_uploaded_file).to eq(file1)
    end
  end


  describe 'issue_membership_number' do
    pending
  end

  describe 'get_next_membership_number' do
    # This is a private method so should make sure any calling methods are tested and so test this.
    # else send this method to a user to test it.
    pending
  end


  describe 'destroy_updloaded_files' do
    # This is a private method so should make sure any calling methods are tested and so test this.
    # else send this method to a user to test it.
    pending
  end
end
