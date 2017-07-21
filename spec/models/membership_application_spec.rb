require 'rails_helper'
require 'aasm/rspec'

require 'support/ae_aasm_matchers/ae_aasm_matchers'

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


RSpec.describe MembershipApplication, type: :model do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:membership_application)).to be_valid
    end
  end

  describe 'DB Table' do
    it {is_expected.to have_db_column :id}
    it {is_expected.to have_db_column :company_number}
    it {is_expected.to have_db_column :phone_number}
    it {is_expected.to have_db_column :contact_email}
    it {is_expected.to have_db_column :membership_number}
    it {is_expected.to have_db_column :state}
    it {is_expected.to have_db_column :custom_reason_text}
  end

  describe 'Validations' do
    it {is_expected.to validate_presence_of :contact_email}
    it {is_expected.to validate_presence_of :company_number}
    it {is_expected.to validate_presence_of :state}

    it {is_expected.to allow_value('user@example.com').for(:contact_email)}
    it {is_expected.not_to allow_value('userexample.com').for(:contact_email)}

    it {is_expected.to validate_length_of(:company_number).is_equal_to(10)}
  end

  describe 'Validate Swedish Orgnr' do
    let (:company) do
      create(:membership_application)
    end

    subject {company}

    before do
      company.company_number = 1234567890
    end

    it {should_not be_valid}
  end

  describe 'Associations' do
    it {is_expected.to belong_to :user}
    it {is_expected.to have_and_belong_to_many :business_categories}
    it {is_expected.to belong_to :company}
    it {is_expected.to belong_to :waiting_reason}
  end

  describe "Uploaded Files" do

    let(:application_owner) {create(:user, email: 'user_1@random.com')}
    let(:application_owner2) {create(:user, email: 'user_2@random.com')}

    it 'uploading a file increases the number of uploaded files by 1' do
      expect {create(:membership_application, user: application_owner, uploaded_files: [create(:uploaded_file, actual_file: (File.new(File.join(FIXTURE_DIR, 'image.jpg'))))])}.to change(UploadedFile, :count).by(1)
    end

  end

  describe 'User attributes nesting' do

    let(:user) {create(:user, first_name: 'Firstname', last_name: 'Lastname')}
    let!(:member_app) {create(:membership_application, user: user, user_attributes: {first_name: 'New Firstname', last_name: 'New Lastname'})}

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
      }.to raise_exception(/#{I18n.t('activerecord.attributes.membership_application.first_name')} #{I18n.t('errors.messages.blank')}/)
    end

    it 'validates the presence of last_name' do
      expect {
        user.last_name = ''
        member_app.save!
      }.to raise_exception(/#{I18n.t('activerecord.attributes.membership_application.last_name')} #{I18n.t('errors.messages.blank')}/)
    end

  end

  describe '#is_accepted?' do
    let!(:states) {MembershipApplication.aasm.states.map(&:name)}
    let(:states_not_accepted) {states.reject {|s| s == :accepted}}

    it "state :accepted == is_accepted" do
      subject.state = :accepted
      expect(subject.is_accepted?).to be_truthy
    end

    it "these states should not be #is_accepted" do
      not_accepted_states = MembershipApplication.aasm.states.map(&:name).reject {|s| s == :accepted}

      not_accepted_states.each do |state|
        subject.state = state
        expect(subject.is_accepted?).to be_falsey
      end
    end

  end


  describe 'test factories' do

    it '1 category with default category name' do
      member_app = create(:membership_application, num_categories: 1)
      expect(member_app.business_categories.count).to eq(1)
      expect(member_app.business_categories.first.name)
          .to eq("Business Category"),
              "The first category name should have been 'Business Category'" \
        "but instead was '#{member_app.business_categories.first.name}'"
    end

    it '2 categories with sequence names' do
      member_app = create(:membership_application, num_categories: 2)
      expect(member_app.business_categories.count).to eq(2), "The number of categories should have been 2 but instead was #{member_app.business_categories.count}"
      expect(member_app.business_categories.first.name).to eq("Business Category 1"), "The first category name should have been 'Business Category 1' but instead was '#{member_app.business_categories.first.name}'"
      expect(member_app.business_categories.last.name).to eq("Business Category 2"), "The last category name should have been 'Business Category 2' but instead was '#{member_app.business_categories.first.name}'"
    end

    it '1 category with the name "Special"' do
      member_app = create(:membership_application, num_categories: 1,
                          category_name:                           "Special")
      expect(member_app.business_categories.count).to eq(1)
      expect(member_app.business_categories.first.name).to eq("Special"), "The first category name should have been 'Special' but instead was '#{member_app.business_categories.first.name}'"
    end

    it '3 categories with the name "Special 1, Special 2, Special 3"' do
      member_app = create(:membership_application, category_name: "Special", num_categories: 3)
      expect(member_app.business_categories.count).to eq(3)
      expect(member_app.business_categories.first.name).to eq("Special 1"), "The first category name should have been 'Special 1' but instead was '#{member_app.business_categories.first.name}'"
      expect(member_app.business_categories.last.name).to eq("Special 3"), "The first category name should have been 'Special 3' but instead was '#{member_app.business_categories.last.name}'"
    end


  end


  describe 'states, events, and transitions' do

    let!(:user) {create(:user_with_membership_app)}
    let!(:application) {user.membership_application}

    describe 'valid states' do
      it {expect(application).to have_valid_state(:new)}
      it {expect(application).to have_valid_state(:under_review)}
      it {expect(application).to have_valid_state(:waiting_for_applicant)}
      it {expect(application).to have_valid_state(:ready_for_review)}
      it {expect(application).to have_valid_state(:accepted)}
      it {expect(application).to have_valid_state(:rejected)}
    end


    it 'initial state = new' do
      expect(user.membership_application).to have_state(:new)
      expect(user.membership_application).not_to have_state(:ready_for_review)
      expect(user.membership_application).not_to have_state(:under_review)
      expect(user.membership_application).not_to have_state(:accepted)
      expect(user.membership_application).not_to have_state(:rejected)
      expect(user.membership_application).not_to have_state(:waiting_for_applicant)
    end


    describe 'valid events' do
      it {expect(application).to have_valid_event(:start_review)}
      it {expect(application).to have_valid_event(:ask_applicant_for_info)}
      it {expect(application).to have_valid_event(:cancel_waiting_for_applicant)}
      it {expect(application).to have_valid_event(:is_ready_for_review)}
      it {expect(application).to have_valid_event(:accept)}
      it {expect(application).to have_valid_event(:reject)}
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

  end


  describe '#se_mailing_csv_str (comma sep string) of the address for the swedish postal service' do

    let(:accepted_app) { create(:membership_application, :accepted) }
    let(:rejected_app) { create(:membership_application, :rejected)}  # no company for this

    it 'uses the company main address' do

      expect(accepted_app.se_mailing_csv_str).to eq AddressExporter.se_mailing_csv_str(accepted_app.company.main_address)

    end


    it 'blanks (just commas with no data between them) if there is no company' do

      expect(rejected_app.se_mailing_csv_str).to eq AddressExporter.se_mailing_csv_str(nil)

    end



  end


end
