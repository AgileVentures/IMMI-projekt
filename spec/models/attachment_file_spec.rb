require 'rails_helper'

RSpec.describe Ckeditor::AttachmentFile, type: :model do

  describe 'DB Table' do
    it { is_expected.to have_db_column :company_id }
  end

  describe 'Validations' do
    it { is_expected.to have_attached_file :data }
    it { is_expected.to validate_attachment_presence :data }
    it { is_expected.to validate_attachment_size(:data).less_than(2.megabytes) }
  end
end
