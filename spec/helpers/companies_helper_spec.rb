require 'rails_helper'

RSpec.describe CompaniesHelper, type: :helper do
  let(:company) { create(:company) }
  let(:user) { create(:user) }

  describe 'companies' do

    it '#list_categories' do
      employee1 = create(:user, member: true)
      ma1 = create(:shf_application, :accepted, user: employee1, category_name: 'cat1')

      # not a member
      ma2 = create(:shf_application, :accepted, user: create(:user, member: false), category_name: 'cat2')
      ma2.companies = ma1.companies

      ma3 = create(:shf_application, :accepted, user: create(:user, member: true), category_name: 'cat3')
      ma3.companies = ma1.companies

      cat1 = BusinessCategory.find_by(name: 'cat1')

      cat1.children.create(name: 'cat1_subcat1')
      cat1.children.create(name: 'cat1_subcat2')
      cat1.children.create(name: 'cat1_subcat3')

      company = ma1.companies.first

      expect(helper.list_categories(company, ' ', true)).to eq 'cat1 cat1_subcat1 cat1_subcat2 cat1_subcat3 cat3'
      expect(helper.list_categories(company, ' ', false)).to eq 'cat1 cat3'
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

  describe 'html_postal_format_entire_address' do
    let(:co) do
      co = build(:company, num_addresses: 1,
                 region: build(:region),
                 company_number: '000000000')
      co.addresses.first.mail = true
      co
    end

    it 'gets the lines to use from postal_format_entire_address' do
      expect(helper).to receive(:postal_format_entire_address)
                            .with(co, person_name: 'Some name')
                            .and_call_original
      helper.html_postal_format_entire_address(co, person_name: 'Some name')
    end
  end


  describe 'postal_format_entire_address' do

    let(:co) do
      co = build(:company, num_addresses: 1,
                 region: build(:region),
                 company_number: '000000000')
      co.addresses.first.mail = true
      co
    end

    let(:result) { helper.postal_format_entire_address(co) }
    let(:result_with_person_name) { helper.postal_format_entire_address(co, person_name: 'Person Name Is Here') }

    # Use the first address found that has been set as the mailing address
    before(:each) do
      allow(co).to receive(:main_address)
                       .and_return(co.addresses.find{|addr| addr.mail })
    end

    it 'uses the main_address' do
      expect(co).to receive(:main_address)
      helper.postal_format_entire_address(co)
    end

    it 'always includes the entire address, no matter the address visibility level' do
      address = co.addresses.first
      address.visibility = Address.no_visibility
      formatted_address = helper.postal_format_entire_address(co)
      formatted_address_lines = formatted_address.split("\n")
      expect(formatted_address_lines.select{|line| line.blank?}).to be_empty
    end

    it 'first is the company name' do
      expect(result.first).to eq('SomeCompany')
      expect(result_with_person_name.first).to eq('SomeCompany')
    end

    context 'person name is given' do
      it '2nd line is person name' do
        expect(result_with_person_name[1]).to eq('Person Name Is Here')
      end
    end

    context 'no person name given' do
      it 'no person name after the company name' do
        expect(result[1]).not_to eq('Person Name Is Here')
      end
    end

    it '"street address" is next to last line' do
      expect(result[result.size - 2]).to eq('Hundforetagarevägen 1')
      expect(result_with_person_name[result_with_person_name.size - 2]).to eq('Hundforetagarevägen 1')
    end

    it '"postcode city" is last line' do
      expect(result.last).to eq('310 40 Harplinge')
      expect(result_with_person_name.last).to eq('310 40 Harplinge')
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

  describe '#company_h_brand_jpg_url' do
    it 'returns company h-brand url with ".jpg" appended' do
      expect(company_h_brand_jpg_url(company)).to eq company_h_brand_url(company) + '.jpg'
    end
  end

  describe '#short_h_brand_url' do
    it 'calls #company_h_brand_jpg_url and returns value returned by #get_short_h_brand_url' do
      url = company_h_brand_jpg_url(company)
      allow(company).to receive(:get_short_h_brand_url).with(url).and_return(url)
      expect(short_h_brand_url(company)).to eq(url)
    end
  end

end
