require 'rails_helper'

RSpec.describe CompanyApplication, type: :model do
  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:company_application)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :company_id }
    it { is_expected.to have_db_column :shf_application_id }
  end

  describe 'Associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to belong_to :shf_application }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:company) }
    it { is_expected.to validate_presence_of(:shf_application) }
    it 'validates uniqueness of company<>shf_application association' do
      subject { FactoryBot.build(:company_application)
      is_expected.to validate_uniqueness_of(:company_id).scoped_to(:shf_application) }
    end
  end
end
