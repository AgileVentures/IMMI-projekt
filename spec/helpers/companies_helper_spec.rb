require 'rails_helper'

RSpec.describe CompaniesHelper, type: :helper do
  let(:company) { create(:company) }
  let(:user) { create(:user) }

  describe 'companies' do
    let(:employee1) { create(:user) }
    let(:employee2) { create(:user) }
    let(:employee3) { create(:user) }

    let!(:ma1) do
      ma = create(:shf_application, :accepted, user: employee1, category_name: 'cat1')
      ma
    end
    let!(:ma2) do
      ma = create(:shf_application, :accepted, user: employee2, category_name: 'cat2')
      ma.companies = ma1.companies
      ma
    end
    let!(:ma3) do
      ma = create(:shf_application, :accepted, user: employee3, category_name: 'cat3')
      ma.companies = ma1.companies
      ma
    end

    it '#list_categories' do
      company = ma1.companies.first
      expect(helper.list_categories(company)).to eq 'cat1 cat2 cat3'
      expect(helper.list_categories(company)).not_to include 'Träning'
    end
  end

  describe '#full_uri' do

    let(:company) { build(:company) }

    it 'url starts with https://' do
      company.website = 'https://example.com'
      expect(helper.full_uri(company)).to eq "https://example.com"
    end

    it 'url starts with http://' do
      company.website = 'http://example.com'
      expect(helper.full_uri(company)).to eq "http://example.com"
    end

    it "url doesn't start with http" do
      company.website = 'example.com'
      expect(helper.full_uri(company)).to eq "http://example.com"
    end

  end


  describe '#location_and_markers_for' do

    it 'empty list of companies' do
      expect(helper.location_and_markers_for([])).to eq([])
    end

    it 'one company (name is linked to the company)' do
      markers = helper.location_and_markers_for([company])
      expect(markers.count).to eq 1
      expect(markers.first[:latitude]).to eq company.addresses[0].latitude
      expect(markers.first[:longitude]).to eq company.addresses[0].longitude
      expect(markers.first[:text]).
        to eq(helper.html_marker_text(company, company.addresses[0]))
      expect(markers.first[:text]).
        to include("#{link_to(company.name, company, target: '_blank')}")
    end

    it 'one company, two addresses' do
      create(:address, addressable: company)
      company.reload
      markers = helper.location_and_markers_for([company])
      expect(markers.count).to eq 2

      expect(markers.first[:latitude]).to eq company.addresses[0].latitude
      expect(markers.first[:longitude]).to eq company.addresses[0].longitude
      expect(markers.first[:text]).
        to eq(helper.html_marker_text(company, company.addresses[0]))
      expect(markers.first[:text]).
        to include("#{link_to(company.name, company, target: '_blank')}")

      expect(markers.second[:latitude]).to eq company.addresses[1].latitude
      expect(markers.second[:longitude]).to eq company.addresses[1].longitude
      expect(markers.second[:text]).
        to eq(helper.html_marker_text(company, company.addresses[1]))
      expect(markers.second[:text]).
        to include("#{link_to(company.name, company, target: '_blank')}")
    end

    it 'just show company name with no link for it' do
      markers = helper.location_and_markers_for([company], link_name: false)
      expect(markers.first[:text]).
        not_to include("#{link_to(company.name, company, target: '_blank')}")
    end

  end


  describe '#html_marker_text' do

    let(:co) { create(:company, company_number: '8776682406')}

    it 'default links name to the company' do
      marker_text = helper.html_marker_text(co, co.addresses[0])
      expect(marker_text).to include( "#{link_to(co.name, co, target: '_blank')}" )
    end


    it 'name text = just the name (no link)' do
      marker_text = helper.html_marker_text(co, co.addresses[0], name_html: co.name)
      expect(marker_text).not_to include( "#{link_to(co.name, co, target: '_blank')}" )
    end

  end

  describe '#address_visibility_array' do
    let(:selection_array) do
      [ [ I18n.t('address_visibility.street_address'), 'street_address' ],
        [ I18n.t('address_visibility.post_code'), 'post_code'],
        [ I18n.t('address_visibility.city'), 'city' ],
        [ I18n.t('address_visibility.kommun'), 'kommun' ],
        [ I18n.t('address_visibility.none'), 'none' ] ]
    end

    after(:each) do
      I18n.locale = I18n.default_locale
    end
    it 'returns swedish selections array' do
      I18n.locale = 'sv'
      expect(selection_array[0][0]).to eq 'Gata'
      expect(address_visibility_array).to match_array selection_array
    end
    it 'returns english selections array' do
      I18n.locale = 'en'
      expect(selection_array[0][0]).to eq 'Street'
      expect(address_visibility_array).to match_array selection_array
    end
  end

  describe '#pay_branding_fee_link' do
    let(:expected_path) do
      payments_path(user_id: user.id, company_id: company.id,
                    type: Payment::PAYMENT_TYPE_BRANDING)
    end

    it 'returns pay-fee link with company and user id' do
      expect(pay_branding_fee_link(company.id, user.id))
        .to match Regexp.new(Regexp.escape(expected_path))
    end
  end

  describe '#company_number_selection_field' do
    4.times do |n|
      let!("cmpy_#{n+1}".to_sym) { create(:company) }
    end

    it 'returns select field for company_number, value == company ID' do
      Company.all.each do |cmpy|
        expect(company_number_selection_field).to match(/option value="#{cmpy.id}"/)
      end
    end

    it 'sets selected value when given an argument' do
      expect(company_number_selection_field(cmpy_3.id))
        .to match(/option selected="selected" value="#{cmpy_3.id}"/)
    end
  end

  describe '#company_number_entry_field' do

    it 'returns entry field with initial value when given an argument' do
      expect(company_number_entry_field('0000000000'))
        .to match(/id="shf_application_company_number" value="0000000000"/)
    end
  end

  describe '#short_h_brand_url' do
    it 'returns value returned by Company#get_short_h_brand_url using generated url' do
      url = company_h_brand_url(company)
      allow(company).to receive(:get_short_h_brand_url).with(url).and_return(url)
      expect(short_h_brand_url(company)).to eq(url)
    end
  end

end
