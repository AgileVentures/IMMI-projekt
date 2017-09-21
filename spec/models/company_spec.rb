require 'rails_helper'

require_relative File.join('..', '..', 'app', 'services', 'address_exporter')


RSpec.describe Company, type: :model do

  let(:no_name) do
    create(:company, name: '', company_number: '2120000142')
  end

  let(:nil_region) do
    nil_co = create(:company, name: 'Nil Region',
                    company_number: '6112107039')

    no_region = build(:company_address, addressable: nil_co, region: nil)

    no_region.save(validate: false)

    nil_co
  end

  let(:complete_co) do
    create(:company, name: 'Complete Company',
           company_number: '4268582063')
  end

  let(:complete_co2) do
    create(:company, name: 'Complete Company 2',
                company_number: '5560360793')
  end

  let(:complete_co3) do
    co = create(:company, name: 'Complete Company 3',
               company_number: '5569467466', num_addresses: 0)
    create(:address, visibility: 'none', addressable: co)
    co.save!
    co
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
    it { is_expected.to have_db_column :description }
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
    it { is_expected.to have_many(:pictures) }
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

  describe '.address_visible' do
    it 'only returns companies that have one or more visible addresses' do
      complete_co2
      complete_co3
      expect(Company.address_visible).
          to contain_exactly(no_name, nil_region, complete_co, complete_co2)
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
      create(:membership_application,
             :accepted,
             user: employee1,
             num_categories: 0,
             company_number: company.company_number)
    end
    let(:m2) do
      create(:membership_application,
             :accepted, user: employee2,
             num_categories: 0,
             company_number: company.company_number)
    end
    let(:m3) do
      create(:membership_application,
             :accepted,
             user: employee3,
             num_categories: 0,
             company_number: company.company_number)
    end

    before(:all) do
      expect(Company.count).to eq(0)
      expect(MembershipApplication.count).to eq(0)
      expect(User.count).to eq(0)
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

    it 'creates a blank address if none exists' do
      company = create(:company, num_addresses: 0)

      expect(company.addresses.count).to eq 0

      # calling .main_address should instantiate an Address
      expect(company.main_address).to be_an_instance_of Address
      expect(company.addresses.count).to eq 1

    end

    it 'returns the first address for the company' do
      company = create(:company, num_addresses: 3)
      expect(company.addresses.count).to eq 3
      expect(company.main_address).to eq(company.addresses.first)
    end

  end


  describe '#se_mailing_csv_str (export CSV string for postal address)' do

    it 'just commas (no data between them) if there is no address' do
      company = build(:company)

      company.addresses.delete_all

      expected_str = AddressExporter.se_mailing_csv_str(Address.new)

      expect(company.se_mailing_csv_str).to eq expected_str

    end

    it 'uses the main address (1 address)' do

      company = create(:company)

      expected_str = AddressExporter.se_mailing_csv_str(company.main_address)

      expect(company.se_mailing_csv_str).to eq expected_str

    end

    it 'uses the main address when it has multiple addresses' do

      company = create(:company, num_addresses: 3)

      expected_str = AddressExporter.se_mailing_csv_str(company.main_address)

      expect(company.se_mailing_csv_str).to eq expected_str

    end

  end


  describe '#sanitize_website' do

    let(:company) { create(:company) }

    it 'website = "javascript://alert(alert-text)"' do
      company.website = "javascript://alert('alert-text')"
      company.save
      expect(company.website).to eq("://alert('alert-text')")
    end

    it 'website = "<script>alert("scriptalert("Boo!")")</script>"' do
      company.website = "<script>alert('scriptalert(Boo!)')</script>"
      company.save
      expect(company.website).to eq("alert('scriptalert(Boo!)')")
    end


  end
end
