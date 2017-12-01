require 'rails_helper'

RSpec.describe CompaniesHelper, type: :helper do
  let!(:company) { create(:company) }
  let(:user) { create(:user) }

  describe 'companies' do
    let(:employee1) { create(:user) }
    let(:employee2) { create(:user) }
    let(:employee3) { create(:user) }

    let!(:ma1) do
      ma = create(:membership_application, :accepted,
                  user: employee1,
                  company_number: company.company_number)
      ma.business_categories << create(:business_category, name: 'cat1')
      ma
    end
    let!(:ma2) do
      ma = create(:membership_application, :accepted,
                  user: employee2,
                  company_number: company.company_number)
      ma.business_categories << create(:business_category, name: 'cat2')
      ma
    end
    let!(:ma3) do
      ma = create(:membership_application, :accepted,
                  user: employee3,
                  company_number: company.company_number)
      ma.business_categories << create(:business_category, name: 'cat3')
      ma
    end

    it '#list_categories' do
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
end
