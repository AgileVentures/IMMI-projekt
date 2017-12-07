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

  let(:complete_companies) { [complete_co] }

  let(:incomplete_companies) do
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
    it { is_expected.to have_many(:membership_applications).dependent(:destroy) }
    it { is_expected.to have_many(:addresses).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:addresses)}
    it { is_expected.to have_many(:pictures) }
    it { is_expected.to have_many(:users).through(:membership_applications) }
    it { is_expected.to have_many(:payments) }
    it { is_expected.to accept_nested_attributes_for(:payments)}
  end


  describe 'complete scope' do
    let(:complete_scope) { Company.complete }

    before(:each) do
      complete_companies
      incomplete_companies
    end

    it 'only returns companies that are complete' do
      expect(complete_scope).to match_array(complete_companies)
    end

    it 'does not return any incomplete companies' do
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
      expect(company.addresses.to_ary.count).to eq 1

    end

    it 'returns mail address for company' do
      company = create(:company, num_addresses: 3)
      company.addresses[1].update(mail: true)
      expect(company.main_address).to eq(company.addresses.second)
    end

    it 'returns the first address for the company if no mail address' do
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

  context 'payment and branding license period' do
    let(:user) { create(:user) }
    let(:company) { create(:company) }

    let(:success) { Payment.order_to_payment_status('successful') }

    let(:payment_date_2017) { Time.zone.local(2017, 10, 1) }

    let(:payment_date_2018) { Time.zone.local(2018, 11, 21) }

    let(:payment1) do
      start_date, expire_date = Company.next_branding_payment_dates(company.id)
      create(:payment, user: user, status: success, company: company,
             payment_type: Payment::PAYMENT_TYPE_BRANDING,
             notes: 'these are notes for branding payment1',
             start_date: start_date,
             expire_date: expire_date)
    end
    let(:payment2) do
      start_date, expire_date = Company.next_branding_payment_dates(company.id)
      create(:payment, user: user, status: success, company: company,
             payment_type: Payment::PAYMENT_TYPE_BRANDING,
             notes: 'these are notes for branding payment2',
             start_date: start_date,
             expire_date: expire_date)
    end

    describe '#branding_expire_date' do
      it 'returns date for latest completed payment' do
        payment1
        expect(company.branding_expire_date).to eq payment1.expire_date
        payment2
        expect(company.branding_expire_date).to eq payment2.expire_date
      end
    end

    describe '#branding_payment_notes' do
      it 'returns notes for latest completed payment' do
        payment1
        expect(company.branding_payment_notes).to eq payment1.notes
        payment2
        expect(company.branding_payment_notes).to eq payment2.notes
      end
    end

    describe '#most_recent_branding_payment' do
      it 'returns latest completed payment' do
        payment1
        expect(company.most_recent_branding_payment).to eq payment1
        payment2
        expect(company.most_recent_branding_payment).to eq payment2
      end
    end

    describe '.self.next_branding_payment_dates' do

      context 'during the year 2017' do

        around(:each) do |example|
          Timecop.freeze(payment_date_2017)
          example.run
          Timecop.return
        end

        it "returns today's date for first payment start date" do
          expect(Company.next_branding_payment_dates(company.id)[0])
            .to eq Time.zone.today
        end

        it 'returns Dec 31, 2018 for first payment expire date' do
          expect(Company.next_branding_payment_dates(company.id)[1])
            .to eq Time.zone.local(2018, 12, 31)
        end

        it 'returns Jan 1, 2019 for second payment start date' do
          payment1
          expect(Company.next_branding_payment_dates(company.id)[0])
            .to eq Time.zone.local(2019, 1, 1)
        end

        it 'returns Dec 31, 2019 for second payment expire date' do
          payment1
          expect(Company.next_branding_payment_dates(company.id)[1])
            .to eq Time.zone.local(2019, 12, 31)
        end
      end

      context 'after the year 2017' do

        around(:each) do |example|
          Timecop.freeze(payment_date_2018)
          example.run
          Timecop.return
        end

        it "returns today's date for first payment start date" do
          expect(Company.next_branding_payment_dates(company.id)[0]).to eq Time.zone.today
        end

        it 'returns one year later for first payment expire date' do
          expect(Company.next_branding_payment_dates(company.id)[1])
            .to eq Time.zone.today + 1.year - 1.day
        end

        it 'returns date-after-expiration for second payment start date' do
          payment1
          expect(Company.next_branding_payment_dates(company.id)[0])
            .to eq Time.zone.today + 1.year
        end

        it 'returns one year later for second payment expire date' do
          payment1
          expect(Company.next_branding_payment_dates(company.id)[1])
            .to eq Time.zone.today + 1.year + 1.year - 1.day
        end
      end
    end

    describe 'scope: branding_licensed' do
      it 'returns all currently-licensed companies' do
        payment1.update(expire_date: Time.zone.today - 1.day)
        payment2.update(expire_date: Time.zone.today - 1.day)
        expect(Company.branding_licensed).to be_empty

        payment1.update(expire_date: Time.zone.today)
        expect(Company.branding_licensed).to contain_exactly(company)

        payment2.update(expire_date: Time.zone.today)
        expect(Company.branding_licensed).to contain_exactly(company)
      end
    end
  end

  describe '#approved_applications_from_members' do
    let(:cmpy1) { create(:company, company_number: '5560360793') }
    let(:cmpy2) { create(:company, company_number: '5562252998') }

    let(:user1) { create(:user, member: true) }
    let(:user2) { create(:user, member: true) }
    let(:user3) { create(:user, member: true) }
    let(:user4) { create(:user) }

    let!(:cmpy1_app1) do
      create(:membership_application, :accepted,
             company_number: cmpy1.company_number, user: user1)
    end

    let!(:cmpy1_app2) do
      create(:membership_application, :accepted,
             company_number: cmpy1.company_number, user: user2)
    end

    let!(:cmpy1_app3) do
      create(:membership_application, :rejected,
             company_number: cmpy1.company_number, user: user3)
    end

    let!(:cmpy2_app1) do
      create(:membership_application, :accepted,
             company_number: cmpy2.company_number, user: user1)
    end

    let!(:cmpy2_app2) do
      create(:membership_application, :accepted,
             company_number: cmpy2.company_number, user: user2)
    end

    let!(:cmpy2_app3) do
      create(:membership_application, :accepted,
             company_number: cmpy1.company_number, user: user4)
    end

    it 'returns only apps that are 1) accepted and 2) from members' do
      expect(cmpy1.approved_applications_from_members)
        .to contain_exactly(cmpy1_app1, cmpy1_app2)

      expect(cmpy2.approved_applications_from_members)
        .to contain_exactly(cmpy2_app1, cmpy2_app2)
    end
  end
end
