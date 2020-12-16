require 'rails_helper'
require 'shared_context/companies'

require File.join(Rails.root, 'app/models/concerns/company_hmarkt_url_generator')


RSpec.describe CompaniesController, type: :controller do

  include_context 'create companies'
  include CompanyHMarktUrlGenerator


  let(:no_query_params) { { "utf8" => "✓" } }

  let(:full_page_title) {  'site title | site name' }


  context '#company_h_brand' do
    let(:app_config) { create(:app_configuration) }
    let(:company) { create(:company) }

    it "returns JPG for params[:render_to] == 'jpg' request" do
      get :company_h_brand, params: { id: company.id, render_to: 'jpg' }
      expect(response.content_type).to eq 'image/jpg'
    end

    it "returns JPG for params[:format] == 'jpg' request" do
      get :company_h_brand, params: { id: company.id, format: 'jpg' }
      expect(response.content_type).to eq 'image/jpg'
    end

    it 'returns HTML otherwise' do
      get :company_h_brand, params: { id: company.id }
      expect(response.content_type).to eq 'text/html'
    end
  end

  describe '#index will fix_FB_changed_params' do

    it "does not change URL if there are no query ('q') parameters" do
      #    no_query_params = { "utf8" => "✓" }

      expected_fixed = { "utf8"       => "✓",
                         "controller" => "companies",
                         "action"     => "index"
      }

      get :index, params: no_query_params

      expect(subject.params.to_unsafe_h).to eq expected_fixed

    end

    it 'q parameters that are a Hash are converted to Array with the Hash values' do

      fb_mangled_params = { "utf8" => "✓",
                            "q"    => {
                                "business_categories_id_in" => { "0" => "1", "1" => "2", "2" => "3" }
                            }
      }

      expected_fixed_q = { "business_categories_id_in" => ["1", "2", "3"] }

      get :index, params: fb_mangled_params
      expect(subject.params.to_unsafe_h['q']).to eq expected_fixed_q
    end

    it 'empty values do not need to be retained)' do

      fb_mangled_params = { "utf8"   => "✓",
                            "q"      => {
                                "business_categories_id_in" => { "0" => "1", "1" => "2", "2" => "3" },
                                "addresses_region_id_in"    => { "0" => "6" },
                                "addresses_kommun_id_in"    => { "0" => nil, "1" => "" },
                                "name_in"                   => { "0" => nil } },
                            "commit" => "Sök" }

      expected_fixed_q = { "business_categories_id_in" => ["1", "2", "3"],
                           "addresses_region_id_in"    => ["6"],
                           "addresses_kommun_id_in"    => ["", ""],
                           "name_in"                   => [""] }


      get :index, params: fb_mangled_params

      expect(subject.params.to_unsafe_h['q']).to match expected_fixed_q
    end

  end


  describe '#index' do

    before(:each) do
      # FIXME: Why is this necessary?
      DatabaseCleaner.clean_with(:truncation)
    end

    let!(:region_stockholm) { create(:region, name: 'Stockholm', code: 'AB') }

    let!(:stockholm_hundforum) do
      co = create(:company, name: 'Stockholms Hundforum',
                  street_address: 'Celsiusgatan 6',
                  post_code:      '112 30',
                  region:         region_stockholm,
                  city:           'Stockholm')
      co.save # so it is geocoded
      co
    end

    let!(:stockholm_hundelska) do
      co = create(:company, name: 'Hundelska',
                  street_address: 'Rehnsgatan 15',
                  post_code:      '113 57',
                  region:         region_stockholm,
                  city:           'Stockholm')
      co.save # so it is geocoded
      co
    end

    let!(:arsta_hundenshus) do
      co = create(:company, name: 'Hundens Hus',
                  street_address: 'Svärdlångsvägen 11 C',
                  post_code:      '120 60',
                  region:         region_stockholm,
                  city:           'Årsta')
      co.save # so it is geocoded
      co
    end

    let!(:kista_hundkurs) do
      co = create(:company, name: 'HundKurs',
                  street_address: 'AKALLALÄNKEN 10',
                  region:         region_stockholm,
                  post_code:      '164 74',
                  city:           'Kista')
      co.save # so it is geocoded
      co
    end

    let(:member_hundforum) { create_member_with_co(stockholm_hundforum) }
    let(:member_hundelska) { create_member_with_co(stockholm_hundelska) }
    let(:member_hundenshus) { create_member_with_co(arsta_hundenshus) }
    let(:member_hundkurs) { create_member_with_co(kista_hundkurs) }


    def create_member_with_co(company)
      member = create(:member_with_expiration_date, expiration_date: Date.current + 6.months)
      member.shf_application.companies = [company]
      create(:h_branding_fee_payment,
             user:         member,
             company:      company,
             payment_type: Payment::PAYMENT_TYPE_BRANDING
      )
      member
    end



    it 'params without :near or :within_coords returns all visible companies' do

      member_hundforum.save
      member_hundelska.save
      member_hundenshus.save
      member_hundkurs.save

      get :index, params: no_query_params

      all_visible_cos = @controller.view_assigns['all_visible_companies']
      expect(all_visible_cos.map { |co| co.name }).to match_array(['Stockholms Hundforum',
                                                                   'HundKurs',
                                                                   'Hundelska',
                                                                   'Hundens Hus'])
    end


    # FIXME: what is this really testing?  if the scopes are correct,
    describe 'search for locations near coordinates' do

      it "near: {latitude: '59.3251172, longitude: 18.0710935}" do
        member_hundforum.save
        member_hundelska.save
        member_hundenshus.save
        member_hundkurs.save

        near_coords_params = { "utf8" => "✓", near: { latitude:  '59.3251172',
                                                      longitude: '18.0710935' } }

        expect(@controller).to receive(:get_addresses_near).and_call_original

        get :index, params: near_coords_params

        all_cos = @controller.view_assigns['all_companies']
        expect((all_cos).map(&:name)).to match_array(['Stockholms Hundforum',
                                                      'Hundelska',
                                                      'Hundens Hus'])
      end

      it "near: {latitude: '59.3251172, longitude: 18.0710935, distance: 3}" do
        member_hundforum.save
        member_hundelska.save
        member_hundenshus.save
        member_hundkurs.save

        near_coords_params = { "utf8" => "✓", near: { latitude:  '59.3251172',
                                                      longitude: '18.0710935',
                                                      distance:  3 } }

        get :index, params: near_coords_params

        all_cos = @controller.view_assigns['all_companies']
        expect((all_cos).map(&:name)).to match_array(['Stockholms Hundforum',
                                                      'Hundelska'])
      end


    end


    describe 'search for locations :near' do

      it "near: {name: 'Stockholm'}" do
        member_hundforum.save
        member_hundelska.save
        member_hundenshus.save
        member_hundkurs.save

        near_stockholm_params = { "utf8" => "✓", near: { name: 'Stockholm' } }

        get :index, params: near_stockholm_params

        all_cos = @controller.view_assigns['all_companies']
        expect((all_cos).map(&:name)).to match_array(['Stockholms Hundforum',
                                                      'Hundelska',
                                                      'Hundens Hus'])
      end

      it "near: {name: 'Stockholm', distance: 2}" do
        member_hundforum.save
        member_hundelska.save
        member_hundenshus.save
        member_hundkurs.save

        near_stockholm_params = { "utf8" => "✓", near: { name: 'Stockholm', distance: 3 } }

        get :index, params: near_stockholm_params

        all_cos = @controller.view_assigns['all_companies']
        expect((all_cos).map(&:name)).to match_array(['Stockholms Hundforum',
                                                      'Hundelska'])
      end

    end


    describe 'meta info (renders view)' do

      # This lets us call get :index just once.
      # Must refer to index_response_body as the first line in a test to ensure this has been called at least once
      let(:index_response_body) do
        get :index
        response.body
      end

      render_views

      it 'page title is from the AppConfiguration' do
        expect(AdminOnly::AppConfiguration.config_to_use).to receive(:site_meta_title)
                                                                 .twice
                                                                 .and_call_original

        index_response_body
        expect(response.body).to match(full_page_title)
      end


      describe 'meta tags' do

        RSpec::Matchers.define :not_starting_with do |start_str|
          match { |actual| !((actual.to_s).start_with?(start_str)) }
        end

        RSpec::Matchers.define :starting_with do |start_str|
          match { |actual| ((actual.to_s).start_with?(start_str)) }
        end


        # Create the Regexp to match meta tag="<tag>" content="<content>"
        def meta_tag_with_content(tag, content)
          Regexp.new("<meta name=\"#{tag}\" content=\"#{content}\">")
        end


        # Create the Regexp to match meta property="<property>" content="<content>"
        def meta_property_with_content(property, content)
          Regexp.new("<meta property=\"#{property}\" content=\"#{content}\">")
        end


        it 'description is from the AppConfiguration' do
          index_response_body
          expect(index_response_body).to match(meta_tag_with_content('description', 'site meta description'))
        end


        describe 'keywords' do

          it 'always has the AppConfiguration site_meta_keywords' do

            index_response_body
            expect(index_response_body).to match(meta_tag_with_content('keywords', AdminOnly::AppConfiguration.config_to_use.site_meta_keywords))
          end


          describe 'appends all business categories after the AppConfiguration keywords' do

            it 'no business categories; is just the Appconfiguration keywords' do

              index_response_body
              expect(index_response_body).to match(meta_tag_with_content('keywords', AdminOnly::AppConfiguration.config_to_use.site_meta_keywords))
            end

            it 'all business categories appended' do

              create(:business_category, name: 'Cat 1')
              create(:business_category, name: 'Cat 2')
              index_response_body

              expected_keywords =  AdminOnly::AppConfiguration.config_to_use.site_meta_keywords + ', Cat 1, Cat 2'
              expect(index_response_body).to match(meta_tag_with_content('keywords', expected_keywords))
            end
          end
        end


        it 'link rel="image_src" is the AppConfiguration site meta image' do
          expect(AdminOnly::AppConfiguration.config_to_use).to receive(:site_meta_image).twice.and_call_original

          index_response_body

          image_src_match = /link rel="image_src" href="#{@controller.request.base_url}#{AdminOnly::AppConfiguration.config_to_use.site_meta_image.url}"/
          expect(index_response_body).to match(image_src_match)
        end


        describe 'link rel="alternate" hreflang' do

          # Create the Regexp to match meta property="<property>" content="<content>"
          def link_hreflang_with_href(hreflang, href)
            Regexp.new("<link rel=\"alternate\" hreflang=\"#{hreflang}\" href=\"#{href}\" />")
          end


          it 'default-x is <request.url> and has no language specifier in the path' do
            index_response_body # ensure this is created before we use it; gets around needing to call 'index_response_body' as a before_all

            default_hreflang_match = link_hreflang_with_href('x-default', @controller.request.url).match(index_response_body)
            expect(default_hreflang_match).not_to be_nil
            expect(default_hreflang_match.size).to eq 1
            expect(default_hreflang_match[0].include?('/sv')).to be_falsey
            expect(default_hreflang_match[0].include?('/en')).to be_falsey
          end

          it 'alt for sv is <base url>/sv/<request.fullpath>' do
            index_response_body # ensure this is created before we use it; gets around needing to call 'index_response_body' as a before_all
            expect(index_response_body).to match(link_hreflang_with_href('sv', "#{@controller.request.base_url}/sv#{request.fullpath}"))
          end

          it 'alt for en is <base url>/en/<request.fullpath>' do
            index_response_body # ensure this is created before we use it; gets around needing to call 'index_response_body' as a before_all
            expect(index_response_body).to match(link_hreflang_with_href('en', "#{@controller.request.base_url}/en#{request.fullpath}"))
          end
        end


        describe 'og (OpenGraph)' do

          it 'title is the complete page title <title | site name>' do
            # <meta property="og:title" content="Hitta H-märkt hundföretag, hundinstruktör | Sveriges Hundföretagare">
            index_response_body
            expect(index_response_body).to match(meta_property_with_content('og:title', full_page_title))
          end

          it 'description is from the AppConfiguration' do
            expect(AdminOnly::AppConfiguration.config_to_use).to receive(:site_meta_description).twice.and_call_original

            index_response_body
            expect(index_response_body).to match(meta_property_with_content('og:description', AdminOnly::AppConfiguration.config_to_use.site_meta_description))
          end


          it 'url is the url of the page' do
            # <meta property="og:url" content="http://0.0.0.0:3000/">
            index_response_body
            expect(index_response_body).to match(meta_property_with_content('og:url', request.url))
          end


          it 'type is website and comes from AppConfiguration' do
            expect(AdminOnly::AppConfiguration.config_to_use).to receive(:og_type).and_return('site default type')

            index_response_body
            expect(index_response_body).to match(meta_property_with_content('og:type', 'site default type'))
          end

          it 'locale = sv_SE' do
            index_response_body
            expect(index_response_body).to match(meta_property_with_content('og:locale', 'sv_SE'))
          end


          describe 'image' do

            it 'image is the public url to the AppConfiguration site_meta_image url' do
              expect(AdminOnly::AppConfiguration.config_to_use).to receive(:site_meta_image).twice.and_call_original

              index_response_body
              expect(index_response_body).to match(meta_property_with_content('og:image', "#{@controller.request.base_url}#{AdminOnly::AppConfiguration.config_to_use.site_meta_image.url}"))
            end


            it 'type is from the AppConfiguration site meta image content type' do

              # <meta property="og:image:type" content="image/jpeg">
              index_response_body
              expect(index_response_body).to match(meta_property_with_content('og:image:type', AdminOnly::AppConfiguration.config_to_use.site_meta_image_content_type))
            end

            it 'width is from the AppConfiguration site meta image width' do

              # <meta property="og:image:width" content="1245">
              index_response_body
              expect(index_response_body).to match(meta_property_with_content('og:image:width', AdminOnly::AppConfiguration.config_to_use.site_meta_image_width))
            end

            it 'height is the site meta image height' do
              # <meta property="og:image:height" content="620">
              index_response_body
              expect(index_response_body).to match(meta_property_with_content('og:image:height', AdminOnly::AppConfiguration.config_to_use.site_meta_image_height))
            end

          end

        end


        it 'twitter:card is from AppConfiguration' do
          expect(AdminOnly::AppConfiguration.config_to_use).to receive(:twitter_card_type).twice.and_call_original
          index_response_body
          expect(index_response_body).to match(meta_tag_with_content('twitter:card', AdminOnly::AppConfiguration.config_to_use.twitter_card_type))
        end

      end

    end

  end


  describe '#show meta data (renders view)' do

    let(:co_html_in_desc) { create(:company, description: "<h1>HundCo</h1>   <p>The best <b>HundCo</b> \n there is!  </p>\n\n &nbsp;  \n") }
    let(:clean_desc_co_html_in_desc) { "HundCo The best HundCo there is!" }

    let(:show_co1_params) { { "id" => "#{complete_co1.id}" } }
    let(:show_co2_params) { { "id" => "#{complete_co2.id}" } }
    let(:show_co3_params) { { "id" => "#{company_3_addrs.id}" } }

    # This lets us call get :show with the company 1 parameters just once.
    # Must refer to show_co1_response_body as the first line in a test to ensure this has been called at least once
    let(:show_co1_response_body) do
      get :show, params: show_co1_params
      response.body
    end

    # This lets us call get :show with the company 1 parameters just once.
    # Must refer to show_co1_response_body as the first line in a test to ensure this has been called at least once
    let(:show_co2_response_body) do
      get :show, params: show_co2_params
      response.body
    end

    # This lets us call get :show with the company 1 parameters just once.
    # Must refer to show_co1_response_body as the first line in a test to ensure this has been called at least once
    let(:show_co3_response_body) do
      get :show, params: show_co3_params
      response.body
    end


    render_views


    it 'page title has the company name and site name' do
      complete_co1
      show_co1_response_body
      expect(show_co1_response_body).to match(/<title>#{complete_co1.name} \| #{AdminOnly::AppConfiguration.config_to_use.site_name}<\/title>/)
    end


    describe 'meta information' do

      # Create the Regexp to match meta tag="<tag>" content="<content>"
      def meta_tag_with_content(tag, content)
        Regexp.new("<meta name=\"#{tag}\" content=\"#{content}\">")
      end


      # Create the Regexp to match meta property="<property>" content="<content>"
      def meta_property_with_content(property, content)
        Regexp.new("<meta property=\"#{property}\" content=\"#{content}\">")
      end


      describe 'description' do

        context 'company has a description' do

          it 'description is the company description with HTML removed and blanks squished' do
            get :show, params: { "id" => "#{co_html_in_desc.id}" }
            expect(response.body).to match(meta_tag_with_content('description', clean_desc_co_html_in_desc))
          end

        end

        context 'company description is blank' do

          it 'is AppConfiguration meta description' do
            complete_co2
            complete_co2.update(description: '')
            complete_co2.save

            show_co2_response_body

            expect(show_co2_response_body).to match(meta_tag_with_content('description', AdminOnly::AppConfiguration.config_to_use.site_meta_description))

          end
        end

      end


      it 'keywords are only the business categories for the company' do

        expect(AdminOnly::AppConfiguration.config_to_use).to receive(:site_meta_keywords).once

        meta_content = complete_co1.business_categories.map(&:name).join(', ')
        show_co1_response_body

        expect(show_co1_response_body).to match(meta_tag_with_content('keywords', meta_content))
      end


      it 'link rel="image_src" is the H-markt image for the company' do
        co_hmarkt_image_url = company_h_markt_url(complete_co1) # FIXME - this needs to be a permanent image and URL
        show_co1_response_body

        expect(show_co1_response_body).to match(co_hmarkt_image_url)
      end


      describe 'link rel="alternate" hreflang' do

        # Create the Regexp to match link rel='alternate' hreflant="<hreflang>" href="<href>"
        def link_hreflang_with_href(hreflang, href)
          Regexp.new("<link rel=\"alternate\" hreflang=\"#{hreflang}\" href=\"#{href}\" />")
        end


        it 'default is "(.)*/hundforetagare/[company id]' do
          complete_co1
          show_co1_response_body

          expect(show_co1_response_body).to match(link_hreflang_with_href('x-default', "(.)*/hundforetag/#{complete_co1.id}"))
        end

        it 'alt for sv is (.)*/hunforetagare/[company id]' do
          complete_co1
          show_co1_response_body

          expect(show_co1_response_body).to match(link_hreflang_with_href('sv', "(.)*/hundforetag/#{complete_co1.id}"))
        end

        it 'alt for en is (.)*/en/hunforetagare/[company id]' do
          complete_co1
          show_co1_response_body

          expect(show_co1_response_body).to match(link_hreflang_with_href('en', "(.)*/en/hundforetag/#{complete_co1.id}"))
        end
      end


      describe 'schema.org info' do

        # This is an example of the schema.org information for a Company in ld+json form:
        #   (I've formatted it with newlines and indents for readability.)
        #
        # <script type="application/ld+json">
        # {
        #   "@context":"http://schema.org",
        #   "@type":"LocalBusiness",
        #   "@id":"https://hitta.sverigeshundforetagre/hundforetag/1",
        #   "name":"Complete Company 1",
        #   "description":"This co has a 2 branding payments",
        #   "url":"https://hitta.sverigeshundforetagre/hundforetag/1",
        #   "email":"thiscompany@example.com",
        #   "telephone":"123123123",
        #   "image":"https://hitta.sverigeshundforetagare.se/hundforetag/1/company_h_brand",
        #   "address":{
        #     "@type":"PostalAddress",
        #     "streetAddress":"Hundforetagarevägen 1",
        #     "postalCode":"310 40",
        #     "addressRegion":"MyString",
        #     "addressLocality":"Harplinge",
        #     "addressCountry":"Sverige"
        #   },
        #   "geo":{
        #     "@type":"GeoCoordinates",
        #     "latitude":56.7422437,
        #     "longitude":12.7206453
        #   },
        #   "knowsLanguage":"sv-SE"
        #   "knowsAbout"=>
        #     ["Hund Business Category 3",
        #     "Hund Business Category 2",
        #     "Hund Business Category 1"]
        #   }
        # }
        # </script>

        it 'is in ld+json format in a <script> tag' do
          complete_co1
          show_co1_response_body

          script_regexp = /<script type=\"application\/ld\+json\">(\s)*(?<company_ld_json>.*)(\s)*<\/script>/
          match         = script_regexp.match(show_co1_response_body)
          expect(match.captures.size).to eq 1

          # turn the matched string into a Hash so we can compare info no matter the order
          co_ld_json = JSON.parse(match.named_captures['company_ld_json'])

          shf_company_url = /#{@controller.request.base_url}\/hundforetag\/#{complete_co1.id}/

          expect(co_ld_json.key?('@context')).to be_truthy
          expect(co_ld_json['@context']).to eq 'http://schema.org'

          expect(co_ld_json.key?('@type')).to be_truthy
          expect(co_ld_json['@type']).to eq 'LocalBusiness'

          expect(co_ld_json.key?('@id')).to be_truthy
          expect(co_ld_json['@id']).to match(shf_company_url)

          expect(co_ld_json.key?('name')).to be_truthy
          expect(co_ld_json['name']).to eq complete_co1.name

          expect(co_ld_json.key?('description')).to be_truthy
          expect(co_ld_json['description']).to eq complete_co1.description

          expect(co_ld_json.key?('url')).to be_truthy
          expect(co_ld_json['url']).to match(shf_company_url)

          expect(co_ld_json.key?('email')).to be_truthy
          expect(co_ld_json['email']).to eq complete_co1.email

          expect(co_ld_json.key?('telephone')).to be_truthy
          expect(co_ld_json['telephone']).to eq complete_co1.phone_number

          expect(co_ld_json.key?('knowsLanguage')).to be_truthy
          expect(co_ld_json['knowsLanguage']).to eq 'sv-SE'

          # prepend each category with I18n.t('dog') so that the search engines can respond
          # when someone searches on "dog <whatever>"
          expect(co_ld_json.key?('knowsAbout')).to be_truthy
          expect(co_ld_json['knowsAbout']).to match_array(complete_co1.
              business_categories.map { |category| "#{I18n.t('dog').capitalize} #{category.name}" })

          expect(co_ld_json.key?('address')).to be_truthy
          expect(co_ld_json['address']).to be_a Hash

          address_hash = co_ld_json['address']
          expect(address_hash.key?('@type')).to be_truthy
          expect(address_hash['@type']).to eq 'PostalAddress'

          expect(address_hash.key?('streetAddress')).to be_truthy
          expect(address_hash['streetAddress']).to eq 'Hundforetagarevägen 1'

          expect(address_hash.key?('postalCode')).to be_truthy
          expect(address_hash['postalCode']).to eq '310 40'

          expect(address_hash.key?('addressRegion')).to be_truthy
          expect(address_hash['addressRegion']).to eq 'MyString'

          expect(address_hash.key?('addressLocality')).to be_truthy
          expect(address_hash['addressLocality']).to eq 'Harplinge'

          expect(address_hash.key?('addressCountry')).to be_truthy
          expect(address_hash['addressCountry']).to eq 'Sverige'

          expect(co_ld_json.key?('geo')).to be_truthy
          expect(co_ld_json['geo']).to be_a Hash

          geo_hash = co_ld_json['geo']
          expect(geo_hash.key?('@type')).to be_truthy
          expect(geo_hash['@type']).to eq 'GeoCoordinates'

          expect(geo_hash.key?('longitude')).to be_truthy
          expect(geo_hash['latitude']).to eq 56.7422437
          expect(geo_hash.key?('longitude')).to be_truthy
          expect(geo_hash['longitude']).to eq 12.7206453


          expect(co_ld_json.key?('image')).to be_truthy
          #    expect(co_ld_json['image']).to eq 'permanent url with a permanent image so search engines can find and display it'

        end


        it 'company with 3 addresses: uses main address for address, lists all 3 addresses as locations' do

          company_3_addrs
          show_co3_response_body

          script_regexp = /<script type=\"application\/ld\+json\">(\s)*(?<company_ld_json>.*)(\s)*<\/script>/
          match         = script_regexp.match(response.body)
          expect(match.captures.size).to eq 1

          # turn the matched string into a Hash so we can compare info no matter the order
          co_ld_json = JSON.parse(match.named_captures['company_ld_json'])

          expect(co_ld_json.key?('name')).to be_truthy
          expect(co_ld_json['name']).to eq company_3_addrs.name

          expect(co_ld_json.key?('address')).to be_truthy
          expect(co_ld_json['address']).to be_a Hash

          address_hash = co_ld_json['address']
          expect(address_hash.key?('@type')).to be_truthy
          expect(address_hash['@type']).to eq 'PostalAddress'

          main_addr = company_3_addrs.main_address

          expect(address_hash.key?('streetAddress')).to be_truthy
          expect(address_hash['streetAddress']).to eq main_addr.street_address

          expect(address_hash.key?('postalCode')).to be_truthy
          expect(address_hash['postalCode']).to eq main_addr.post_code

          expect(address_hash.key?('addressRegion')).to be_truthy
          expect(address_hash['addressRegion']).to eq main_addr.region.name

          expect(address_hash.key?('addressLocality')).to be_truthy
          expect(address_hash['addressLocality']).to eq main_addr.city #main_addr.kommun.name

          expect(address_hash.key?('addressCountry')).to be_truthy
          expect(address_hash['addressCountry']).to eq main_addr.country

          expect(co_ld_json.key?('geo')).to be_truthy
          expect(co_ld_json['geo']).to be_a Hash

          geo_hash = co_ld_json['geo']
          expect(geo_hash.key?('@type')).to be_truthy
          expect(geo_hash['@type']).to eq 'GeoCoordinates'

          expect(geo_hash.key?('longitude')).to be_truthy
          expect(geo_hash['latitude']).to eq main_addr.latitude
          expect(geo_hash.key?('longitude')).to be_truthy
          expect(geo_hash['longitude']).to eq main_addr.longitude

          location = co_ld_json['location']
          expect(location).to be_a Array
          expect(location.size).to eq 3

          # expect 3 places, all with addresses and geo information
          3.times do |i|
            expect(location[i]['@type']).to eq 'Place'

            expect(location[i].key?('address')).to be_truthy
            expect(location[i]['address']['@type']).to eq 'PostalAddress'

            expect(location[i].key?('geo')).to be_truthy
            expect(location[i]['geo']['@type']).to eq 'GeoCoordinates'
          end

        end


        it 'schema.org info for a company with multiple images' do
          pending("images will be done in a separate story/PR")
          fail
        end

      end


      describe 'og (OpenGraph)' do

        it 'title is same as the page title' do
          # <meta property="og:title" content="Hitta H-märkt hundföretag, hundinstruktör | Sveriges Hundföretagare">
          complete_co1
          show_co1_response_body

          expect(response.body).to match(meta_property_with_content('og:title', "#{complete_co1.name} \| Sveriges Hundföretagare"))
        end


        it 'description == Company desc with HTML and linefeeds removed' do
          get :show, params: { "id" => "#{co_html_in_desc.id}" }
          expect(response.body).to match(meta_property_with_content('og:description', clean_desc_co_html_in_desc))
        end


        it 'url is the url of the page' do
          # <meta property="og:url" content="http://0.0.0.0:3000/">
          complete_co1
          show_co1_response_body

          expect(response.body).to match(meta_property_with_content('og:url', request.url))
        end

        it 'type is from AppConfiguration' do
          expect(AdminOnly::AppConfiguration.config_to_use).to receive(:og_type).twice.and_call_original
          complete_co1
          show_co1_response_body

          expect(response.body).to match(meta_property_with_content('og:type', AdminOnly::AppConfiguration.config_to_use.og_type))
        end

        it 'locale = sv_SE' do
          complete_co1
          show_co1_response_body

          expect(response.body).to match(meta_property_with_content('og:locale', 'sv_SE'))
        end


        describe 'image' do

          # TODO: What is the definition of the 'main image for the company'? What image do we use?

          describe 'if there is no image for the company, use the site meta image' do
            pending
          end


          it 'image is the same as the page image_src' do
            pending("og:image will be done in a separate story/PR")
            fail

            #   co_hmarkt_image_url = company_h_markt_url(complete_co1)  # FIXME - this needs to be a permanent image and URL
            #   show_co1_response_body
            #
            #   expect(response.body).to match(meta_property_with_content('og:image', co_hmarkt_image_url))
          end

          it 'type = image/png' do
            pending("og:image will be done in a separate story/PR")
            fail

            #   # <meta property="og:image:type" content="image/png">
            #   complete_co1
            #   show_co1_response_body
            #
            #   expect(response.body).to match(meta_property_with_content('og:image:type', 'image/png'))
          end
          #
          it 'width is the width of the asset banner image)' do
            pending("og:image will be done in a separate story/PR")
            fail

            #   # <meta property="og:image:width" content="329">
            #   complete_co1
            #   show_co1_response_body
            #
            #   expect(response.body).to match(meta_property_with_content('og:image:width', '329'))
          end

          it 'height is the height of the asset banner image)' do
            pending("og:image will be done in a separate story/PR")
            fail

            #   # <meta property="og:image:height" content="424">
            #   complete_co1
            #   show_co1_response_body
            #
            #   expect(response.body).to match(meta_property_with_content('og:image:height', '424'))
          end

        end

      end


      describe 'twitter:card is summary and comes the AppConfiguration' do

        it 'comes from appConfiguration' do
          expect(AdminOnly::AppConfiguration.config_to_use).to receive(:twitter_card_type).twice.and_call_original

          complete_co1
          show_co1_response_body
          expect(show_co1_response_body).to match(meta_tag_with_content('twitter:card', AdminOnly::AppConfiguration.config_to_use.twitter_card_type))
        end
      end

    end

  end


  describe 'ignore sort by business category' do

    let(:no_q_params) { no_query_params.merge({ 'controller' => 'companies', 'action' => 'index' }) }

    it "does not change the params if there is no query ('q') parameter" do

      get :index, params: no_query_params
      expect(subject.params.to_unsafe_h).to eq no_q_params
    end


    it "does not change the params if there is no sort ('s') parameter" do

      business_cat_in = no_q_params.merge({ 'q' => { 'business_categories_id_in' => ["1"] } })
      get :index, params: business_cat_in

      expect(subject.params.to_unsafe_h).to eq business_cat_in
    end


    describe 'removes the sort param no matter the sort direction' do

      empty_query_request = { "utf8"       => "✓",
                              'controller' => 'companies', 'action' => 'index',
                              'q'          => {} }

      sort_by_business_cats_no_dir = { desc: 'no direction', request: empty_query_request.merge({ 'q' => { 's' => 'business_categories_name' } }) }
      sort_by_business_cats_asc    = { desc: 'asc', request: empty_query_request.merge({ 'q' => { 's' => 'business_categories_name asc' } }) }
      sort_by_business_cats_desc   = { desc: 'desc', request: empty_query_request.merge({ 'q' => { 's' => 'business_categories_name desc' } }) }
      sort_by_business_cats_blorf  = { desc: 'nonsense direction', request: empty_query_request.merge({ 'q' => { 's' => 'business_categories_name blorf' } }) }

      sort_dirs = [sort_by_business_cats_no_dir, sort_by_business_cats_asc,
                   sort_by_business_cats_desc, sort_by_business_cats_blorf
      ]

      sort_dirs.each do |sort_direction_request|

        it "removes the sort param with #{sort_direction_request[:desc]}" do
          get :index, params: sort_direction_request[:request]
          expect(subject.params.to_unsafe_h).to eq empty_query_request
        end
      end

    end # describe 'removes the sort param no matter the sort direction'


    it 'will not throw an error if a sort by business categories request is made' do
      bad_request = { "utf8"       => "✓",
                      'controller' => 'companies', 'action' => 'index',
                      'q'          => { 's' => 'business_categories_name asc' } }

      expect { get :index, params: bad_request }.not_to raise_error
    end

  end # describe 'ignore sort by business category'


end
