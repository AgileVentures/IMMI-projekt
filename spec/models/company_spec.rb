require 'rails_helper'

RSpec.describe Company, type: :model do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:company)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :company_number }
    it { is_expected.to have_db_column :phone_number }
    it { is_expected.to have_db_column :email }
    it { is_expected.to have_db_column :street }
    it { is_expected.to have_db_column :post_code }
    it { is_expected.to have_db_column :city }
    it { is_expected.to have_db_column :region }
    it { is_expected.to have_db_column :website }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :company_number }

    it { is_expected.to validate_length_of(:company_number).is_equal_to(10) }

    it { is_expected.to allow_value('user@example.com').for(:email) }
    it { is_expected.not_to allow_value('userexample.com').for(:email) }

  end

  describe 'Associations' do
    it { is_expected.to have_and_belong_to_many :business_categories }
  end


end
