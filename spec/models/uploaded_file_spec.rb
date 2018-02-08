require 'rails_helper'

RSpec.describe UploadedFile, type: :model do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:uploaded_file)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :actual_file_file_name }
    it { is_expected.to have_db_column :actual_file_content_type }
    it { is_expected.to have_db_column :actual_file_file_size }
    it { is_expected.to have_db_column :actual_file_updated_at }
  end

  describe 'Validations' do

    it { should validate_attachment_content_type(:actual_file)
                    .allowing(UploadedFile::ALLOWED_FILE_TYPES.values)
                    .rejecting('bin', 'exe') }
  end

  describe 'Associations' do
    it { is_expected.to belong_to :shf_application }
    it { should have_attached_file :actual_file }
  end

  describe "accepted content types" do
    it "png" do
      expect(build(:uploaded_file, :png)).to be_valid
    end
    it "gif" do
      expect(build(:uploaded_file, :gif)).to be_valid
    end
    it "jpg" do
      expect(build(:uploaded_file, :jpg)).to be_valid
    end

    it "pdf" do
      expect(build(:uploaded_file, :pdf)).to be_valid
    end
    it "txt" do
      expect(build(:uploaded_file, :txt)).to be_valid
    end
    it "Microsoft Word doc" do
      expect(build(:uploaded_file, :doc)).to be_valid
    end
    it "Microsoft Word .docx" do
      expect(build(:uploaded_file, :docx)).to be_valid
    end
    it "Microsoft Word macro enabled doc (.docm)" do
      expect(build(:uploaded_file, :docm)).to be_valid
    end

  end

  describe "unacceptable contented types" do

    it "binary" do
      expect(build(:uploaded_file, :bin)).not_to be_valid
    end

    it ".exe" do
      expect(build(:uploaded_file, :exe)).not_to be_valid
    end


  end

end
