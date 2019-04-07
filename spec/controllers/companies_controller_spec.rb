require 'rails_helper'
require 'shared_context/companies'

require File.join(Rails.root, 'app/models/concerns/company_hmarkt_url_generator')


RSpec.describe CompaniesController, type: :controller do

  include_context 'create companies'
  include CompanyHMarktUrlGenerator


  let(:no_query_params) { { "utf8" => "✓" } }

  let(:full_page_title) { 'Hitta H-märkt hundföretag, hundinstruktör | Sveriges Hundföretagare' }


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

    let(:region_stockholm) { create(:region, name: 'Stockholm', code: 'AB') }

    let(:stockholm_hundforum) do
      co = create(:company, name: 'Stockholms Hundforum',
                  street_address: 'Celsiusgatan 6',
                  post_code:      '112 30',
                  region:         region_stockholm,
                  city:           'Stockholm')
      co.save # so it is geocoded
      co
    end

    let(:stockholm_hundelska) do
      co = create(:company, name: 'Hundelska',
                  street_address: 'Rehnsgatan 15',
                  post_code:      '113 57',
                  region:         region_stockholm,
                  city:           'Stockholm')
      co.save # so it is geocoded
      co
    end

    let(:arsta_hundenshus) do
      co = create(:company, name: 'Hundens Hus',
                  street_address: 'Svärdlångsvägen 11 C',
                  post_code:      '120 60',
                  region:         region_stockholm,
                  city:           'Årsta')
      co.save # so it is geocoded
      co
    end

    let(:kista_hundkurs) do
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
      member                           = create(:member_with_membership_app)
      member.shf_application.companies = [company]
      create(:payment,
             :successful,
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


    context 'search for locations near coordinates' do

      it "near: {latitude: '59.3251172, longitude: 18.0710935}" do
        member_hundforum.save
        member_hundelska.save
        member_hundenshus.save
        member_hundkurs.save

        near_coords_params = { "utf8" => "✓", near: { latitude:  '59.3251172',
                                                      longitude: '18.0710935' } }

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


    context 'search for locations :near' do

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

      render_views


      it 'page title is from the locale file' do
        get :index
        expect(response.body).to match(full_page_title)
      end


      describe 'meta tags' do

        # Create the Regexp to match meta tag="<tag>" content="<content>"
        def meta_tag_with_content(tag, content)
          Regexp.new("<meta name=\"#{tag}\" content=\"#{content}\">")
        end

        # Create the Regexp to match meta property="<property>" content="<content>"
        def meta_property_with_content(property, content)
          Regexp.new("<meta property=\"#{property}\" content=\"#{content}\">")
        end


        it 'description is from the locale file' do
          # will return 'blorf' when it pretends (mocks) to look up something in a locale file
          allow(I18n.config.backend).to receive(:translate)
                                            .with(anything, anything, anything)
                                            .and_return('blorf')
          get :index
          expect(response.body).to match(meta_tag_with_content('description', 'blorf'))
        end


        describe 'keywords' do

          it 'always has what is in the locale file ' do
            # will return 'blorf' when it pretends (mocks) to look up something in a locale file
            allow(I18n.config.backend).to receive(:translate)
                                              .with(anything, anything, anything)
                                              .and_return('blorf')
            get :index
            expect(response.body).to match(meta_tag_with_content('keywords', 'blorf'))
          end


          describe 'appends the business categories after the locale file keywords' do

            it 'no business categories; is just the I18n keywords' do
              # will return 'blorf' when it pretends (mocks) to look up something in a locale file
              allow(I18n.config.backend).to receive(:translate)
                                                .with(anything, anything, anything)
                                                .and_return('blorf')
              get :index
              expect(response.body).to match(meta_tag_with_content('keywords', 'blorf'))
            end

            it 'some business categories' do
              # will return 'blorf' when it pretends (mocks) to look up something in a locale file
              allow(I18n.config.backend).to receive(:translate)
                                                .with(anything, anything, anything)
                                                .and_return('blorf')
              create(:business_category, name: 'Cat 1')
              create(:business_category, name: 'Cat 2')
              get :index

              meta_content = 'blorf' + ', Cat 1, Cat 2'
              expect(response.body).to match(meta_tag_with_content('keywords', meta_content))
            end
          end
        end


        it 'link rel="image_src" is the banner image in assets/images' do
          get :index

          image_src_match = "<link rel=\"image_src\" href=\"http(.*)/assets/Sveriges_hundforetagare_banner_sajt.jpg\">"
          expect(response.body).to match(image_src_match)
        end


        describe 'link rel="alternate" hreflang' do

          # Create the Regexp to match meta property="<property>" content="<content>"
          def link_hreflang_with_href(hreflang, href)
            Regexp.new("<link rel=\"alternate\" hreflang=\"#{hreflang}\" href=\"#{href}\" />")
          end


          it 'default-x is <request.url> and has no language specifier in the path' do
            get :index

            default_hreflang_match = link_hreflang_with_href('x-default', @controller.request.url).match(response.body)
            expect(default_hreflang_match).not_to be_nil
            expect(default_hreflang_match.size).to eq 1
            expect(default_hreflang_match[0].include?('/sv')).to be_falsey
            expect(default_hreflang_match[0].include?('/en')).to be_falsey
          end

          it 'alt for sv is <base url>/sv/<request.fullpath>' do
            get :index
            expect(response.body).to match(link_hreflang_with_href('sv', "#{@controller.request.base_url}/sv#{request.fullpath}"))
          end

          it 'alt for en is <base url>/en/<request.fullpath>' do
            get :index
            expect(response.body).to match(link_hreflang_with_href('en', "#{@controller.request.base_url}/en#{request.fullpath}"))
          end
        end


        describe 'og (OpenGraph)' do

          it 'title is the complete page title <title | site name>' do
            # <meta property="og:title" content="Hitta H-märkt hundföretag, hundinstruktör | Sveriges Hundföretagare">
            get :index
            expect(response.body).to match(meta_property_with_content('og:title', full_page_title))
          end

          it 'description is the same as the page description' do
            get :index
            expect(response.body).to match(meta_property_with_content('og:description', 'Här hittar du etiska, svenska, H-märkta hundföretag. Du hittar bland annat hundinstruktörer, hundpsykologer, hunddagis, trim med mera.'))
          end

          it 'url is the url of the page' do
            # <meta property="og:url" content="http://0.0.0.0:3000/">
            get :index
            expect(response.body).to match(meta_property_with_content('og:url', request.url))
          end

          it 'type is website' do
            get :index
            expect(response.body).to match(meta_property_with_content('og:type', 'website'))
          end

          it 'locale = sv_SE' do
            get :index
            expect(response.body).to match(meta_property_with_content('og:locale', 'sv_SE'))
          end


          describe 'image' do

            it 'image is the same as the page image_src' do
              # <meta property="og:image" content="http://0.0.0.0:3000/assets/Sveriges_hundforetagare_banner_sajt.jpg">
              get :index
              expect(response.body).to match(meta_property_with_content('og:image', 'http(.*)/assets/Sveriges_hundforetagare_banner_sajt.jpg'))
            end

            it 'type = image/jpeg' do
              # <meta property="og:image:type" content="image/jpeg">
              get :index
              expect(response.body).to match(meta_property_with_content('og:image:type', 'image/jpeg'))
            end

            it 'width is 1245 (the width of the asset banner image)' do
              # <meta property="og:image:width" content="1245">
              get :index
              expect(response.body).to match(meta_property_with_content('og:image:width', '1245'))
            end

            it 'height is 620 (the height of the asset banner image)' do
              # <meta property="og:image:height" content="620">
              get :index
              expect(response.body).to match(meta_property_with_content('og:image:height', '620'))
            end

          end

        end

        describe 'twitter' do

          it '<meta name="twitter:card" content="summary">' do
            get :index
            expect(response.body).to match(meta_tag_with_content('twitter:card', 'summary'))
          end
        end
      end


    end

  end


  describe '#show meta data (renders view)' do

    render_views

    let(:show_co1_params) { { "id" => "#{complete_co1.id}"}  }
    let(:show_co2_params) { { "id" => "#{complete_co2.id}"}  }
    let(:show_co3_params) { { "id" => "#{company_3_addrs.id}"}  }


    it 'page title has the company name and site name' do
      complete_co1
      get :show, params: show_co1_params

      expect(response.body).to match(/<title>#{complete_co1.name} \| Sveriges Hundföretagare<\/title>/)
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
          it 'description is the company description' do
            complete_co1
            get :show, params: show_co1_params
            expect(response.body).to match(meta_tag_with_content('description', complete_co1.description))
          end

        end

        context 'company description is blank' do

          it 'is SHF default page meta description' do
          complete_co2
          complete_co2.update(description: '')
          complete_co2.save

          get :show, params: show_co2_params

          expect(response.body).to match(meta_tag_with_content('description', SiteMetaInfoDefaults.description))

          end
        end

      end


      it 'keywords are only the business categories for the company' do
        meta_content = complete_co1.business_categories.map(&:name).join(', ')
        get :show, params: show_co1_params

        expect(response.body).to match(meta_tag_with_content('keywords', meta_content))
      end


      it 'link rel="image_src" is the H-markt image for the company' do
        co_hmarkt_image_url = company_h_markt_url(complete_co1) # FIXME - this needs to be a permanent image and URL
        get :show, params: show_co1_params

        expect(response.body).to match(co_hmarkt_image_url)
      end


      describe 'link rel="alternate" hreflang' do

        # Create the Regexp to match link rel='alternate' hreflant="<hreflang>" href="<href>"
        def link_hreflang_with_href(hreflang, href)
          Regexp.new("<link rel=\"alternate\" hreflang=\"#{hreflang}\" href=\"#{href}\" />")
        end


        it 'default is "(.)*/hundforetagare/[company id]' do
          complete_co1
          get :show, params: show_co1_params

          expect(response.body).to match(link_hreflang_with_href('x-default', "(.)*/hundforetag/#{complete_co1.id}"))
        end

        it 'alt for sv is (.)*/hunforetagare/[company id]' do
          complete_co1
          get :show, params: show_co1_params

          expect(response.body).to match(link_hreflang_with_href('sv', "(.)*/hundforetag/#{complete_co1.id}"))
        end

        it 'alt for en is (.)*/en/hunforetagare/[company id]' do
          complete_co1
          get :show, params: show_co1_params

          expect(response.body).to match(link_hreflang_with_href('en', "(.)*/en/hundforetag/#{complete_co1.id}"))
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
          get :show, params: show_co1_params

          script_regexp = /<script type=\"application\/ld\+json\">(\s)*(?<company_ld_json>.*)(\s)*<\/script>/
          match = script_regexp.match(response.body)
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
              business_categories.map{|category| "#{I18n.t('dog').capitalize} #{category.name}"} )

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
          get :show, params: show_co3_params

          script_regexp = /<script type=\"application\/ld\+json\">(\s)*(?<company_ld_json>.*)(\s)*<\/script>/
          match = script_regexp.match(response.body)
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
          expect(address_hash['addressLocality']).to eq main_addr.city  #main_addr.kommun.name

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
          3.times do | i |
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
          get :show, params: show_co1_params

          expect(response.body).to match(meta_property_with_content('og:title', "#{complete_co1.name} \| Sveriges Hundföretagare"))
        end


        it 'description is the same as the page description' do
          complete_co1
          get :show, params: show_co1_params

          # get the content in the description tag
          page_desc_regexp = Regexp.new("<meta name=\"description\" content=\"(.*)\">")
          desc_in_response = page_desc_regexp.match(response.body)

          expect(desc_in_response).not_to be_nil  # be super sure that we could find the meta name="description"

          expect(response.body).to match(meta_property_with_content('og:description', desc_in_response[1]))
        end


        it 'url is the url of the page' do
          # <meta property="og:url" content="http://0.0.0.0:3000/">
          complete_co1
          get :show, params: show_co1_params

          expect(response.body).to match(meta_property_with_content('og:url', request.url))
        end

        it 'type is website' do
          complete_co1
          get :show, params: show_co1_params

          expect(response.body).to match(meta_property_with_content('og:type', 'website'))
        end

        it 'locale = sv_SE' do
          complete_co1
          get :show, params: show_co1_params

          expect(response.body).to match(meta_property_with_content('og:locale', 'sv_SE'))
        end


        describe 'image' do

           it 'image is the same as the page image_src' do
             pending("og:image will be done in a separate story/PR")
             fail

          #   co_hmarkt_image_url = company_h_markt_url(complete_co1)  # FIXME - this needs to be a permanent image and URL
          #   get :show, params: show_co1_params
          #
          #   expect(response.body).to match(meta_property_with_content('og:image', co_hmarkt_image_url))
           end

           it 'type = image/png' do
             pending("og:image will be done in a separate story/PR")
             fail

             #   # <meta property="og:image:type" content="image/png">
          #   complete_co1
          #   get :show, params: show_co1_params
          #
          #   expect(response.body).to match(meta_property_with_content('og:image:type', 'image/png'))
           end
          #
           it 'width is 329 (the width of the asset banner image)' do
             pending("og:image will be done in a separate story/PR")
             fail

             #   # <meta property="og:image:width" content="329">
          #   complete_co1
          #   get :show, params: show_co1_params
          #
          #   expect(response.body).to match(meta_property_with_content('og:image:width', '329'))
           end

           it 'height is 424 (the height of the asset banner image)' do
             pending("og:image will be done in a separate story/PR")
             fail

             #   # <meta property="og:image:height" content="424">
          #   complete_co1
          #   get :show, params: show_co1_params
          #
          #   expect(response.body).to match(meta_property_with_content('og:image:height', '424'))
           end

        end

      end


      describe 'twitter' do

        it '<meta name="twitter:card" content="summary">' do
          complete_co1
          get :show, params: show_co1_params

          expect(response.body).to match(meta_tag_with_content('twitter:card', 'summary'))
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
