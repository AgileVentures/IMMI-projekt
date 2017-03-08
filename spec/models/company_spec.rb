require 'rails_helper'

RSpec.describe Company, type: :model do

  let(:no_name) do
    create(:company, name: '', company_number: '2120000142')
  end

  let(:nil_region) do
    nil_co = create(:company, name: 'Nil Region',
                     company_number: '6112107039')

    no_region = create(:company_address, addressable: nil_co, region: nil)

    nil_co
  end

  let(:complete_co) do
    create(:company, name: 'Complete Company',
                     company_number: '4268582063')
  end

  let!(:complete_companies) { [complete_co] }

  let!(:incomplete_companies) do
    incomplete_cos = []
    incomplete_cos << no_name
    incomplete_cos << nil_region
    incomplete_cos
  end

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

    it { is_expected.to have_many(:addresses) }
  end


  describe 'complete scope' do

    it 'only returns companies that are complete' do

      complete_scope = Company.complete
      expect(complete_scope).to match_array(complete_companies)
    end

    it 'does not return any incomplete companies' do
      complete_scope = Company.complete
      expect(complete_scope & incomplete_companies).to match_array([])
    end

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
      create(:membership_application, :accepted, user: employee1,
             num_categories: 0,
             company_number: company.company_number)
    end
    let(:m2) do
      create(:membership_application, :accepted, user: employee2,
             num_categories: 0,
             company_number: company.company_number)
    end
    let(:m3) do
      create(:membership_application, :accepted, user: employee3,
             num_categories: 0,
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


  describe '#main_address' do

    let(:company) { create(:company, num_addresses: 3) }

    it 'returns the first address for the company' do
      expect(company.addresses.count).to eq 3
      expect(company.main_address).to eq(company.addresses.first)
    end

  end

end
