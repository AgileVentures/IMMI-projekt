require 'rails_helper'
require 'aasm/rspec'

require 'support/ae_aasm_matchers/ae_aasm_matchers'

require_relative './shared_ex_scope_updated_in_date_range_spec'


# alias shared example call for readability
RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_will, 'it will'
end


# Shared examples:

RSpec.shared_examples 'allow transition to' do |start_state, to_state, transition_event|

  it "#{to_state}" do
    expect(application).to transition_from(start_state).to(to_state).on_event(transition_event), "expected to transition from #{start_state} to #{to_state} on event #{transition_event}"
  end
end


RSpec.shared_examples 'not allow transition to' do |start_state, to_state|
  it "#{to_state}" do

    application.aasm(:default).current_state = start_state.to_sym

    expect(application).not_to allow_transition_to(to_state), "expected to not to be able to transition from #{start_state} to #{to_state}"
  end
end

#--------------------------------------------------------------------------


RSpec.describe ShfApplication, type: :model do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:shf_application)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :company_number }
    it { is_expected.to have_db_column :phone_number }
    it { is_expected.to have_db_column :contact_email }
    it { is_expected.to have_db_column :state }
    it { is_expected.to have_db_column :custom_reason_text }
    it { is_expected.to have_db_column :user_id }
    it { is_expected.to have_db_column :company_id }
    it { is_expected.to have_db_column :member_app_waiting_reasons_id }
  end

  describe 'Associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :company }
    it { is_expected.to have_and_belong_to_many :business_categories }
    it { is_expected.to have_many :uploaded_files }
    it { is_expected.to belong_to(:waiting_reason)
                          .class_name(AdminOnly::MemberAppWaitingReason)
                          .with_foreign_key('member_app_waiting_reasons_id') }
    it { is_expected.to accept_nested_attributes_for(:uploaded_files)
                          .allow_destroy(true) }
    it { is_expected.to accept_nested_attributes_for(:user)
                          .update_only(true).allow_destroy(false) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :contact_email }
    it { is_expected.to validate_presence_of :company_number }
    it { is_expected.to validate_presence_of :state }

    it { is_expected.to allow_value('user@example.com').for(:contact_email) }
    it { is_expected.not_to allow_value('userexample.com').for(:contact_email) }

    it { is_expected.to validate_length_of(:company_number).is_equal_to(10) }

    describe 'uniqueness of user scoped within company_number' do
      subject { FactoryGirl.build(:shf_application) }
      it { is_expected.to validate_uniqueness_of(:user_id)
                                .scoped_to(:company_number) }
    end

    describe 'swedish org number' do
      it { is_expected.to allow_values('5560360793', '2120000142')
                            .for(:company_number) }
      it { is_expected.not_to allow_values('0123456789', '212000')
                            .for(:company_number) }
    end
  end

  context 'scopes' do

    context 'open and accepted' do
      let!(:accepted_app1) { create(:shf_application, :accepted) }
      let!(:accepted_app2) { create(:shf_application, :accepted) }
      let!(:rejected_app1) { create(:shf_application, :rejected) }
      let!(:new_app1) { create(:shf_application) }

      describe 'open' do
        it 'returns all apps not accepted or rejected' do
          expect(described_class.open.all).to contain_exactly(new_app1)
        end
      end

      describe 'accepted' do
        it 'returns all accepted apps' do
          expect(described_class.accepted.all)
              .to contain_exactly(accepted_app1, accepted_app2)
        end
      end

    end

    describe 'no uploaded files: all open applications that have no uploaded files' do

      let!(:application_owner1) { create(:user, email: 'user_1@random.com') }
      let!(:application_owner2) { create(:user, email: 'user_2@random.com') }
      let!(:application_owner3) { create(:user, email: 'user_3@random.com') }

      let!(:shf_open_app_no_uploads_1) { create(:shf_application, user: application_owner2, contact_email: application_owner2.email,) }
      let!(:shf_open_app_no_uploads_2) { create(:shf_application, user: application_owner3, contact_email: application_owner3.email,) }

      let!(:shf_rejected_app_uploads_1) do
        user = create(:user, email: 'user_7@random.com')
        create(:shf_application, :rejected, user: user)
      end

      let!(:shf_rejected_app_uploads_2) do
        user = create(:user, email: 'user_8@random.com')
        create(:shf_application, :rejected, user: user)
      end

      let!(:shf_rejected_app_uploads_3) do
        user = create(:user, email: 'user_9@random.com')
        create(:shf_application, :rejected, user: user)
      end

      let!(:shf_rejected_app_uploads_4) do
        user = create(:user, email: 'user_10@random.com')
        create(:shf_application, :rejected, user: user)
      end


      context 'no uploaded files in the system [caused a problem with the original scope]' do

        it 'returns 2 apps when there are 2 open apps without uploads, 4 rejected apps without uploads' do

          expect(described_class.no_uploaded_files).to contain_exactly(shf_open_app_no_uploads_1,
                                                                       shf_open_app_no_uploads_2)
        end
      end

      context 'there are uploaded files in the system' do

        let!(:shf_open_app_uploads_1) do
          shf_app = create(:shf_application, user: application_owner1, contact_email: application_owner1.email)
          shf_app.uploaded_files << create(:uploaded_file, :jpg, shf_application: shf_app)
        end

        let!(:shf_approved_app_uploads_1) do
          member = create(:member_with_membership_app, email: 'user_4@random.com')
          shf_app = member.shf_applications.first
          shf_app.uploaded_files << create(:uploaded_file, :jpg, shf_application: shf_app)
          shf_app
        end

        let!(:shf_approved_app_uploads_2) do
          member = create(:member_with_membership_app, email: 'user_5@random.com')
          shf_app = member.shf_applications.first
          shf_app.uploaded_files << create(:uploaded_file, :jpg, shf_application: shf_app)
          shf_app
        end

        let!(:shf_approved_app_uploads_3) do
          member = create(:member_with_membership_app, email: 'user_6@random.com')
          shf_app = member.shf_applications.first
          shf_app.uploaded_files <<  create(:uploaded_file, :png, shf_application: shf_app)
          shf_app
        end


        describe '1 open apps with uploads, 2 open apps without, 3 approved apps with uploads, 4 rejected apps without uploads ' do

          it 'open count = 3' do
            expect(described_class.open.count).to eq 3
          end

          it 'no_uploaded_files count = 2' do
            expect(described_class.no_uploaded_files.count).to eq 2
            expect(described_class.no_uploaded_files).to contain_exactly(shf_open_app_no_uploads_1, shf_open_app_no_uploads_2)
          end

        end

      end


    end

    describe 'updated_in_date_range(start_date, end_date)' do
      it_behaves_like 'it_has_updated_in_date_range_scope', :shf_application
    end
  end


  describe "Uploaded Files" do

    let(:application_owner) { create(:user, email: 'user_1@random.com') }
    let(:application_owner2) { create(:user, email: 'user_2@random.com') }

    it 'uploading a file increases the number of uploaded files by 1' do
      expect { create(:shf_application, user: application_owner, uploaded_files: [create(:uploaded_file, actual_file: (File.new(File.join(FIXTURE_DIR, 'image.jpg'))))]) }.to change(UploadedFile, :count).by(1)
    end

  end


  describe 'User attributes nesting' do

    let(:user) { create(:user, first_name: 'Firstname', last_name: 'Lastname') }
    let!(:member_app) { create(:shf_application, user: user, user_attributes: { first_name: 'New Firstname', last_name: 'New Lastname' }) }

    it 'sets first_name on user' do
      expect(user.first_name).to eq('New Firstname')
    end

    it 'sets last_name on user' do
      expect(user.last_name).to eq('New Lastname')
    end

    it 'validates the presence of first_name' do
      expect {
        user.first_name = ''
        member_app.save!
      }.to raise_exception(/#{I18n.t('activerecord.attributes.shf_application.first_name')} #{I18n.t('errors.messages.blank')}/)
    end

    it 'validates the presence of last_name' do
      expect {
        user.last_name = ''
        member_app.save!
      }.to raise_exception(/#{I18n.t('activerecord.attributes.shf_application.last_name')} #{I18n.t('errors.messages.blank')}/)
    end

  end

  describe 'destroy callbacks' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    app_file = (File.new(File.join(FIXTURE_DIR, 'image.jpg')))
    let(:uploaded_file) { create(:uploaded_file, actual_file: app_file) }

    let(:application) do
      create(:shf_application, user: user1,
             uploaded_files: [uploaded_file], state: :accepted)
    end
    let(:application2) do
      create(:shf_application, user: user2,
             uploaded_files: [uploaded_file], state: :new,
             company_id: application.company.id,
             company_number: application.company_number)
    end

    it 'invokes method to destroy uploaded files' do
      application.destroy
      expect(uploaded_file.destroyed?).to be_truthy
    end

    it "destroys associated company if it has no remaining applications" do
      expect(application.company).to receive(:destroy)
      application.destroy
    end

    it "does not destroy associated company if other applications remain" do
      application2
      expect(application.company).not_to receive(:destroy)
      application.destroy
    end
  end

  describe 'test factories' do

    it '1 category with default category name' do
      member_app = create(:shf_application, num_categories: 1)
      expect(member_app.business_categories.count).to eq(1)
      expect(member_app.business_categories.first.name)
          .to eq("Business Category"),
              "The first category name should have been 'Business Category'" \
        "but instead was '#{member_app.business_categories.first.name}'"
    end

    it '2 categories with sequence names' do
      member_app = create(:shf_application, num_categories: 2)
      expect(member_app.business_categories.count).to eq(2), "The number of categories should have been 2 but instead was #{member_app.business_categories.count}"
      expect(member_app.business_categories.first.name).to eq("Business Category 1"), "The first category name should have been 'Business Category 1' but instead was '#{member_app.business_categories.first.name}'"
      expect(member_app.business_categories.last.name).to eq("Business Category 2"), "The last category name should have been 'Business Category 2' but instead was '#{member_app.business_categories.first.name}'"
    end

    it '1 category with the name "Special"' do
      member_app = create(:shf_application, num_categories: 1,
                          category_name: "Special")
      expect(member_app.business_categories.count).to eq(1)
      expect(member_app.business_categories.first.name).to eq("Special"), "The first category name should have been 'Special' but instead was '#{member_app.business_categories.first.name}'"
    end

    it '3 categories with the name "Special 1, Special 2, Special 3"' do
      member_app = create(:shf_application, category_name: "Special", num_categories: 3)
      expect(member_app.business_categories.count).to eq(3)
      expect(member_app.business_categories.first.name).to eq("Special 1"), "The first category name should have been 'Special 1' but instead was '#{member_app.business_categories.first.name}'"
      expect(member_app.business_categories.last.name).to eq("Special 3"), "The first category name should have been 'Special 3' but instead was '#{member_app.business_categories.last.name}'"
    end


  end


  describe 'states, events, and transitions' do

    let!(:user) { create(:user_with_membership_app) }
    let!(:application) { user.shf_application }

    describe 'valid states' do
      it { expect(application).to have_valid_state(:new) }
      it { expect(application).to have_valid_state(:under_review) }
      it { expect(application).to have_valid_state(:waiting_for_applicant) }
      it { expect(application).to have_valid_state(:ready_for_review) }
      it { expect(application).to have_valid_state(:accepted) }
      it { expect(application).to have_valid_state(:rejected) }
    end


    it 'initial state = new' do
      expect(user.shf_application).to have_state(:new)
      expect(user.shf_application).not_to have_state(:ready_for_review)
      expect(user.shf_application).not_to have_state(:under_review)
      expect(user.shf_application).not_to have_state(:accepted)
      expect(user.shf_application).not_to have_state(:rejected)
      expect(user.shf_application).not_to have_state(:waiting_for_applicant)
    end


    describe 'valid events' do
      it { expect(application).to have_valid_event(:start_review) }
      it { expect(application).to have_valid_event(:ask_applicant_for_info) }
      it { expect(application).to have_valid_event(:cancel_waiting_for_applicant) }
      it { expect(application).to have_valid_event(:is_ready_for_review) }
      it { expect(application).to have_valid_event(:accept) }
      it { expect(application).to have_valid_event(:reject) }
    end


    describe 'new' do

      it_will 'not allow transition to', :new, :new

      it_will 'allow transition to', :new, :under_review, :start_review

      it_will 'not allow transition to', :new, :waiting_for_applicant
      it_will 'not allow transition to', :new, :ready_for_review

      it_will 'not allow transition to', :new, :accepted
      it_will 'not allow transition to', :new, :rejected

    end


    describe 'under_review' do

      it_will 'not allow transition to', :under_review, :new

      it_will 'not allow transition to', :under_review, :under_review

      it_will 'allow transition to', :under_review, :waiting_for_applicant, :ask_applicant_for_info

      it_will 'not allow transition to', :under_review, :ready_for_review

      it_will 'allow transition to', :under_review, :accepted, :accept

      it_will 'allow transition to', :under_review, :rejected, :reject

    end


    describe 'waiting_for_applicant' do

      it_will 'not allow transition to', :waiting_for_applicant, :new

      it_will 'allow transition to', :waiting_for_applicant, :under_review, :cancel_waiting_for_applicant

      it_will 'not allow transition to', :waiting_for_applicant, :waiting_for_applicant
      it_will 'allow transition to', :waiting_for_applicant, :ready_for_review, :is_ready_for_review

      it_will 'not allow transition to', :waiting_for_applicant, :accepted, :accept
      it_will 'not allow transition to', :waiting_for_applicant, :rejected, :reject

    end


    describe 'state accepted' do

      it_will 'not allow transition to', :accepted, :new

      it_will 'not allow transition to', :accepted, :under_review

      it_will 'not allow transition to', :accepted, :waiting_for_applicant
      it_will 'not allow transition to', :accepted, :ready_for_review

      it_will 'not allow transition to', :accepted, :accepted
      it_will 'allow transition to', :accepted, :rejected, :reject

    end


    describe 'state rejected' do

      it_will 'not allow transition to', :rejected, :new

      it_will 'not allow transition to', :rejected, :under_review

      it_will 'not allow transition to', :rejected, :waiting_for_applicant
      it_will 'not allow transition to', :rejected, :ready_for_review

      it_will 'allow transition to', :rejected, :accepted, :accept
      it_will 'not allow transition to', :rejected, :rejected

    end

    context 'actions taken on state transition' do
      describe 'application accepted' do
        before(:each) do
          application.start_review!
          application.accept!
        end
        it 'assigns company email to application contact_email' do
          expect(application.company.email).to eq application.contact_email
        end
      end

      describe 'application rejected' do
        xit 'need tests here' do
        end
      end
    end

  end


  describe '#se_mailing_csv_str (comma sep string) of the address for the swedish postal service' do

    let(:accepted_app) { create(:shf_application, :accepted) }
    let(:rejected_app) { create(:shf_application, :rejected) } # no company for this

    it 'uses the company main address' do

      expect(accepted_app.se_mailing_csv_str).to eq AddressExporter.se_mailing_csv_str(accepted_app.company.main_address)

    end


    it 'blanks (just commas with no data between them) if there is no company' do

      expect(rejected_app.se_mailing_csv_str).to eq AddressExporter.se_mailing_csv_str(nil)

    end

  end

  describe 'membership number generator' do

    let(:user) { create(:user) }
    let(:new_app) { create(:shf_application, user: user) }

    before(:each) do
      new_app.start_review
    end

    it 'does not generate a membership_number for a new application' do
      expect(user.membership_number).to be_nil
    end

    it 'removes the membership_number when an application is rejected' do
      new_app.accept
      new_app.reject
      expect(user.membership_number).to be_nil
    end

  end

end
