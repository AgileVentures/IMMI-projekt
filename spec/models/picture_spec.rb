require 'rails_helper'

RSpec.describe Ckeditor::Picture, type: :model do

  let!(:company1) { create(:company) }
  let!(:company2) { create(:company, company_number: '5562252998') }

  let(:picture1) { Ckeditor::Picture.create(data: file_fixture('image.png').open) }
  let(:picture2) { Ckeditor::Picture.create(data: file_fixture('image.png').open) }
  let(:picture3) { Ckeditor::Picture.create(data: file_fixture('image.png').open) }
  let(:picture4) { Ckeditor::Picture.create(data: file_fixture('image.png').open) }
  let(:picture5) { Ckeditor::Picture.create(data: file_fixture('image.png').open) }
  let(:picture6) { Ckeditor::Picture.create(data: file_fixture('image.png').open) }

  # Since we cannot test the :company association, all we can do is verify that
  # it exists in the database:
  describe 'DB Table' do
    it { is_expected.to have_db_column(:company_id).with_options( null: true )}
  end

  describe 'Associations' do
    # Note that we cannot test the belongs_to association because it can sometimes be nil
    # and the presence is only required (validated) _ if => lambda { /company/.match(@@category) }_
    #   (if the current class category matches /company/)
    # and the shoulda-matchers gem version 4.0.1 is not sophisticated enough to be able to
    # test validity of (belongs_to  ... optional: true) + (validates_presence_of ... with an :if clause)
    #
    # This fails because the matchers cannot also test
    # for the validation_presence_of ... with the :if clause at the same time:
    #   it { is_expected.to belong_to(:company).optional }
  end

  describe 'Validations' do
    Ckeditor::Picture.images_category = 'company_1'

    it { is_expected.to have_attached_file :data }
    it { is_expected.to validate_attachment_presence :data }
    it { is_expected.to validate_attachment_size(:data).in(0..2.megabytes) }
  end

  describe "company can be nil" do

    context "category = 'member_pages'" do
      it 'company can be nil' do
        Ckeditor::Picture.images_category = 'member_pages'
        Ckeditor::Picture.for_company_id = nil
        picture1
        expect(picture1.company).to be_nil
      end
    end

    context "category is not 'member_pages'" do
      it "company can be nil" do
        Ckeditor::Picture.images_category = 'blorf'
        Ckeditor::Picture.for_company_id = nil
        picture4
        expect(picture4.company).to be_nil
      end
    end

  end


  describe 'class and instance methods - company images' do

    before(:each) do
      Ckeditor::Picture.images_category = 'company_1'
      Ckeditor::Picture.for_company_id = company1.id
      picture1
      picture3
      Ckeditor::Picture.images_category = 'company_2'
      Ckeditor::Picture.for_company_id = company2.id
      picture2
      picture4
    end

    it 'sets class vars' do
      expect(Ckeditor::Picture.class_variable_get(:@@category)).
        to eq('company_2')
      expect(Ckeditor::Picture.class_variable_get(:@@company_id)).
        to eq(company2.id)
    end

    it 'sets company id for image record' do
      expect(picture1.company_id).to eq company1.id
      expect(picture2.company_id).to eq company2.id
    end

    it 'fetches images for subject company' do
      Ckeditor::Picture.for_company_id = company1.id
      expect(Ckeditor::Picture.all).to match_array [picture1, picture3]

      Ckeditor::Picture.for_company_id = company2.id
      expect(Ckeditor::Picture.all).to match_array [picture2, picture4]
    end
  end

  describe 'class and instance methods - member pages images' do
    before(:each) do
      Ckeditor::Picture.images_category = 'company_1'
      Ckeditor::Picture.for_company_id = company1.id
      picture1
      picture3
      Ckeditor::Picture.images_category = 'member_pages'
      Ckeditor::Picture.for_company_id = nil
      picture5
      picture6
    end

    it 'sets class vars' do
      expect(Ckeditor::Picture.class_variable_get(:@@category)).to eq('member_pages')
      expect(Ckeditor::Picture.class_variable_get(:@@company_id)).to be_nil
    end

    it 'fetches images for member pages' do
      Ckeditor::Picture.images_category = 'member_pages'

      expect(Ckeditor::Picture.all).to match_array [picture5, picture6]
    end
  end
end
