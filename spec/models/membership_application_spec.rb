require 'rails_helper'

RSpec.describe MembershipApplication, type: :model do
  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:membership_application)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :company_name }
    it { is_expected.to have_db_column :company_number }
    it { is_expected.to have_db_column :contact_person }
    it { is_expected.to have_db_column :phone_number }
    it { is_expected.to have_db_column :company_email }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :company_name }
    it { is_expected.to validate_presence_of :company_number }
    it { is_expected.to validate_presence_of :contact_person }
    it { is_expected.to validate_presence_of :company_email }

    it { is_expected.to allow_value('user@example.com').for(:company_email) }
    it { is_expected.not_to allow_value('userexample.com').for(:company_email) }

    it { is_expected.to validate_length_of(:company_number).is_equal_to(10) }
  end

  describe 'Associations' do
    it { is_expected.to belong_to :user }
  end
end
