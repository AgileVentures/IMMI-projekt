require 'rails_helper'

RSpec.describe MembershipApplication, type: :model do
  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:membership_application)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :first_name }
    it { is_expected.to have_db_column :last_name }
    it { is_expected.to have_db_column :company_number }
    it { is_expected.to have_db_column :phone_number }
    it { is_expected.to have_db_column :contact_email }
    it { is_expected.to have_db_column :status }
    it { is_expected.to have_db_column :membership_number }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :contact_email }
    it { is_expected.to validate_presence_of :company_number }
    it { is_expected.to validate_presence_of :last_name }
    it { is_expected.to validate_presence_of :status }

    it { is_expected.to allow_value('user@example.com').for(:contact_email) }
    it { is_expected.not_to allow_value('userexample.com').for(:contact_email) }

    it { is_expected.to validate_length_of(:company_number).is_equal_to(10) }
  end

  describe 'Validate Swedish Orgnr' do
    let (:company) do
      create(:membership_application)
    end

    subject { company }

    before do
      company.company_number = 1234567890
    end

    it { should_not be_valid }
  end

  describe 'Associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to have_and_belong_to_many :business_categories }
    it { is_expected.to belong_to :company }
  end

  describe "Uploaded Files" do

    let(:application_owner) { create(:user, email: 'user_1@random.com') }
    let(:application_owner2) { create(:user, email: 'user_2@random.com') }

    it 'uploading a file increases the number of uploaded files by 1' do
      expect { create(:membership_application, user: application_owner, uploaded_files: [ create(:uploaded_file, actual_file: (File.new(File.join(FIXTURE_DIR, 'image.jpg'))) ) ]) }.to change(UploadedFile, :count).by(1)
    end

  end

  describe '#is_accepted?' do
    it "true: status = 'Godkänd'" do
      subject.status = 'Godkänd'
      expect(subject.is_accepted?).to be_truthy
    end
    it "true: status = 'Avböjd'" do
      subject.status = 'Avböjd'
      expect(subject.is_accepted?).to be_falsey
    end
    it "true: status = 'Pending'" do
      subject.status = 'Pending'
      expect(subject.is_accepted?).to be_falsey
    end
    it "true: status = 'Behandlas'" do
      subject.status = 'Behandlas'
      expect(subject.is_accepted?).to be_falsey
    end
    it "true: status = 'Inväntar betalning'" do
      subject.status = 'Inväntar betalning'
      expect(subject.is_accepted?).to be_falsey
    end
    it "true: status = 'Inväntar komplettering'" do
      subject.status = 'Inväntar komplettering'
      expect(subject.is_accepted?).to be_falsey
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
                          category_name: "Special")
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

end
