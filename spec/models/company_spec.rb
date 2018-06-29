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

  let(:user) { create(:user) }

  let(:success) { Payment.order_to_payment_status('successful') }

  let(:payment_date_2017) { Time.zone.local(2017, 10, 1) }

  let(:payment_date_2018) { Time.zone.local(2018, 11, 21) }

  let(:payment1) do
    start_date, expire_date = Company.next_branding_payment_dates(complete_co.id)
    create(:payment, user: user, status: success, company: complete_co,
           payment_type: Payment::PAYMENT_TYPE_BRANDING,
           notes: 'these are notes for branding payment1',
           start_date: start_date,
           expire_date: expire_date)
  end
  let(:payment2) do
    start_date, expire_date = Company.next_branding_payment_dates(complete_co.id)
    create(:payment, user: user, status: success, company: complete_co,
           payment_type: Payment::PAYMENT_TYPE_BRANDING,
           notes: 'these are notes for branding payment2',
           start_date: start_date,
           expire_date: expire_date)
  end

  let(:company) { create(:company, num_addresses: 3) }

  let(:event1) { create(:event, company: company) }
  let(:event2) { create(:event, company: company) }


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
    it { is_expected.to have_db_column :dinkurs_company_id }
    it { is_expected.to have_db_column :show_dinkurs_events }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :company_number }
    it { is_expected.to validate_length_of(:company_number).is_equal_to(10) }
    it { is_expected.to allow_value('user@example.com').for(:email) }
    it { is_expected.not_to allow_value('userexample.com').for(:email) }

    describe 'uniqueness of company_number' do
      let(:msg) { I18n.t('activerecord.errors.models.company.attributes.company_number.taken') }
      subject { FactoryBot.build(:company) }

      it 'uniqueness of company_number' do
        expect(subject).to validate_uniqueness_of(:company_number)
                             .with_message(msg).case_insensitive
      end
    end

    describe 'swedish org number' do
      it { is_expected.to allow_values('5560360793', '2120000142')
                            .for(:company_number) }
      it { is_expected.not_to allow_values('0123456789', '212000')
                            .for(:company_number) }
    end
  end

  describe 'Associations' do
    it { is_expected.to have_many(:business_categories).through(:shf_applications) }
    it { is_expected.to have_many(:company_applications) }
    it { is_expected.to have_many(:shf_applications).through(:company_applications) }
    it { is_expected.to have_many(:addresses).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:addresses).allow_destroy(true) }
    it do
      is_expected.to have_many(:pictures).dependent(:destroy)
                       .class_name(Ckeditor::Picture)
    end
    it { is_expected.to have_many(:users).through(:shf_applications) }
    it { is_expected.to have_many(:payments) }
    it { is_expected.to accept_nested_attributes_for(:payments).allow_destroy(false) }
    it { is_expected.to have_many(:events).dependent(:destroy) }
  end

  describe 'destroy associated records when company is destroyed' do
    let(:user1)   { create(:user) }
    let(:user2)   { create(:user) }
    let(:application1) do
      create(:shf_application, company: company,
             company_number: company.company_number, user: user1)
    end
    let(:application2) do
      create(:shf_application, company: company,
             company_number: company.company_number, user: user2)
    end

    let(:payment_type) { Payment::PAYMENT_TYPE_BRANDING }
    let(:brand_pymt1) do
      create(:payment, company: company, payment_type: payment_type)
    end
    let(:brand_pymt2) do
      create(:payment, company: company, payment_type: payment_type)
    end

    let(:picture1) do
      pic = Ckeditor::Picture.new
      pic.company_id = company.id
      pic.data_file_name = 'test'
      pic.save!(validate: false)
      pic
    end

    let(:picture2) do
      pic = Ckeditor::Picture.new
      pic.company_id = company.id
      pic.data_file_name = 'test'
      pic.save!(validate: false)
      pic
    end

    it 'addresses' do
      expect { company }.to change(Address, :count).by(3)
      expect { company.destroy }.to change(Address, :count).by(-3)
    end

    it 'events' do
      event1
      event2
      expect { company.destroy }.to change(Event, :count).by(-2)
    end

    it 'pictures' do
      Ckeditor::Picture.for_company_id = company.id
      picture1
      picture2
      expect(company.pictures.count).to eq 2
      expect { company.destroy }.to change(Ckeditor::Picture, :count).by(-2)
    end

    it 'payments' do
      brand_pymt1
      brand_pymt2
      expect(company.payments.count).to eq 2
      expect { company.destroy }.to change(Payment, :count).by(-2)
    end
  end

  describe 'events update management' do
    it '#events_start_date returns starting date for stored events' do
      expect(company.events_start_date).to eq 1.day.ago.to_date
    end

    context '#fetch_dinkurs_events', :vcr do
      it 'returns nil if no dinkurs_company_id' do
        expect(company.fetch_dinkurs_events).to be_nil
      end

      it 'removes previous events and returns nil if no dinkurs_company_id' do
        event1
        event2
        expect(company.events.count).to eq 2
        expect(company.fetch_dinkurs_events).to be_nil
        expect(company.events.count).to eq 0
      end

      it 'removes previous events and returns nil if invalid dinkurs_company_id' do
        company.dinkurs_company_id = 'nonesuch'
        event1
        event2
        expect(company.events.count).to eq 2
        expect(company.fetch_dinkurs_events).to be_nil
        expect(company.events.count).to eq 0
      end

      it 'returns events for valid dinkurs_company_id' do
        company.dinkurs_company_id = ENV['DINKURS_COMPANY_TEST_ID']
        expect(company.events.count).to eq 0
        expect(company.fetch_dinkurs_events).to_not be_nil
        expect(company.events.count).to_not eq 0
      end
    end

    context '#validate_key_and_fetch_dinkurs_events', :vcr do
      it 'returns true if dinkurs key is unchanged' do
        expect(company.validate_key_and_fetch_dinkurs_events).to eq true
      end

      it 'returns true if events are fetched' do
        company.dinkurs_company_id = ENV['DINKURS_COMPANY_TEST_ID']
        expect(company.validate_key_and_fetch_dinkurs_events).to eq true
      end

      it 'adds model error and returns false if invalid dinkurs key' do
        company.dinkurs_company_id = 'xyz'
        err = I18n.t('activerecord.errors.models.company.attributes.dinkurs_company_id.invalid')

        result = company.validate_key_and_fetch_dinkurs_events

        expect(result).to eq false
        expect(company.errors.full_messages.first).to match(/#{err}/)
      end
    end
  end

  describe 'categories = all employee categories' do

    let(:company) { create(:company) }

    let(:employee1) { create(:user) }
    let(:employee2) { create(:user) }
    let(:employee3) { create(:user) }

    let(:cat1) { create(:business_category, name: 'cat1') }
    let(:cat2) { create(:business_category, name: 'cat2') }
    let(:cat3) { create(:business_category, name: 'cat3') }

    let(:m1) do
      m = create(:shf_application, :accepted, user: employee1)
      m.companies = [company]
      m
    end
    let(:m2) do
      m = create(:shf_application, :accepted, user: employee2)
      m.companies = m1.companies.to_a
      m
    end
    let(:m3) do
      m = create(:shf_application, :accepted, user: employee3)
      m.companies = m1.companies.to_a
      m
    end

    it '3 employees, each with 1 unique category' do
      m1.business_categories = [cat1]
      m2.business_categories = [cat2]
      m3.business_categories = [cat3]

      expect(company.business_categories.count).to eq 3
      expect(company.business_categories.map(&:name))
          .to contain_exactly('cat1', 'cat2', 'cat3')
    end

    it '3 employees, each with the same category' do
      m1.business_categories = [cat1]
      m2.business_categories = [cat1]
      m3.business_categories = [cat1]

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

  describe '#sanitize_description' do

    let(:company) { create(:company) }

    it 'removes unwanted/malicious text' do
      company.description = "<img src=javascript:alert('Hello')>"
      company.save
      expect(company.description).to eq("<img>")
    end

    it 'website = "<script>alert("scriptalert("Boo!")")</script>"' do
      company.description = "<script>alert('scriptalert(Boo!)')</script>"
      company.save
      expect(company.description).to eq("alert('scriptalert(Boo!)')")
    end
  end

  context 'payment and branding license period' do

    describe '#branding_expire_date' do
      it 'returns date for latest completed payment' do
        payment1
        expect(complete_co.branding_expire_date).to eq payment1.expire_date
        payment2
        expect(complete_co.branding_expire_date).to eq payment2.expire_date
      end
    end

    describe '#branding_payment_notes' do
      it 'returns notes for latest completed payment' do
        payment1
        expect(complete_co.branding_payment_notes).to eq payment1.notes
        payment2
        expect(complete_co.branding_payment_notes).to eq payment2.notes
      end
    end

    describe '#most_recent_branding_payment' do
      it 'returns latest completed payment' do
        payment1
        expect(complete_co.most_recent_branding_payment).to eq payment1
        payment2
        expect(complete_co.most_recent_branding_payment).to eq payment2
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
          expect(Company.next_branding_payment_dates(complete_co.id)[0])
            .to eq Time.zone.today
        end

        it 'returns Dec 31, 2018 for first payment expire date' do
          expect(Company.next_branding_payment_dates(complete_co.id)[1])
            .to eq Time.zone.local(2018, 12, 31)
        end

        it 'returns Jan 1, 2019 for second payment start date' do
          payment1
          expect(Company.next_branding_payment_dates(complete_co.id)[0])
            .to eq Time.zone.local(2019, 1, 1)
        end

        it 'returns Dec 31, 2019 for second payment expire date' do
          payment1
          expect(Company.next_branding_payment_dates(complete_co.id)[1])
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
          expect(Company.next_branding_payment_dates(complete_co.id)[0]).to eq Time.zone.today
        end

        it 'returns one year later for first payment expire date' do
          expect(Company.next_branding_payment_dates(complete_co.id)[1])
            .to eq Time.zone.today + 1.year - 1.day
        end

        it 'returns date-after-expiration for second payment start date' do
          payment1
          expect(Company.next_branding_payment_dates(complete_co.id)[0])
            .to eq Time.zone.today + 1.year
        end

        it 'returns one year later for second payment expire date' do
          payment1
          expect(Company.next_branding_payment_dates(complete_co.id)[1])
            .to eq Time.zone.today + 1.year + 1.year - 1.day
        end
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
    let(:user5) { create(:user, member: true) }
    let(:user6) { create(:user, member: true) }

    let!(:cmpy1_app1) do
      m = create(:shf_application, :accepted, user: user1)
      m.companies = [cmpy1]
      m
    end

    let!(:cmpy1_app2) do
      m = create(:shf_application, :accepted, user: user2)
      m.companies = [cmpy1]
      m
    end

    let!(:cmpy1_app3) do
      m = create(:shf_application, :rejected, user: user3)
      m.companies = [cmpy1]
      m
    end

    let!(:cmpy2_app1) do
      m = create(:shf_application, :accepted, user: user4)
      m.companies = [cmpy2]
      m
    end

    let!(:cmpy2_app2) do
      m = create(:shf_application, :accepted, user: user5)
      m.companies = [cmpy2]
      m
    end

    let!(:cmpy2_app3) do
      m = create(:shf_application, :accepted, user: user6)
      m.companies = [cmpy2]
      m
    end

    it 'returns only apps that are 1) accepted and 2) from members' do
      expect(cmpy1.approved_applications_from_members)
        .to contain_exactly(cmpy1_app1, cmpy1_app2)

      expect(cmpy2.approved_applications_from_members)
        .to contain_exactly(cmpy2_app2, cmpy2_app3)
    end
  end

  describe 'scopes' do

    let(:cmpy2) { create(:company, company_number: '5562252998') }

    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:user3) { create(:user) }

    let(:app_co1_user1) do
      app = create(:shf_application, user: user1)
      app.companies = [complete_co]
      app
    end
    let(:app_co1_user2) do
      app = create(:shf_application, user: user2)
      app.companies = [complete_co]
      app
    end
    let(:app_co2_user3) do
      app = create(:shf_application, user: user3)
      app.companies = [cmpy2]
      app
    end

    let(:complete_scope) { Company.complete }

    context '.complete' do

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

    context '.address_visible' do

      it 'only returns companies that have one or more visible addresses' do
        complete_co2
        complete_co3
        expect(Company.address_visible).
            to contain_exactly(no_name, nil_region, complete_co, complete_co2)
      end
    end

    context '.with_members' do

      before(:each) { app_co1_user1; app_co1_user2; app_co2_user3 }

      it 'returns no companies if no members' do
        expect(Company.with_members).to be_empty
      end

      it 'returns all companies with members' do
        app_co1_user1.start_review
        app_co1_user1.accept!
        user1.update(member: true)

        expect(Company.with_members).to contain_exactly(complete_co)

        app_co2_user3.start_review
        app_co2_user3.accept!
        user3.update(member: true)

        expect(Company.with_members).to contain_exactly(complete_co, cmpy2)
      end

      it 'returns company only once even if multiple members' do
        app_co1_user1.start_review
        app_co1_user1.accept!
        user1.update(member: true)

        app_co1_user2.start_review; app_co1_user2.accept!
        user2.update(member: true)

        expect(Company.with_members).to contain_exactly(complete_co)
      end
    end

    context '.branding_licensed' do

      it 'returns all currently-licensed companies' do
        payment1.update(expire_date: Time.zone.today - 1.day)
        payment2.update(expire_date: Time.zone.today - 1.day)
        expect(Company.branding_licensed).to be_empty

        payment1.update(expire_date: Time.zone.today)
        expect(Company.branding_licensed).to contain_exactly(complete_co)

        payment2.update(expire_date: Time.zone.today)
        expect(Company.branding_licensed).to contain_exactly(complete_co)
      end
    end

    context '.searchable' do

      it 'returns no companies if no companies exist' do
        expect(Company.searchable).to be_empty
      end

      it 'returns all companies that are complete, have member(s) and paid-up' do
        app_co1_user1.start_review
        app_co1_user1.accept!
        user1.update(member: true)
        payment1
        expect(Company.searchable).to contain_exactly(complete_co)
      end

      it 'returns no companies if none have members' do
        app_co1_user1.start_review
        app_co1_user1.accept!
        payment1
        expect(Company.searchable).to be_empty
      end

      it 'returns no companies if none are paid-up' do
        app_co1_user1.start_review
        app_co1_user1.accept!
        user1.update(member: true)
        expect(Company.searchable).to be_empty
      end

      it 'returns no companies if none have members' do
        app_co1_user1.start_review
        app_co1_user1.accept!
        payment1
        expect(Company.searchable).to be_empty
      end

    end
  end

end
