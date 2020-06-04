require 'rails_helper'
require 'aasm/rspec'

require 'support/ae_aasm_matchers/ae_aasm_matchers'

require 'shared_examples/scope_updated_in_date_range'


#================================================================================
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

#================================================================================


RSpec.describe ShfApplication, type: :model do

  before(:each) do
    # stub this so we don't have to create the MasterChecklist for the Member Guidelines checklist
    # if a ShfApplication is accepted.
    # allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for).and_return(true)
  end


  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:shf_application)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :phone_number }
    it { is_expected.to have_db_column :contact_email }
    it { is_expected.to have_db_column :state }
    it { is_expected.to have_db_column :custom_reason_text }
    it { is_expected.to have_db_column :user_id }
    it { is_expected.to have_db_column :member_app_waiting_reasons_id }
    it { is_expected.to have_db_column :when_approved }
    it { is_expected.to have_db_column :file_delivery_method_id }
    it { is_expected.to have_db_column(:file_delivery_selection_date).with_options(null: true) }
    it { is_expected.to have_db_column :uploaded_files_count }
  end

  describe 'Associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many(:company_applications) }
    it { is_expected.to have_many(:companies).through(:company_applications) }
    it { is_expected.to have_and_belong_to_many :business_categories }
    it { is_expected.to have_many :uploaded_files }
    it { is_expected.to belong_to(:waiting_reason)
                          .class_name(AdminOnly::MemberAppWaitingReason)
                          .with_foreign_key('member_app_waiting_reasons_id')
                          .optional}
    it { is_expected.to accept_nested_attributes_for(:uploaded_files)
                          .allow_destroy(true) }

    # Note that we cannot test the file_delivery_method belongs_to association because it can sometimes be nil
    # and the presence is only required (validated) _on create_
    # and the shoulda-matchers gem version 4.0.1 is not sophisticated enough to be able to
    # test validity of (belongs_to  ... optional: true) + (validates_presence_of ... with an :if clause)
    #
    # This fails because the matchers cannot also test
    # for the validation_presence_of ... with the :if clause at the same time:
    #   it { is_expected.to belong_to(:file_delivery_method)
    #                    .without_validating_presence
    #                    .class_name('AdminOnly::FileDeliveryMethod')
    #                    .optional
    #   }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :contact_email }
    it { is_expected.to validate_presence_of :state }
    it { is_expected.to validate_presence_of :companies }
    it { is_expected.to validate_presence_of :business_categories }
    it { is_expected.to validate_presence_of(:file_delivery_method).on(:create) }

    it { is_expected.to allow_value('user@example.com').for(:contact_email) }
    it { is_expected.not_to allow_value('userexample.com').for(:contact_email) }

    describe 'uniqueness of user across all applications' do
      subject { FactoryBot.build(:shf_application) }
      it { is_expected.to validate_uniqueness_of(:user_id) }
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

      let!(:shf_open_app_no_uploads_1) do
        create(:shf_application, user: application_owner2,
                                 contact_email: application_owner2.email)
      end

      let!(:shf_open_app_no_uploads_2) do
        create(:shf_application, user: application_owner3,
                                 contact_email: application_owner3.email)
      end

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
          shf_app = create(:shf_application, user: application_owner1,
                           contact_email: application_owner1.email)
          shf_app.uploaded_files << create(:uploaded_file, :jpg, shf_application: shf_app)
        end

        let!(:shf_approved_app_uploads_1) do
          member = create(:member_with_membership_app, email: 'user_4@random.com')
          shf_app = member.shf_application
          shf_app.uploaded_files << create(:uploaded_file, :jpg, shf_application: shf_app)
          shf_app
        end

        let!(:shf_approved_app_uploads_2) do
          member = create(:member_with_membership_app, email: 'user_5@random.com')
          shf_app = member.shf_application
          shf_app.uploaded_files << create(:uploaded_file, :jpg, shf_application: shf_app)
          shf_app
        end

        let!(:shf_approved_app_uploads_3) do
          member = create(:member_with_membership_app, email: 'user_6@random.com')
          shf_app = member.shf_application
          shf_app.uploaded_files << create(:uploaded_file, :png, shf_application: shf_app)
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
      app = create(:shf_application, user: application_owner)
      expect { create(:uploaded_file, shf_application: app, actual_file: (File.new(File.join(FIXTURE_DIR, 'image.jpg')))) }.to change(UploadedFile, :count).by(1)
    end

  end

  describe 'destroy callbacks' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    # app_file = (File.new(File.join(FIXTURE_DIR, 'image.jpg')))
    # let(:uploaded_file) { create(:uploaded_file, actual_file: app_file) }

    let(:application) do
      create(:shf_application, user: user1, state: :accepted)
    end

    let(:uploaded_file) do
      app_file = (File.new(File.join(FIXTURE_DIR, 'image.jpg')))
      file = create(:uploaded_file, actual_file: app_file, shf_application: application)
      application.uploaded_files << file
      file
    end

    let(:application2) do
      create(:shf_application, user: user2, state: :new, companies: [application.companies.last])
    end

    it 'invokes method to destroy uploaded files' do
      uploaded_file
      application.destroy
      expect(uploaded_file.destroyed?).to be_truthy
    end

    it "does not destroy associated company if other applications remain" do
      application2
      expect(application.companies.last).not_to receive(:destroy)
      application.destroy
    end

    it 'destroys CompanyApplication record' do
      application
      expect { application.destroy }.to change(CompanyApplication, :count).by(-1)
    end

    it 'destroys associated companies' do
      application
      expect { application.destroy }.to change(Company, :count).by(-1)
    end

    it 'does not destroy company if other app(s) exist' do
      application
      application2
      expect { application.destroy }.not_to change(Company, :count)
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

      it_should 'not allow transition to', :new, :new

      it_should 'allow transition to', :new, :under_review, :start_review

      it_should 'not allow transition to', :new, :waiting_for_applicant
      it_should 'not allow transition to', :new, :ready_for_review

      it_should 'not allow transition to', :new, :accepted
      it_should 'not allow transition to', :new, :rejected

    end


    describe 'under_review' do

      it_should 'not allow transition to', :under_review, :new

      it_should 'not allow transition to', :under_review, :under_review

      it_should 'allow transition to', :under_review, :waiting_for_applicant, :ask_applicant_for_info

      it_should 'not allow transition to', :under_review, :ready_for_review

      it_should 'allow transition to', :under_review, :accepted, :accept

      it_should 'allow transition to', :under_review, :rejected, :reject

    end


    describe 'waiting_for_applicant' do

      it_should 'not allow transition to', :waiting_for_applicant, :new

      it_should 'allow transition to', :waiting_for_applicant, :under_review, :cancel_waiting_for_applicant

      it_should 'not allow transition to', :waiting_for_applicant, :waiting_for_applicant
      it_should 'allow transition to', :waiting_for_applicant, :ready_for_review, :is_ready_for_review

      it_should 'not allow transition to', :waiting_for_applicant, :accepted, :accept
      it_should 'not allow transition to', :waiting_for_applicant, :rejected, :reject

    end


    describe 'state accepted' do

      it_should 'not allow transition to', :accepted, :new

      it_should 'not allow transition to', :accepted, :under_review

      it_should 'not allow transition to', :accepted, :waiting_for_applicant
      it_should 'not allow transition to', :accepted, :ready_for_review

      it_should 'not allow transition to', :accepted, :accepted
      it_should 'allow transition to', :accepted, :rejected, :reject

    end


    describe 'state rejected' do

      it_should 'not allow transition to', :rejected, :new

      it_should 'not allow transition to', :rejected, :under_review

      it_should 'not allow transition to', :rejected, :waiting_for_applicant
      it_should 'not allow transition to', :rejected, :ready_for_review

      it_should 'allow transition to', :rejected, :accepted, :accept
      it_should 'not allow transition to', :rejected, :rejected

    end


    context 'actions taken on state transition' do
      let(:uploaded_files) { create(:uploaded_file, shf_application: application,
                                    actual_file: (File.new(File.join(FIXTURE_DIR,
                                                  'image.jpg')))) }

      let(:jan_2_early_am) { Time.utc(2019, 1, 2, 3, 4, 5) }

      describe 'application accepted' do

        before(:each) do
          Timecop.freeze(jan_2_early_am) do
            application.uploaded_files = [uploaded_files]
            application.start_review!
            application.accept!
          end

        end

        it "assigns app's latest-added-company email to application contact_email" do
          expect(application.companies.last.email).to eq application.contact_email
        end

        it 'records the time when it was accepted/approved' do
          expect(application.when_approved).to eq jan_2_early_am
        end
      end


      describe 'application rejected' do
        before(:each) do
          application.uploaded_files = [uploaded_files]
          application.user.membership_number = 10
          application.when_approved = jan_2_early_am
          application.start_review!
          application.reject!
        end

        it 'assigns user membership_number to nil' do
          expect(application.user.membership_number).to be_nil
        end

        it 'sets when_approved to nil' do
          expect(application.when_approved).to be_nil
        end

        it 'destroys uploaded files' do
          expect(application.uploaded_files.count).to be 0
        end

        it 'destroys associated company(s)' do
          expect(application.companies.count).to be 1
        end
      end
    end

  end


  describe '#se_mailing_csv_str (comma sep string) of the address for the swedish postal service' do

    let(:accepted_app) { create(:shf_application, :accepted) }
    let(:app_no_company) do
      app = create(:shf_application)
      app.companies = []
      app
    end

    it "uses the app's latest-added-company main address" do

      expect(accepted_app.se_mailing_csv_str)
        .to eq AddressExporter
        .se_mailing_csv_str(accepted_app.companies.last.main_address)

    end


    it 'blanks (just commas with no data between them) if there is no company' do

      expect(app_no_company.se_mailing_csv_str).to eq AddressExporter.se_mailing_csv_str(nil)

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

  describe '#company_numbers and #company_names' do
    let(:cmpy1) { create(:company, name: 'Company One') }
    let(:cmpy2) { create(:company, name: 'Company Two') }
    let(:app) do
      app = create(:shf_application)
      app.companies = [cmpy1, cmpy2]
      app
    end

    it '#company_numbers returns string of company numbers' do
      expect(app.company_numbers).to eq "#{cmpy1.company_number}, #{cmpy2.company_number}"
    end

    it '#company_names returns string of company names' do
      expect(app.company_names).to eq "#{cmpy1.name}, #{cmpy2.name}"
    end
  end


  describe 'file_delivery_methods' do

    context 'can be nil' do
      pending 'When is it valid for this to be nil?'
    end

    context 'cannot be nil' do
      pending 'When must the file_deliver_method not be nil?'
    end

  end


  describe 'applicant_can_edit?' do

    it 'true if state is "new"' do
      expect(create(:shf_application).applicant_can_edit?).to be_truthy
    end

    it 'true if state is "waiting for applicant"' do
      expect(create(:shf_application, state: :waiting_for_applicant).applicant_can_edit?).to be_truthy
    end


    describe 'false otherwise:' do
      other_states = described_class.all_states.reject{ |state| state.to_sym == :new || state.to_sym == :waiting_for_applicant }

      other_states.each do | other_state |
        it "#{other_state}" do
          expect(create(:shf_application, state: other_state).applicant_can_edit?).to be_falsey
        end
      end

    end
  end

end
