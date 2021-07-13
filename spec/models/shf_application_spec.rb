require 'rails_helper'
require 'aasm/rspec'

require 'support/ae_aasm_matchers/ae_aasm_matchers'


RSpec.describe ShfApplication, type: :model do

  let(:mock_log) { instance_double("ActivityLogger") }

  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)

    # stub this so we don't have to create the MasterChecklist for the Member Guidelines checklist
    # if a ShfApplication is accepted.
    simple_guideline = create(:user_checklist, :completed, master_checklist: build(:membership_guidelines_master_checklist))
    allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for).and_return(simple_guideline)
  end


  shared_examples 'allow transition to' do |start_state, to_state, transition_event|

    it "#{to_state}" do
      expect(application).to transition_from(start_state).to(to_state).on_event(transition_event), "expected to transition from #{start_state} to #{to_state} on event #{transition_event}"
    end
  end

  shared_examples 'not allow transition to' do |start_state, to_state|
    it "#{to_state}" do

      application.aasm(:default).current_state = start_state.to_sym

      expect(application).not_to allow_transition_to(to_state), "expected to not to be able to transition from #{start_state} to #{to_state}"
    end
  end


  describe 'Factory' do
    it 'has a valid factory' do
      expect(build(:shf_application)).to be_valid
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
    it { is_expected.not_to allow_value('userexample@.com').for(:contact_email) }
    it { is_expected.not_to allow_value('exåmple@example.com').for(:contact_email) }

    describe 'uniqueness of user across all applications' do
      subject { FactoryBot.build(:shf_application) }
      it { is_expected.to validate_uniqueness_of(:user_id) }
    end
  end


  context 'Scopes' do

    describe 'not_decided and accepted' do
      let!(:accepted_app1) { create(:shf_application, :accepted) }
      let!(:accepted_app2) { create(:shf_application, :accepted) }
      let!(:rejected_app1) { create(:shf_application, :rejected) }
      let!(:new_app1) { create(:shf_application) }

      describe 'not_decided' do
        it 'returns all apps not accepted or rejected' do
          expect(described_class.not_decided.all).to contain_exactly(new_app1)
        end
      end

      describe 'accepted' do
        it 'returns all accepted apps' do
          expect(described_class.accepted.all)
              .to contain_exactly(accepted_app1, accepted_app2)
        end
      end

    end


    context 'no uploaded files in the system' do

      describe 'decided_with_no_uploaded_files = apps that have not yet been decided AND have no uploaded files' do

        let!(:new_app_1) do
          create(:shf_application, user: create(:user, email: 'new-applicant-1@random.com'),
                 contact_email: "new-0-uploads--applicant-2@random.com")
        end

        let!(:new_app_2) do
          create(:shf_application, user: create(:user, email: 'new-applicant-2@random.com'),
                 contact_email: "new-0-uploads--applicant-2@random.com")
        end

        let!(:waiting_app) do
          create(:shf_application, state: :waiting_for_applicant, user: create(:user, email: 'waiting_for-applicant@random.com'),
                 contact_email: "new-0-uploads--applicant-2@random.com")
        end

        let!(:ready_for_review_app) do
          create(:shf_application, state: :ready_for_review, user: create(:user, email: 'ready_for_review-applicant@random.com'),
                 contact_email: "new-0-uploads--applicant-2@random.com")
        end

        let!(:rejected_app) do
          create(:shf_application, :rejected, user: create(:user, email: 'rejected-applicant-7@random.com'),
                 contact_email: "rejected-0-uploads--rejected-applicant-7@random.com")
        end

        it 'returns 2 apps when there are 2 not_decided apps without uploads, 4 rejected apps without uploads' do
          expect(described_class.decided_with_no_uploaded_files).to contain_exactly(new_app_1,
                                                                                    new_app_2,
                                                                                    waiting_app,
                                                                                    ready_for_review_app)
        end
      end
    end


    context 'there are uploaded files in the system' do

      let!(:new_0_uploads) do
        user =  create(:user, email: 'applicant-1@random.com')
        create(:shf_application, user: user,
               contact_email: "new-0-uploads--#{user.email}")
      end

      let!(:waiting_0_uploads) do
        user = create(:user, email: 'applicant-2@random.com')
        create(:shf_application, state: :waiting_for_applicant, user: user,
               contact_email: "waiting-0-uploads--#{user.email}")
      end

      let!(:new_1_upload) do
        user = create(:user, email: 'applicant-3@random.com')
        shf_app = create(:shf_application, user: user,
                         contact_email: "new-1--#{user.email}")
        shf_app.uploaded_files << create(:uploaded_file, :jpg, shf_application: shf_app)
        shf_app
      end

      let!(:rejected_0_uploads) do
        user = create(:user, email: 'rejected-applicant-1@random.com')
        create(:shf_application, :rejected, user: user,
               contact_email: "rejected-0-uploads--#{user.email}")
      end

      let!(:rejected_1_uploads) do
        user = create(:user, email: 'rejected-applicant-2@random.com')
        shf_app = create(:shf_application, :rejected, user: user,
               contact_email: "rejected-0-uploads--#{user.email}")
        shf_app.uploaded_files << create(:uploaded_file, :jpg, shf_application: shf_app)
      end

      let!(:accepted_0_uploads_a) do
        member = create(:member, email: 'accepted_no-upload-1@random.com')
        shf_app = member.shf_application
        shf_app.contact_email = "accepted-0--#{member.email}"
        shf_app
      end

      let!(:accepted_0_uploads_b) do
        member = create(:member, email: 'accepted_no-upload-2@random.com')
        shf_app = member.shf_application
        shf_app.contact_email = "accepted-0--#{member.email}"
        shf_app
      end

      let!(:accepted_1_upload_a) do
        member = create(:member, email: 'accepted_1-upload@random.com')
        shf_app = member.shf_application
        shf_app.contact_email = "accepted-1--#{member.email}"
        shf_app.uploaded_files << create(:uploaded_file, :jpg, shf_application: shf_app)
        shf_app
      end

      let!(:accepted_1_upload_b) do
        member = create(:member, email: 'accepted_2-upload@random.com')
        shf_app = member.shf_application
        shf_app.contact_email = "accepted-1--#{member.email}"
        shf_app.uploaded_files << create(:uploaded_file, :jpg, shf_application: shf_app)
        shf_app
      end

      let!(:accepted_1_upload_c) do
        member = create(:member, email: 'accepted_3-upload@random.com')
        shf_app = member.shf_application
        shf_app.contact_email = "accepted-1--#{member.email}"
        shf_app.uploaded_files << create(:uploaded_file, :jpg, shf_application: shf_app)
        shf_app
      end


      describe '2 not_decided apps with ZERO uploads, 1 new app with uploads, 4 decided apps with uploads, 3 decided apps with no uploads' do

        it 'decided_with_no_uploaded_files count = 2' do
          result = described_class.decided_with_no_uploaded_files
          expect(result.count).to eq 2
          expect(result).to contain_exactly(new_0_uploads, waiting_0_uploads)
        end

      end
    end

  end


  context 'User proof_of_membership (POM) JPG and Company h-brand JPG cache management' do
    let(:user) { create(:user) }
    let(:company) { create(:company) }
    let(:company2) { create(:company) }
    let!(:application) do
      create(:shf_application,
             user: user,
             companies: [company, company2])
    end


    describe 'after_update :clear_image_caches' do

      before(:each) do
        user.proof_of_membership_jpg = file_fixture('image.png')
        company.h_brand_jpg = file_fixture('image.png')
        company2.h_brand_jpg = file_fixture('image.png')
      end

      it "clears user POM cache and related-companies' h-brand caches" do
        expect(application).to receive(:clear_image_caches).once.and_call_original
        expect(user).to receive(:clear_proof_of_membership_jpg_cache).once.and_call_original
        expect(company).to receive(:clear_h_brand_jpg_cache).once.and_call_original
        expect(company2).to receive(:clear_h_brand_jpg_cache).once.and_call_original
        expect(user.proof_of_membership_jpg).to_not be_nil
        expect(company.h_brand_jpg).to_not be_nil
        expect(company2.h_brand_jpg).to_not be_nil

        application.update_attributes(phone_number: '1234')

        expect(user.proof_of_membership_jpg).to be_nil
        expect(company.h_brand_jpg).to be_nil
        expect(company2.h_brand_jpg).to be_nil
      end
    end
  end


  describe "Uploaded Files" do

    let(:application_owner) { create(:user, email: 'user_1@random.com') }
    let(:applicant_2) { create(:user, email: 'user_2@random.com') }

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


  describe 'Factories' do

    it 'has valid factories' do
      expect(build(:shf_application)).to be_valid
    end

    describe 'categories' do

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


  describe 'marked_ready_for_review' do
    pending
  end


  describe 'marked_ready_for_review=' do
    pending
  end


  describe 'not_a_member?' do
    it 'true only if the user is not_a_member' do
      not_member_app = build(:shf_application)
      expect(not_member_app.not_a_member?).to be_truthy
    end
  end



  describe 'company_numbers and company_names' do
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


  describe 'possibly_waiting_for_upload?' do
    # Only these states can be waiting for file uploads
    STATES_CAN_BE_WAITING = %w(new under_review waiting_for_applicant)

    context 'states that can be waiting for uploads' do

      STATES_CAN_BE_WAITING.each do | s |
        it "true for state: #{s}" do
          allow(subject).to receive(:state).and_return(s)
          expect(subject.possibly_waiting_for_upload?).to be_truthy
        end
      end
    end

    context 'states that cannot be waiting for uploads' do
      ALL_OTHER_STATES = described_class.all_states - STATES_CAN_BE_WAITING
      ALL_OTHER_STATES.each do | s |
        it "false for state: #{s}" do
          allow(subject).to receive(:state).and_return(s)
          expect(subject.possibly_waiting_for_upload?).to be_falsey
        end
      end
    end

  end


  describe 'upload_files_will_be_delivered_later?' do

    it 'true if file_delivery_method.email? is true' do
      mock_file_delivery_email = instance_double('AdminOnly::FileDeliveryMethod', name:'email' )
      allow(mock_file_delivery_email).to receive(:email?)
                                             .and_return(true)
      allow(mock_file_delivery_email).to receive(:mail?)
                                             .and_return(false)

      allow(subject).to receive(:file_delivery_method)
                            .and_return(mock_file_delivery_email)
      expect(subject.upload_files_will_be_delivered_later?).to be_truthy
    end

    it 'true if file_delivery_method.mail? is true' do
      mock_file_delivery_mail = instance_double('AdminOnly::FileDeliveryMethod', name:'email' )
      allow(mock_file_delivery_mail).to receive(:email?)
                                             .and_return(true)
      allow(mock_file_delivery_mail).to receive(:mail?)
                                             .and_return(false)

      allow(subject).to receive(:file_delivery_method)
                            .and_return(mock_file_delivery_mail)
      expect(subject.upload_files_will_be_delivered_later?).to be_truthy
    end

    it 'false if file_delivery_method.email? is false and file_delivery_method.email? is false' do
      mock_file_delivery_other = instance_double('AdminOnly::FileDeliveryMethod', name:'email' )
      allow(mock_file_delivery_other).to receive(:email?)
                                            .and_return(false)
      allow(mock_file_delivery_other).to receive(:mail?)
                                            .and_return(false)

      allow(subject).to receive(:file_delivery_method)
                            .and_return(mock_file_delivery_other)

      expect(subject.upload_files_will_be_delivered_later?).to be_falsey
    end
  end


  describe 'Business Subcategories' do

    let(:parent) { create(:business_category, name: 'parent') }
    let(:unassociated_category) { create(:business_category) }

    let(:child1) { parent.children.create(name: 'child 1') }
    let(:child2) { parent.children.create(name: 'child 2') }
    let(:child3) { parent.children.create(name: 'child 3') }
    let(:child4) { parent.children.create(name: 'child 4') }
    let(:child5) { parent.children.create(name: 'child 5') }

    let(:app) do
      app = build(:shf_application, num_categories: 0)
      app.business_categories = [parent, child1, child2, child3]
      app.save!
      app
    end

    describe '#business_subcategories' do

      it 'returns all subcategories for a category associated with the app' do
        expect(app.business_subcategories(parent)).to eq [child1, child2, child3]
      end

      it 'returns nil if called with a subcategory' do
        expect(app.business_subcategories(child1)).to be_nil
      end

      it 'returns nil if category is not associated with this application' do
        expect(app.business_subcategories(unassociated_category)).to be_nil
      end
    end

    describe '#set_business_subcategories' do

      it 'set subcategories for a category associated with the app' do
        app.set_business_subcategories(parent, [child4, child5])
        expect(app.business_subcategories(parent)).to eq [child4, child5]
      end

      it 'takes no action if called with a subcategory' do
        app.set_business_subcategories(child1, [child4, child5])
        expect(app.business_subcategories(parent)).to eq [child1, child2, child3]
      end

      it 'takes no action if called with an unassociated category' do
        app.set_business_subcategories(unassociated_category, [child4, child5])
        expect(app.business_subcategories(parent)).to eq [child1, child2, child3]
      end
    end
  end

end
