require 'rails_helper'


RSpec.describe Adapters::CompanyToSchemaLocalBusiness do

  let(:co) do
    shf_app             = create(:shf_application, :accepted, num_categories: 2, create_company: true)
    company             = shf_app.companies.first
    company.description = '1 address, 2 categories'
    company
  end

  let(:test_adapter) { Adapters::CompanyToSchemaLocalBusiness.new(co, url: 'shf page for the company') }

  let(:schema_local_business) { test_adapter.set_target_attributes(test_adapter.target_class.new) }


  it 'target_class' do
    expect(test_adapter.target_class).to eq SchemaDotOrg::LocalBusiness
  end


  it 'image is the H-markt' do
    expect(schema_local_business.image).to match(/\/hundforetag\/#{co.id}\/company_h_brand/)
  end


  it 'name' do
    expect(schema_local_business.name).to eq 'SomeCompany'
  end


  it 'description' do
    expect(schema_local_business.description).to eq '1 address, 2 categories'
  end

  it 'email' do
    expect(schema_local_business.email).to eq 'thiscompany@example.com'
  end

  it 'url is the SHF page for the company' do
    expect(schema_local_business.url).to eq 'shf page for the company'
  end

  it 'telephone' do
    expect(schema_local_business.telephone).to eq '123123123'
  end


  describe "knowsAbout = business categories with I18n.t('dog').capitalize in front" do

    it 'is nil if no business categories' do
      co_no_cats = create(:company)
      adapter = Adapters::CompanyToSchemaLocalBusiness.new(co_no_cats)
      schema_localbiz_no_cats = adapter.set_target_attributes(adapter.target_class.new)

      expect(schema_localbiz_no_cats.knowsAbout).to be_nil
    end


    it 'array of the business category names' do
      dog_cap = I18n.t('dog').capitalize

      expect(schema_local_business.knowsAbout).to match_array ["#{dog_cap} Business Category 2", "#{dog_cap} Business Category 1"]
    end

  end


  it 'knowsLanguage is hardcoded sv-SE' do
    expect(schema_local_business.knowsLanguage).to eq 'sv-SE'
  end


  describe 'addresses' do

    describe '1 address' do

      it '1 complete address and 2 business categories' do

        expect(schema_local_business.location).to be_nil

        expect(schema_local_business.address.streetAddress).to eq 'Hundforetagarevägen 1'
        expect(schema_local_business.address.postalCode).to eq '310 40'
        expect(schema_local_business.address.addressRegion).to eq 'MyString'
        expect(schema_local_business.address.addressLocality).to eq 'Harplinge'
        expect(schema_local_business.address.addressCountry).to eq 'Sverige'
        expect(schema_local_business.geo.latitude).to eq 56.7422437
        expect(schema_local_business.geo.longitude).to eq 12.7206453

      end

    end


    describe 'multiple addresses' do

      let(:test_adapter_mult_addrs) {
        co             = create(:company)
        co.description = '3 addresses'
        addr2          = create(:address, addressable: co,
                                city: 'Plingshult',
                                region: create(:region, name: 'Halland'))
        co.addresses << addr2

        addr3          = create(:address, addressable: co,
                                street_address:        'Matarengivägen 24',
                                post_code:             '957 31',
                                city:                  'Övertorneå',
                                kommun:                create(:kommun, name: 'Övertorneå'),
                                region:                create(:region, name: 'Norrbotten'))
        co.addresses << addr3
        Adapters::CompanyToSchemaLocalBusiness.new(co)
      }

      let(:schema_biz_multaddr) { test_adapter_mult_addrs.set_target_attributes(test_adapter_mult_addrs.target_class.new) }


      it 'sets one main address and geocoordinates' do
        expect(schema_biz_multaddr.address.streetAddress).to eq 'Hundforetagarevägen 1'
        expect(schema_biz_multaddr.address.postalCode).to eq '310 40'
        expect(schema_biz_multaddr.address.addressRegion).to eq 'MyString'
        expect(schema_biz_multaddr.address.addressLocality).to eq 'Harplinge'
        expect(schema_biz_multaddr.address.addressCountry).to eq 'Sverige'
        expect(schema_biz_multaddr.geo.latitude).to eq 56.7422437
        expect(schema_biz_multaddr.geo.longitude).to eq 12.7206453
      end


      it 'creates location with array of Places' do
        expect(schema_biz_multaddr.location).to be_a Array
        expect(schema_biz_multaddr.location.size).to eq 3

        schema_biz_multaddr.location.each do | location_item |
          expect(location_item).to be_a SchemaDotOrg::Place
        end
      end

    end


    it 'no address' do
      co_no_address             = create(:company)
      co_no_address.description = 'no address'
      co_no_address.addresses   = []
      adapter_no_addr           = Adapters::CompanyToSchemaLocalBusiness.new(co_no_address)

      schema_locbiz_no_addr = adapter_no_addr.set_target_attributes(adapter_no_addr.target_class.new)

      expect(schema_locbiz_no_addr.location).to be_nil
    end


    it 'address missing street, postal code and city' do
      co_no_address                  = create(:company)
      co_no_address.description      = 'address has country only'
      co_no_address.addresses        = []
      addr_incomplete                = create(:address, addressable: co_no_address,
                                              region:                create(:region, name: 'Sveriges'),
                                              kommun:                create(:kommun, name: 'Stockholm'),
                                              visibility:            'kommun')
      addr_incomplete.street_address = ''
      addr_incomplete.city           = ''
      addr_incomplete.post_code      = ''
      addr_incomplete.latitude       = nil
      addr_incomplete.longitude      = nil

      adapter_incomplete_addr = Adapters::CompanyToSchemaLocalBusiness.new(co_no_address)

      schema_locbiz_incompl_addr = adapter_incomplete_addr.set_target_attributes(adapter_incomplete_addr.target_class.new)

      expect(schema_locbiz_incompl_addr.location).to be_nil
    end


  end


end
