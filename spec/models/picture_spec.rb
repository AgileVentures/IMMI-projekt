require 'rails_helper'

RSpec.describe Ckeditor::Picture, type: :model do

  let!(:company1) { create(:company) }
  let!(:company2) { create(:company, company_number: '5562252998') }

  let(:picture1) { Ckeditor::Picture.create(data: file_fixture('image.png').open) }
  let(:picture2) { Ckeditor::Picture.create(data: file_fixture('image.png').open) }
  let(:picture3) { Ckeditor::Picture.create(data: file_fixture('image.png').open) }
  let(:picture4) { Ckeditor::Picture.create(data: file_fixture('image.png').open) }

  describe 'DB Table' do
    it { is_expected.to have_db_column :company_id }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:company) }
  end

  describe 'Validations' do
    it { is_expected.to have_attached_file :data }
    it { is_expected.to validate_attachment_presence :data }
    it { is_expected.to validate_attachment_size(:data).in(0..2.megabytes) }
    it { is_expected.to validate_presence_of :company }
  end

  describe 'class and instance methods' do

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
end
