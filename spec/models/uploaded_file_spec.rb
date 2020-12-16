require 'rails_helper'
require 'shared_context/unstub_paperclip_file_commands'


RSpec.describe UploadedFile, type: :model do

  # These are required to get the content type and validate it
  include_context 'unstub Paperclip file commands'


  describe 'Factory' do
    it 'has valid factories' do
      expect(build(:uploaded_file)).to be_valid
      expect(build(:uploaded_file, user:(build(:user)))).to be_valid
      expect(build(:uploaded_file, user:(build(:user)), shf_application:(build(:shf_application)))).to be_valid
      expect(build(:uploaded_file_for_application)).to be_valid
      expect(build(:uploaded_file_for_application, shf_application: (build(:shf_application)))).to be_valid
      expect(build(:uploaded_file_for_application, user: build(:user))).to be_valid
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

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :actual_file_file_name }
    it { is_expected.to have_db_column :actual_file_content_type }
    it { is_expected.to have_db_column :actual_file_file_size }
    it { is_expected.to have_db_column :actual_file_updated_at }
    it { is_expected.to have_db_column :description }
  end

  describe 'Validations' do

    it { should validate_attachment_content_type(:actual_file)
                    .allowing(UploadedFile::ALLOWED_FILE_TYPES.values)
                    .rejecting('bin', 'exe') }
  end

  describe 'Associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:shf_application).optional }
    it { should have_attached_file :actual_file }
  end

  describe 'Scopes' do

    it '.sort_by_user_full_name' do
      user_AA = create(:user, first_name: 'A', last_name: 'A')
      user_AB = create(:user, first_name: 'A', last_name: 'B')
      user_ZZ = create(:user, first_name: 'Z', last_name: 'Z')

      upload_ZZ = create(:uploaded_file, user: user_ZZ)
      upload_AA = create(:uploaded_file, user: user_AA)
      upload_AB = create(:uploaded_file, user: user_AB)

      expect(described_class.sort_by_user_full_name).to eq([upload_AA, upload_AB, upload_ZZ])
    end

    it '.sort_by_user_full_name_asc calls sort_by_user_full_name with (:asc) order direction' do
      expect(described_class).to receive(:sort_by_user_full_name).with(:asc)
      described_class.sort_by_user_full_name_asc
    end

    it '.sort_by_user_full_name_desc calls sort_by_user_full_name with (:desc) order direction' do
      expect(described_class).to receive(:sort_by_user_full_name).with(:desc)
      described_class.sort_by_user_full_name_desc
    end
  end

  describe '.allowed_file_types' do
    it 'hash with keys = the allowed file type extensions, values = the allowed file type mime types' do
      expect(described_class.allowed_file_types).to be_a Hash
    end

    it 'flattened keys are jpg, .jpg, .gif, .png, .txt. .rtf, .pdf, .doc, .dot, .docx, .docm' do
      expect(described_class.allowed_file_types.keys.flatten).to match_array [".jpeg", ".jpg", ".gif", ".png", ".txt", ".rtf", ".pdf", ".doc", ".dot", ".docx", ".docm"]
    end
  end

  describe 'allowed_file_types' do
    it 'calls the class version of this method' do
      expect(described_class).to receive(:allowed_file_types)
      subject.allowed_file_types
    end
  end

  describe 'can_edit?' do

    context 'has a shf_application' do

      it 'false if shf_application is under review' do
        uploaded_file = build(:uploaded_file_for_application, shf_application: build(:shf_application, :under_review))
        expect(uploaded_file.can_edit?).to be_falsey
      end

      it 'false if shf_application is accepted' do
        uploaded_file = build(:uploaded_file_for_application, shf_application: build(:shf_application, :accepted))
        expect(uploaded_file.can_edit?).to be_falsey
      end

      it 'false if shf_application is rejected' do
        uploaded_file = build(:uploaded_file_for_application, shf_application: build(:shf_application, :accepted))
        expect(uploaded_file.can_edit?).to be_falsey
      end

      context 'true if shf_application is not under_review, being destroyed, accepted, rejected' do

        other_states = ShfApplication.all_states - [:under_review, :accepted, :rejected, :being_destroyed]
        other_states.each do | other_state |
          it "#{other_state}" do
            uploaded_file = build(:uploaded_file_for_application, shf_application: build(:shf_application, state: other_state))
            expect(uploaded_file.can_edit?).to be_truthy
          end
        end
      end
    end

    it 'true if no shf_application' do
      uploaded_file = build(:uploaded_file)
      expect(uploaded_file.can_edit?).to be_truthy
    end
  end


  describe 'can_delete?' do

    context 'has a shf_application' do

      it 'false if shf_application is under review' do
        uploaded_file = build(:uploaded_file_for_application, shf_application: build(:shf_application, :under_review))
        expect(uploaded_file.can_delete?).to be_falsey
      end
      it 'false if shf_application is accepted' do
        uploaded_file = build(:uploaded_file_for_application, shf_application: build(:shf_application, :accepted))
        expect(uploaded_file.can_delete?).to be_falsey
      end

      it 'false if shf_application is rejected' do
        uploaded_file = build(:uploaded_file_for_application, shf_application: build(:shf_application, :accepted))
        expect(uploaded_file.can_delete?).to be_falsey
      end

      context 'true if shf_application is not being destroyed, under review, accepted, rejected' do

        other_states = ShfApplication.all_states - [:under_review, :accepted, :rejected, :being_destroyed]
        other_states.each do | other_state |
          it "#{other_state}" do
            uploaded_file = build(:uploaded_file_for_application, shf_application: build(:shf_application, state: other_state))
            expect(uploaded_file.can_delete?).to be_truthy
          end
        end
      end
    end

    it 'true if no shf_application' do
      uploaded_file = build(:uploaded_file)
      expect(uploaded_file.can_delete?).to be_truthy
    end
  end
end
