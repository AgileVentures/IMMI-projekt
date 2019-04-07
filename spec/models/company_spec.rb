require 'rails_helper'

require 'shared_context/companies'

require_relative File.join('..', '..', 'app', 'services', 'address_exporter')


RSpec.describe Company, type: :model, focus: true do

  include_context 'create companies'


  let(:complete_companies) { [complete_co1] }

  let(:incomplete_companies) do
    incomplete_cos = []
    incomplete_cos << co_no_name
    incomplete_cos << co_nil_region
    incomplete_cos
  end

  let(:user) { create(:user) }

  let(:payment_date_2017) { Time.zone.local(2017, 10, 1) }
  let(:payment_date_2018) { Time.zone.local(2018, 11, 21) }
  let(:payment_date_2020) { Time.zone.local(2020, 3, 15) }

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
    it { is_expected.to have_db_column :short_h_brand_url }
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
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:application1) do
      create(:shf_application, company: company_3_addrs,
             company_number:            company_3_addrs.company_number, user: user1)
    end
    let(:application2) do
      create(:shf_application, company: company_3_addrs,
             company_number:            company_3_addrs.company_number, user: user2)
    end

    let(:payment_type) { Payment::PAYMENT_TYPE_BRANDING }
    let(:brand_pymt1) do
      create(:payment, company: company_3_addrs, payment_type: payment_type)
    end
    let(:brand_pymt2) do
      create(:payment, company: company_3_addrs, payment_type: payment_type)
    end

    let(:picture1) do
      pic                = Ckeditor::Picture.new
      pic.company_id     = company_3_addrs.id
      pic.data_file_name = 'test'
      pic.save!(validate: false)
      pic
    end

    let(:picture2) do
      pic                = Ckeditor::Picture.new
      pic.company_id     = company_3_addrs.id
      pic.data_file_name = 'test'
      pic.save!(validate: false)
      pic
    end

    it 'addresses' do
      expect { company_3_addrs }.to change(Address, :count).by(3)
      expect { company_3_addrs.destroy }.to change(Address, :count).by(-3)
    end

    it 'events' do
      event1
      event2
      expect { company_3_addrs.destroy }.to change(Event, :count).by(-2)
    end

    it 'pictures' do
      Ckeditor::Picture.for_company_id = company_3_addrs.id
      picture1
      picture2
      expect(company_3_addrs.pictures.count).to eq 2
      expect { company_3_addrs.destroy }.to change(Ckeditor::Picture, :count).by(-2)
    end

    it 'payments' do
      brand_pymt1
      brand_pymt2
      expect(company_3_addrs.payments.count).to eq 2
      expect { company_3_addrs.destroy }.to change(Payment, :count).by(-2)
    end
  end

  describe 'events update management' do

    around(:each) do |example|
      Timecop.freeze(Time.zone.local(2018, 6, 1))
      example.run
      Timecop.return
    end

    it '#events_start_date returns starting date for stored events' do
      expect(company_3_addrs.events_start_date).to eq 1.day.ago.to_date
    end

    context '#fetch_dinkurs_events', :vcr do
      it 'returns nil if no dinkurs_company_id' do
        expect(company_3_addrs.fetch_dinkurs_events).to be_nil
      end

      it 'removes previous events and returns nil if no dinkurs_company_id' do
        event1
        event2
        expect(company_3_addrs.events.count).to eq 2
        expect(company_3_addrs.fetch_dinkurs_events).to be_nil
        expect(company_3_addrs.events.count).to eq 0
      end

      it 'removes previous events and returns nil if invalid dinkurs_company_id' do
        company_3_addrs.dinkurs_company_id = 'nonesuch'
        event1
        event2
        expect(company_3_addrs.events.count).to eq 2
        expect(company_3_addrs.fetch_dinkurs_events).to be_nil
        expect(company_3_addrs.events.count).to eq 0
      end

      it 'returns events for valid dinkurs_company_id' do
        company_3_addrs.dinkurs_company_id = ENV['DINKURS_COMPANY_TEST_ID']
        expect(company_3_addrs.events.count).to eq 0
        expect(company_3_addrs.fetch_dinkurs_events).to_not be_nil
        expect(company_3_addrs.events.count).to_not eq 0
      end
    end

    context '#validate_key_and_fetch_dinkurs_events', :vcr do
      it 'returns true if dinkurs key is unchanged' do
        expect(company_3_addrs.validate_key_and_fetch_dinkurs_events).to eq true
      end

      it 'returns true if events are fetched' do
        company_3_addrs.dinkurs_company_id = ENV['DINKURS_COMPANY_TEST_ID']
        expect(company_3_addrs.validate_key_and_fetch_dinkurs_events).to eq true
      end

      it 'adds model error and returns false if invalid dinkurs key' do
        company_3_addrs.dinkurs_company_id = 'xyz'
        err                        = I18n.t('activerecord.errors.models.company.attributes.dinkurs_company_id.invalid')

        result = company_3_addrs.validate_key_and_fetch_dinkurs_events

        expect(result).to eq false
        expect(company_3_addrs.errors.full_messages.first).to match(/#{err}/)
      end
    end
  end

  describe 'categories = all employee categories' do

    let(:company_emp_cats) { create(:company) }

    let(:employee1) { create(:user) }
    let(:employee2) { create(:user) }
    let(:employee3) { create(:user) }

    let(:cat1) { create(:business_category, name: 'cat1') }
    let(:cat2) { create(:business_category, name: 'cat2') }
    let(:cat3) { create(:business_category, name: 'cat3') }

    let(:m1) do
      m           = create(:shf_application, :accepted, user: employee1)
      m.companies = [company_emp_cats]
      m
    end
    let(:m2) do
      m           = create(:shf_application, :accepted, user: employee2)
      m.companies = m1.companies.to_a
      m
    end
    let(:m3) do
      m           = create(:shf_application, :accepted, user: employee3)
      m.companies = m1.companies.to_a
      m
    end

    it '3 employees, each with 1 unique category' do
      m1.business_categories = [cat1]
      m2.business_categories = [cat2]
      m3.business_categories = [cat3]

      expect(company_emp_cats.business_categories.count).to eq 3
      expect(company_emp_cats.business_categories.map(&:name))
          .to contain_exactly('cat1', 'cat2', 'cat3')
    end

    it '3 employees, each with the same category' do
      m1.business_categories = [cat1]
      m2.business_categories = [cat1]
      m3.business_categories = [cat1]

      expect(company_emp_cats.business_categories.distinct.count).to eq 1
      expect(company_emp_cats.business_categories.count).to eq 3
      expect(company_emp_cats.business_categories.distinct.map(&:name))
          .to contain_exactly('cat1')
    end
  end


  describe '#current_members' do

    it 'is empty if no members' do
      company = create(:company)
      expect(company.current_members).to be_empty
    end

    it 'is empty if all members expiration date has past' do

      mem1_shf = create(:shf_application, :accepted)
      mem1_exp = mem1_shf.user
      mem1_co  = mem1_shf.companies.first

      create(:payment,
             :successful,
             user: mem1_exp,
             company: mem1_co,
             payment_type:   Payment::PAYMENT_TYPE_MEMBER,
             notes:          'these are notes for branding payment1, mem1_co',
             start_date:     payment_date_2017,
             expire_date:    payment_date_2017 + 365)


      Timecop.freeze(Date.new(2019, 1, 1)) do
        expect(mem1_co.current_members).to be_empty
      end
    end

    it 'only returns members with current membership' do

      ShfApplication.all_states.reject { |s| s == :accepted }.each do |a_state|
        create(:shf_application, state: a_state)
      end

      mem1_shf = create(:shf_application, :accepted)
      mem1_exp = mem1_shf.user
      mem1_co  = mem1_shf.companies.first

      create(:payment,
             :successful,
             user: mem1_exp,
             company: mem1_co,
             payment_type:   Payment::PAYMENT_TYPE_MEMBER,
             notes:          'these are notes for branding payment1,mem1_co',
             start_date:     Date.new(2018, 12, 1),
             expire_date:    Date.new(2018, 12, 1) + 365)

      Timecop.freeze(Date.new(2019, 1, 1)) do
        expect(mem1_co.current_members).to match_array([mem1_exp])
      end
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

    let(:company_sani_site) { create(:company) }

    it 'website = "javascript://alert(alert-text)"' do
      company_sani_site.website = "javascript://alert('alert-text')"
      company_sani_site.save
      expect(company_sani_site.website).to eq("://alert('alert-text')")
    end

    it 'website = "<script>alert("scriptalert("Boo!")")</script>"' do
      company_sani_site.website = "<script>alert('scriptalert(Boo!)')</script>"
      company_sani_site.save
      expect(company_sani_site.website).to eq ''
    end

  end

  describe '#sanitize_description' do

    let(:company_sani_desc) { create(:company) }

    it 'removes unwanted/malicious text' do
      company_sani_desc.description = "<img src=javascript:alert('Hello')>"
      company_sani_desc.save
      expect(company_sani_desc.description).to eq("<img>")
    end

    it 'website = "<script>alert("scriptalert("Boo!")")</script>"' do
      company_sani_desc.description = "<script>alert('scriptalert(Boo!)')</script>"
      company_sani_desc.save
      expect(company_sani_desc.description).to eq ''
    end
  end


  context 'payment and branding license period' do

    describe '#branding_expire_date' do
      it 'returns date for latest completed payment' do
        payment1_co1
        expect(complete_co1.branding_expire_date).to eq payment1_co1.expire_date
        payment2
        expect(complete_co1.branding_expire_date).to eq payment2.expire_date
      end
    end

    describe '#branding_payment_notes' do
      it 'returns notes for latest completed payment' do
        payment1_co1
        expect(complete_co1.branding_payment_notes).to eq payment1_co1.notes
        payment2
        expect(complete_co1.branding_payment_notes).to eq payment2.notes
      end
    end

    describe '#most_recent_branding_payment' do
      it 'returns latest completed payment' do
        payment1_co1
        expect(complete_co1.most_recent_branding_payment).to eq payment1_co1
        payment2
        expect(complete_co1.most_recent_branding_payment).to eq payment2
      end
    end


    describe '.self.next_branding_payment_dates' do

      around(:each) do |example|
        Timecop.freeze(payment_date_2018)
        example.run
        Timecop.return
      end

      it "returns today's date for first payment start date" do
        expect(Company.next_branding_payment_dates(complete_co1.id)[0]).to eq Time.zone.today
      end

      it 'returns one year later for first payment expire date' do
        expect(Company.next_branding_payment_dates(complete_co1.id)[1])
            .to eq Time.zone.today + 1.year - 1.day
      end

      it 'returns date-after-expiration for second payment start date' do
        payment1_co1
        expect(Company.next_branding_payment_dates(complete_co1.id)[0])
            .to eq Time.zone.today + 1.year
      end

      it 'returns one year later for second payment expire date' do
        payment1_co1
        expect(Company.next_branding_payment_dates(complete_co1.id)[1])
            .to eq Time.zone.today + 1.year + 1.year - 1.day
      end

      context 'if next payment occurs after prior payment expire date' do

        it 'returns actual payment date for start date' do
          payment1_co1
          Timecop.freeze(payment_date_2020)
          expect(Company.next_branding_payment_dates(complete_co1.id)[0])
              .to eq payment_date_2020
        end

        it 'returns payment date + 1 year for expire date' do
          payment1_co1
          Timecop.freeze(payment_date_2020)
          expect(Company.next_branding_payment_dates(complete_co1.id)[1])
              .to eq payment_date_2020 + 1.year - 1.day
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
      m           = create(:shf_application, :accepted, user: user1)
      m.companies = [cmpy1]
      m
    end

    let!(:cmpy1_app2) do
      m           = create(:shf_application, :accepted, user: user2)
      m.companies = [cmpy1]
      m
    end

    let!(:cmpy1_app3) do
      m           = create(:shf_application, :rejected, user: user3)
      m.companies = [cmpy1]
      m
    end

    let!(:cmpy2_app1) do
      m           = create(:shf_application, :accepted, user: user4)
      m.companies = [cmpy2]
      m
    end

    let!(:cmpy2_app2) do
      m           = create(:shf_application, :accepted, user: user5)
      m.companies = [cmpy2]
      m
    end

    let!(:cmpy2_app3) do
      m           = create(:shf_application, :accepted, user: user6)
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

    let(:cmpy2) do
      create(:company, company_number: '5562252998',
             street_address:           'Rehnsgatan 15',
             post_code:                '113 57',
             city:                     'Stockholm')
    end

    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:user3) { create(:user) }

    let(:app_co1_user1) do
      app           = create(:shf_application, user: user1)
      app.companies = [complete_co1]
      app
    end
    let(:app_co1_user2) do
      app           = create(:shf_application, user: user2)
      app.companies = [complete_co1]
      app
    end
    let(:app_co2_user3) do
      app           = create(:shf_application, user: user3)
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
        co_no_viz_addresses
        expect(Company.address_visible).
            to contain_exactly(co_no_name, co_nil_region, complete_co1, complete_co2)
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

        expect(Company.with_members).to contain_exactly(complete_co1)

        app_co2_user3.start_review
        app_co2_user3.accept!
        user3.update(member: true)

        expect(Company.with_members).to contain_exactly(complete_co1, cmpy2)
      end

      it 'returns company only once even if multiple members' do
        app_co1_user1.start_review
        app_co1_user1.accept!
        user1.update(member: true)

        app_co1_user2.start_review; app_co1_user2.accept!
        user2.update(member: true)

        expect(Company.with_members).to contain_exactly(complete_co1)
      end
    end

    context '.branding_licensed' do

      it 'returns all currently-licensed companies' do
        payment1_co1.update(expire_date: Time.zone.today - 1.day)
        payment2.update(expire_date: Time.zone.today - 1.day)
        expect(Company.branding_licensed).to be_empty

        payment1_co1.update(expire_date: Time.zone.today)
        expect(Company.branding_licensed).to contain_exactly(complete_co1)

        payment2.update(expire_date: Time.zone.today)
        expect(Company.branding_licensed).to contain_exactly(complete_co1)
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
        payment1_co1
        expect(Company.searchable).to contain_exactly(complete_co1)
      end

      it 'returns no companies if none have members' do
        app_co1_user1.start_review
        app_co1_user1.accept!
        payment1_co1
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
        payment1_co1
        expect(Company.searchable).to be_empty
      end

    end


    context '.at_addresses(addresses)' do

        let(:kista_co) do
            create(:company,
                 name:           'Stockholm Co',
                 street_address: 'Rehnsgatan 15',
                 post_code:      '113 57',
                 city:           'Stockholm')
        end

        let(:stockholm_co) do
          create(:company,
                 name:           'Kista Co',
                 street_address: 'AKALLALÄNKEN 10',
                 post_code:      '164 74',
                 city:           'Kista')
        end



      it 'returns all companies at these addresses' do
        kista_co
        stockholm_co

        kista_address = Address.find_by_city('Kista')
        expect(Company.at_addresses([kista_address]).map(&:name)).to match_array(['Kista Co'])
      end

      it 'no companies if addresses is empty' do
        kista_co
        stockholm_co

        expect(Company.at_addresses([]).size).to eq 0
      end

    end # end context '.at_addresses(addresses)' do

    context '.with_dinkurs_id' do

      it 'returns nil if no companies with non-empty dinkurs_company_id' do
        company_3_addrs
        expect(Company.with_dinkurs_id).to be_empty
      end

      it 'returns companies with dinkurs_company_id' do
        complete_co1
        complete_co2
        co_no_viz_addresses
        company_3_addrs.update_attribute(:dinkurs_company_id, ENV['DINKURS_COMPANY_TEST_ID'])
        expect(Company.with_dinkurs_id).not_to be_empty
        expect(Company.with_dinkurs_id).to contain_exactly(company_3_addrs)
      end

    end

  end #scopes

  describe '#get_short_h_brand_url' do
    context 'there is already a shortened url in the table' do
      it 'returns shortened url' do
        url = 'http://localhost:3000/anvandare/0/company_h_brand?company_id=1'
        expect(co_with_short_h_brand_url.get_short_h_brand_url(url)).to eq('http://www.tinyurl.com/hbrand')
      end
    end
    context 'there is no shortened url in the table and ShortenUrl.short is called' do
      it 'saves the result if the result is not nil and returns shortened url' do
        url = 'http://localhost:3000/anvandare/0/company_h_brand?company_id=1'
        allow(ShortenUrl).to receive(:short).with(url).and_return('http://tinyurl.com/hbrand2')
        expect(complete_co1.get_short_h_brand_url(url)).to eq(ShortenUrl.short(url))
        expect(complete_co1.short_h_brand_url).to eq(ShortenUrl.short(url))
      end
      it 'does not save anything if the result is nil and returns unshortened url' do
        url = 'http://localhost:3000/anvandare/0/company_h_brand?company_id=1'
        allow(ShortenUrl).to receive(:short).with(url).and_return(nil)
        expect(complete_co1.get_short_h_brand_url(url)).to eq(url)
        expect(complete_co1.short_h_brand_url).to eq(nil)
      end
    end
  end


  describe '#branding_license? always returns true || false, never nil' do

    context 'no payments' do

      it 'is false (never nil)' do
        expect(complete_co2.branding_license?).not_to be_nil
        expect(complete_co2.branding_license?).to be_falsey
      end

    end


    context 'payments expire before today - always false (never nil)' do

      let(:past_payments_co) { create(:company) }

      payment_statuses = Payment::ORDER_PAYMENT_STATUS.keys.reject(&:nil?)

      payment_statuses.each do | payment_status |

        context "#{payment_status} payments" do

          let(:payment_2017_10_1) do
            create(:payment, user: user, status: Payment::ORDER_PAYMENT_STATUS[payment_status],
                   company:        past_payments_co,
                   payment_type:   Payment::PAYMENT_TYPE_BRANDING,
                   notes:          'these are notes for branding payment_2017_10_1, past_payments_co',
                   start_date:     payment_date_2017,
                   expire_date:    (payment_date_2017.advance(days: 364) ) )
          end

          it 'is false (never nil)' do
            Timecop.freeze(2019, 1, 1) do
              payment_2017_10_1
              expect(past_payments_co.payments.size).to eq 1
              expect(past_payments_co.branding_license?).not_to be_nil
              expect(past_payments_co.branding_license?).to be false
            end

          end
        end #  context 'successful payments'

      end
    end # context 'payments before today'


    context 'payments expire after today' do

      let(:payment_start)  { Time.zone.local(2018, 1, 3)   }
      let(:payment_expire) { Time.zone.local(2019, 1, 2)   }
      let(:pretend_today)  { Time.zone.local(2018, 10, 10) }

      context 'successful payments' do

        let(:successful_payments_co) { create(:company) }

        let(:payment_2018_1_3) do
          create(:payment, :successful, user: user,
                 company:        successful_payments_co,
                 payment_type:   Payment::PAYMENT_TYPE_BRANDING,
                 notes:          'these are notes for branding payment_2018_1_3, successful_payments_co',
                 start_date:     payment_start,
                 expire_date:    Company.expire_date_for_start_date(payment_start) )
        end

        it 'is true' do
          Timecop.freeze( pretend_today ) do
            payment_2018_1_3
            expect(successful_payments_co.payments.size).to eq 1
            expect(successful_payments_co.branding_license?).to be_truthy
          end
        end
      end


      context 'not successful payments' do

        let(:not_successful_payments_co) { create(:company) }

        payment_statuses = Payment::ORDER_PAYMENT_STATUS.keys.reject(&:nil?).reject{|status| status == 'successful'}

        payment_statuses.each do | payment_status |

          let(:payment_2018_1_3) do
            create(:payment, user: user, status: Payment::ORDER_PAYMENT_STATUS[payment_status],
                   company:        not_successful_payments_co,
                   payment_type:   Payment::PAYMENT_TYPE_BRANDING,
                   notes:          'these are notes for branding payment_2018_1_3, not_successful_payments_co',
                   start_date:     payment_start,
                   expire_date:    Company.expire_date_for_start_date(payment_start) )
          end

          it "payment status #{payment_status}: is false (never nil)" do
            Timecop.freeze( pretend_today ) do
              payment_2018_1_3
              expect(not_successful_payments_co.payments.size).to eq 1
              expect(not_successful_payments_co.branding_license?).not_to be_nil
              expect(not_successful_payments_co.branding_license?).to be_falsey
            end
          end

        end

      end # context 'not successful payments'

    end # context 'payments after today'
  end # describe '#branding_license?'


  describe '#earliest_current_member_fee_paid' do
    #current_members.empty? ? nil : current_members.map(&:membership_start_date).sort.first'

    it 'is nil if there are no current members' do
      expect( (create(:company)).earliest_current_member_fee_paid ).to be_nil
    end


    it 'is the earliest membership_fee paid date for all current members' do

      dec_3 = Date.new(2018, 12, 3)
      dec_5 = Date.new(2018, 12, 5)

      member_paid_dec_3_shf_app = create(:shf_application, :accepted)
      member_paid_dec_3 = member_paid_dec_3_shf_app.user
      co_with_1_member_expires  = member_paid_dec_3_shf_app.companies.first

      create(:payment,
             :successful,
             user: member_paid_dec_3,
             company: co_with_1_member_expires,
             payment_type:   Payment::PAYMENT_TYPE_MEMBER,
             notes:          'these are notes for a member payment, co_with_1_member_expires',
             start_date:     dec_3,
             expire_date:    Company.expire_date_for_start_date(dec_3) )

      member_paid_dec_5_shf_app = create(:shf_application, :accepted, company_number: co_with_1_member_expires.company_number)
      member_paid_dec_5 = member_paid_dec_5_shf_app.user

      create(:payment,
             :successful,
             user: member_paid_dec_5,
             company: co_with_1_member_expires,
             payment_type:   Payment::PAYMENT_TYPE_MEMBER,
             notes:          'these are notes for a member payment, co_with_1_member_expires',
             start_date:     dec_5,
             expire_date:    Company.expire_date_for_start_date(dec_5) )

      member_dec_3_start = member_paid_dec_3.payment_start_date(Payment::PAYMENT_TYPE_MEMBER)
      member_dec_3_start_time = Time.utc(member_dec_3_start.year, member_dec_3_start.month, member_dec_3_start.day)

      member_dec_3_expiry = member_paid_dec_3.payment_expire_date(Payment::PAYMENT_TYPE_MEMBER)
      member_dec_3_expiry_time = Time.utc(member_dec_3_expiry.year, member_dec_3_expiry.month, member_dec_3_expiry.day)

      day_before_member_dec_3_expiry = member_dec_3_expiry - 1
      day_before_member_dec_3_expiry_time = Time.utc(day_before_member_dec_3_expiry.year, day_before_member_dec_3_expiry.month, day_before_member_dec_3_expiry.day)

      member_dec_5_start = member_paid_dec_5.payment_start_date(Payment::PAYMENT_TYPE_MEMBER)
      member_dec_5_start_time = Time.utc(member_dec_5_start.year, member_dec_5_start.month, member_dec_5_start.day)


      Timecop.freeze( day_before_member_dec_3_expiry_time ) do

        # update membership status based on today's date
        MembershipStatusUpdater.instance.user_updated(member_paid_dec_3)
        MembershipStatusUpdater.instance.user_updated(member_paid_dec_5)

        expect(co_with_1_member_expires.current_members.size).to eq 2
        expect( co_with_1_member_expires.earliest_current_member_fee_paid ).to eq member_dec_3_start_time
      end


      Timecop.freeze( member_dec_3_expiry_time) do
        # update membership status based on today's date
        MembershipStatusUpdater.instance.user_updated(member_paid_dec_3)
        MembershipStatusUpdater.instance.user_updated(member_paid_dec_5)

        expect(co_with_1_member_expires.current_members.size).to eq 1
        expect( co_with_1_member_expires.earliest_current_member_fee_paid ).to eq member_dec_5_start_time
      end

    end

  end # describe '#earliest_current_member_fee_paid'


  describe '#missing_region?' do

    describe 'false if all addresses have a region' do
      it 'only address has a region' do
        expect(complete_co1.missing_region?).to be_falsey
      end

      it 'all addresses have a region' do
        complete_co1.addresses << build(:company_address, addressable: complete_co1)
        complete_co1.addresses << build(:company_address, addressable: complete_co1)
        expect(complete_co1.missing_region?).to be_falsey
      end
    end

    describe 'true if 1 or more addresses have no region' do

      it 'only address does not have a region' do
        co_nil_region.addresses.first.region = nil  # just in case it's been changed by other tests
        expect(co_nil_region.missing_region?).to be_truthy
      end

      it 'one of many addresses does not have a region' do
        co_nil_region.addresses.first.region = nil  # just in case it's been changed by other tests

      # add some valid addresses (Region is not nil)
        co_nil_region.addresses << build(:company_address, addressable: co_nil_region)
        co_nil_region.addresses << build(:company_address, addressable: co_nil_region)

        expect(co_nil_region.missing_region?).to be_truthy
      end
    end
  end

end
