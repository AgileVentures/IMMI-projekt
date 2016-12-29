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
    it { is_expected.to have_db_column :region_id }
    it { is_expected.to have_db_column :old_region }
    it { is_expected.to have_db_column :website }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :company_number }

    it { is_expected.to validate_length_of(:company_number).is_equal_to(10) }

    it { is_expected.to allow_value('user@example.com').for(:email) }
    it { is_expected.not_to allow_value('userexample.com').for(:email) }

  end

  describe 'Associations' do
    it { is_expected.to have_many(:business_categories).through(:membership_applications) }
    it { is_expected.to have_many(:membership_applications) }
    it { is_expected.to belong_to(:region) }
  end


  describe 'categories = all employee categories' do

    let(:company) { create(:company, company_number: '5562252998') }

    let(:employee1) { create(:user) }
    let(:employee2) { create(:user) }
    let(:employee3) { create(:user) }

    let(:cat1) { create(:business_category, name: 'cat1') }
    let(:cat2) { create(:business_category, name: 'cat2') }
    let(:cat3) { create(:business_category, name: 'cat3') }

    let(:m1) do
      create(:membership_application, user: employee1,
             num_categories: 0, status: 'Godkänd',
             company_number: company.company_number)
    end
    let(:m2) do
      create(:membership_application, user: employee2,
             num_categories: 0, status: 'Godkänd',
             company_number: company.company_number)
    end
    let(:m3) do
      create(:membership_application, user: employee3,
             num_categories: 0, status: 'Godkänd',
             company_number: company.company_number)
    end

    before(:all) do
      Company.delete_all
      MembershipApplication.delete_all
      User.delete_all
    end

    it '3 employees, each with 1 unique category' do
      m1.business_categories << cat1
      m2.business_categories << cat2
      m3.business_categories << cat3

      expect(company.business_categories.count).to eq 3
      expect(company.business_categories.map(&:name))
          .to contain_exactly('cat1', 'cat2', 'cat3')
    end

    it '3 employees, each with the same category' do
      m1.business_categories << cat1
      m2.business_categories << cat1
      m3.business_categories << cat1

      expect(company.business_categories.distinct.count).to eq 1
      expect(company.business_categories.count).to eq 3
      expect(company.business_categories.distinct.map(&:name))
          .to contain_exactly('cat1')
    end
  end

end
