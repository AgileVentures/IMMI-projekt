require 'rails_helper'

RSpec.describe CompaniesHelper, type: :helper do
  let!(:company) { create(:company) }

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

    before(:all) do
      expect(Company.count).to eq(0)
      expect(MembershipApplication.count).to eq(0)
      expect(User.count).to eq(0)
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
      co = build(:company)
      markers = helper.location_and_markers_for([co])
      expect(markers.count).to eq 1
      expect(markers.first[:latitude]).to eq co.main_address.latitude
      expect(markers.first[:longitude]).to eq co.main_address.longitude
      expect(markers.first[:text]).to eq(helper.html_marker_text(co))
      expect(markers.first[:text]).to include("#{link_to(co.name, co,target: '_blank')}")
    end

    it 'just show company name with no link for it' do
      co = build(:company)
      markers = helper.location_and_markers_for([co], link_name: false)
      expect(markers.first[:text]).not_to include("#{link_to(co.name, co,target: '_blank')}")
    end

  end


  describe '#html_marker_text' do

    let(:co) { create(:company, company_number: '8776682406')}

    it 'default links name to the company' do
      marker_text = helper.html_marker_text(co)
      expect(marker_text).to include( "#{link_to(co.name, co, target: '_blank')}" )
    end


    it 'name text = just the name (no link)' do
      marker_text = helper.html_marker_text(co, name_html: co.name)
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

  describe '#show_address_fields' do
    let(:admin)   { create(:user, admin: true) }
    let(:member)  { create(:member_with_membership_app) }
    let(:visitor) { build(:visitor) }
    let(:company) { create(:company, num_addresses: 0) }
    let(:address) { create(:address, addressable: company) }

    let(:all_fields) do
      [ { name: 'street_address', label: 'street', method: nil },
        { name: 'post_code', label: 'post_code', method: nil },
        { name: 'city', label: 'city', method: nil },
        { name: 'kommun', label: 'kommun', method: 'name' },
        { name: 'region', label: 'region', method: 'name' } ]
    end

    it 'returns all fields for admin user' do
      # The helper method returns two values, so these will be in an array
      expect(show_address_fields(admin, nil)).to match_array [ all_fields, true ]
    end

    it 'returns all fields for member associated with company' do
      company = member.membership_applications[0].company
      expect(show_address_fields(member, company.addresses.first))
        .to match_array [ all_fields, true ]
    end

    it 'for visitor, returns fields consistent with address visibility' do

      (0..Address::ADDRESS_VISIBILITY.length-1).each do |idx|

        address.visibility = Address::ADDRESS_VISIBILITY[idx]
        address.save!

        fields, visibility = show_address_fields(visitor, address)

        expect(visibility).to be false

        case address.visibility
        when 'none'
          expect(fields).to be nil
        else
          expect(fields).to match_array all_fields[idx, 5]
        end
      end
    end
  end

end
