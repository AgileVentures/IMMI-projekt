require 'rails_helper'

require_relative 'address_shared_examples'


RSpec.describe Address, type: :model do

  let(:new_region) { create(:region, name: 'New Region') }
  let(:new_kommun) { create(:kommun, name: 'New Kommun') }

  let(:co_has_region) { create(:company, name: 'Has Region', company_number: '4268582063', city: 'HasRegionBorg') }
  let(:co_missing_region) { create(:company, name: 'Missing Region', company_number: '6112107039', city: 'NoRegionBorg') }

  let(:addr_has_region) { co_has_region.main_address }

  let(:no_region) do
    addr_no_region = co_missing_region.main_address
    addr_no_region.update_columns(region_id: nil)
    addr_no_region
  end

  let(:not_visible_addr) do
    create(:address, visibility: 'none', addressable: co_has_region)
  end

  let(:visible_addr) do
    create(:address, visibility: 'city', addressable: co_has_region)
  end

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:company_address)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :street_address }
    it { is_expected.to have_db_column :post_code }
    it { is_expected.to have_db_column :city }
    it { is_expected.to have_db_column :region_id }
    it { is_expected.to have_db_column :addressable_id }
    it { is_expected.to have_db_column :addressable_type }
    it { is_expected.to have_db_column :latitude }
    it { is_expected.to have_db_column :longitude }
    it { is_expected.to have_db_column :visibility }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :country }
    it { is_expected.to validate_presence_of :addressable }
    it { is_expected.to validate_inclusion_of(:visibility)
                            .in_array(described_class.address_visibility_levels) }

    it 'validates only one mailing address' do
      visible_addr.mail = true
      expect(visible_addr).to be_valid

      visible_addr.save!
      not_visible_addr.mail = true
      not_visible_addr.valid?
      expect(not_visible_addr).to_not be_valid
      expect(not_visible_addr.errors.full_messages).to include('Post används redan')
    end

    describe 'after_validation calls geocode_best_possible' do

      let(:a_company) { create(:company, num_addresses: 0) }

      let(:norbotten_region) { create(:region, name: 'Norrbotten') }
      let(:overtornea_kommun) { create(:kommun, name: 'Övertorneå') }

      let(:address_no_lat_long) do
        create(:address,
               street_address: 'Matarengivägen 24',
               post_code: '957 31',
               city: 'Övertorneå',
               kommun: overtornea_kommun,
               region: norbotten_region,
               addressable: a_company,
               mail: false)
      end

      let(:address_with_lat_long) do
        addr = create(:address,
                      street_address: 'Matarengivägen 24',
                      post_code: '957 31',
                      city: 'Övertorneå',
                      kommun: overtornea_kommun,
                      region: norbotten_region,
                      addressable: a_company,
                      mail: false)
        addr.latitude = 59.3251172
        addr.longitude = 18.0710935
        addr
      end


      context 'latitude or longitude are nil' do

        # this geocodes only in PRODUCTION so that
        # we can create addresses from a CSV file without geocoding them
        it 'a new address will always geocode (in PRODUCTION only)' do

          RSpec::Mocks.with_temporary_scope do
            allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

            new_address = build(:address,
                                street_address: 'Matarengivägen 24',
                                post_code: '957 31',
                                city: 'Övertorneå',
                                kommun: overtornea_kommun,
                                region: norbotten_region,
                                addressable: a_company,
                                mail: false)

            expect(new_address).to receive(:geocode_best_possible).and_call_original.exactly(1).times
            expect(Geocoder).to receive(:search).and_call_original.at_least(1).times
            new_address.validate
          end
        end

        context 'is not new ' do

          it 'does not geocode if nothing has changed' do
            saved_addr = address_no_lat_long

            expect(saved_addr).to receive(:geocode_best_possible).never
            expect(Geocoder).to receive(:search).and_call_original.never
            saved_addr.validate
          end

          it_behaves_like 'it does not geocode when validated after changing', 'nothing' do
            let(:address) { address_no_lat_long }
          end


          context 'something has changed' do

            context 'geocodes for changed GEO location info' do

              it_behaves_like 'it geocodes when validated after changing', 'street_address (long = nil)' do
                let(:address) do
                  addr = address_no_lat_long

                  addr.longitude = nil
                  addr.street_address = 'new street'
                  addr
                end
              end

              it_behaves_like 'it geocodes when validated after changing', 'post_code (long = nil)' do
                let(:address) do
                  addr = address_no_lat_long

                  addr.longitude = nil
                  addr.post_code = '999 99'
                  addr
                end
              end

              it_behaves_like 'it geocodes when validated after changing', 'city (long = nil)' do
                let(:address) do
                  addr = address_no_lat_long

                  addr.longitude = nil
                  addr.city = 'Newburg'
                  addr
                end
              end

              it_behaves_like 'it geocodes when validated after changing', 'kommun (lat = nil)' do
                let(:address) do
                  addr = address_no_lat_long

                  addr.latitude = nil
                  addr.kommun = new_kommun
                  addr
                end
              end

              it_behaves_like 'it geocodes when validated after changing', 'region (lat = nil)' do
                let(:address) do
                  addr = address_no_lat_long

                  addr.latitude = nil
                  addr.region = new_region
                  addr
                end
              end

              it_behaves_like 'it geocodes when validated after changing', 'country (lat = nil)' do
                let(:address) do
                  addr = address_no_lat_long

                  addr.latitude = nil
                  addr.country = 'Blorflund'
                  addr
                end
              end

            end #  context 'geocodes for changed GEO location info'


            context 'does not geocode if non-GEO location attribute is changed' do

              it_behaves_like 'it does not geocode when validated after changing', 'mail' do
                let(:address) do
                  addr = address_no_lat_long
                  addr.mail = 'new email'
                  addr
                end
              end

            end #context 'does not geocode if non-GEO location attribute is changed'

          end #  context 'something has changed'
        end # context 'is not new '

      end #  'latitude or longitude are nil'


      context 'latitude and longitude are not nil' do

        # this geocodes only in PRODUCTION so that
        # we can create addresses from a CSV file without geocoding them
        it 'a new address will always geocode (in PRODUCTION only)' do

          RSpec::Mocks.with_temporary_scope do
            allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

            new_address = build(:address,
                                street_address: 'Matarengivägen 24',
                                post_code: '957 31',
                                city: 'Övertorneå',
                                kommun: overtornea_kommun,
                                region: norbotten_region,
                                addressable: a_company,
                                mail: false)

            new_address.latitude = 59.3251172
            new_address.longitude = 18.0710935

            expect(new_address).to receive(:geocode_best_possible).and_call_original.exactly(1).times
            expect(Geocoder).to receive(:search).and_call_original.at_least(1).times
            new_address.validate
          end
        end

        context 'is not new' do

          it_behaves_like 'it does not geocode when validated after changing', 'nothing' do
            let(:address) do
              addr = address_with_lat_long
              addr.latitude = 59.3251172
              addr.longitude = 18.0710935
              addr.save
              addr
            end
          end


          context 'something has changed' do

            context 'geocodes for changed GEO location info' do

              it_behaves_like 'it geocodes when validated after changing', 'street_address' do
                let(:address) do
                  addr = address_with_lat_long
                  addr.street_address = 'new street'
                  addr
                end
              end

              it_behaves_like 'it geocodes when validated after changing', 'post_code' do
                let(:address) do
                  addr = address_with_lat_long
                  addr.post_code = '999 99'
                  addr
                end
              end

              it_behaves_like 'it geocodes when validated after changing', 'city' do
                let(:address) do
                  addr = address_with_lat_long
                  addr.city = 'Newburg'
                  addr
                end
              end

              it_behaves_like 'it geocodes when validated after changing', 'kommun' do
                let(:address) do
                  addr = address_with_lat_long
                  addr.kommun = new_kommun
                  addr
                end
              end

              it_behaves_like 'it geocodes when validated after changing', 'region' do
                let(:address) do
                  addr = address_with_lat_long
                  addr.region = new_region
                  addr
                end
              end

              it_behaves_like 'it geocodes when validated after changing', 'country' do
                let(:address) do
                  addr = address_with_lat_long
                  addr.country = 'Blorflund'
                  addr
                end
              end

            end

            context 'does not geocode if non-GEO location attribute is changed' do

              it_behaves_like 'it does not geocode when validated after changing', 'mail' do
                let(:address) do
                  addr = address_with_lat_long
                  addr.mail = 'new email'
                  addr
                end
              end

            end #context 'does not geocode if non-GEO location attribute is changed'

          end # context 'something has changed'
        end # context 'is not new'

      end # context 'latitude and longitude are not nil'

    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:region).optional }
    it { is_expected.to belong_to(:kommun).optional }
    it { is_expected.to belong_to(:addressable) }
  end

  describe 'Calls #format_city_name before save' do
    let(:address) { build(:address, addressable: build(:company)) }

    it 'removes unneeded white space' do
      address.city = '   lots  of   white   space   '
      address.save
      expect(address.city).to eq 'Lots Of White Space'
    end

    it 'converts city to Title Case' do
      address.city = 'trollhättan'
      address.save
      expect(address.city).to eq 'Trollhättan'

      address.city = 'ÄLMHULT'
      address.save
      expect(address.city).to eq 'Älmhult'

      address.city = 'saltsjö-boo'
      address.save
      expect(address.city).to eq 'Saltsjö-Boo'
    end

  end


  describe 'scopes' do
    let!(:has_regions) { [addr_has_region] }
    let!(:lacking_regions) { [no_region] }

    describe 'visible' do
      it 'only returns addresses that are visible' do
        expect(co_has_region.addresses.visible).
            to contain_exactly(addr_has_region, visible_addr)
      end
    end

    describe 'has_region' do

      it 'only returns addresses that have a region' do
        has_region_scope = described_class.has_region

        expect(has_region_scope).to match_array(has_regions), "expected #{has_regions.pretty_inspect} },\n\n but got #{has_region_scope.pretty_inspect} }"
      end

      it 'does not return any addresses that do not have a region' do
        has_region_scope = described_class.has_region
        expect(has_region_scope & lacking_regions).to match_array([])
      end

    end


    describe 'lacking_region' do

      it 'only returns addresses that do not have a region' do
        lacking_region_scope = described_class.lacking_region
        expect(lacking_region_scope).to match_array(lacking_regions)
      end

      it 'does not return any addresses that do have a region' do
        lacking_region_scope = described_class.lacking_region
        expect(lacking_region_scope & has_regions).to match_array([])
      end

    end

    describe 'mail_address' do
      it 'returns mail address if present' do
        mail_addr = create(:address, mail: true, addressable: co_has_region)
        expect(co_has_region.addresses.mail_address[0]).to eq mail_addr
      end
      it 'returns nil if mail address not present' do
        create(:address, addressable: co_has_region)
        expect(co_has_region.addresses.mail_address[0]).to be_nil
      end
    end

    describe '.company_address' do

      it 'addresses that belong to a company' do
        expect(described_class.company_address.count).to eq 2
      end

    end

  end


  describe '#entire_address ' do

    let(:addr) { build(:address) }
    it 'calls address_array to get the array of address elements' do
      expect(addr).to receive(:address_array).and_call_original
      addr.entire_address
    end

    it 'joins the address array elements with ", "' do
      allow(addr).to receive(:address_array)
                         .and_return(['one', 'two', 'three'])
      expect(addr.entire_address).to eq 'one, two, three'
    end

    it 'returns all data if full_visibility: true' do
      addr.visibility = described_class.no_visibility
      expect(addr).to receive(:address_array)
                          .with(described_class.max_visibility)
                          .and_return(['would be all address elements'])
      addr.entire_address(full_visibility: true)
    end

    it 'returns empty string if visibility == none' do
      addr.visibility = described_class.no_visibility
      expect(addr.entire_address).to be_empty
    end
  end


  describe 'geocoding' do

    let(:expected_streetaddress) { 'Kvarnliden 10' }
    let(:expected_postcode) { '310 40' }
    let(:expected_kommun) { create(:kommun, name: 'Halland') }
    let(:expected_city) { 'Harplinge' }
    let(:expected_country) { 'Sverige' }

    # orig lat and long, which is wrong and should be updated if the address changes
    let(:orig_lat) { 56.7439545 }
    let(:orig_long) { 12.7276875 }


    def addr_details(addr, expected_msg)
      "#{expected_msg}; addr: #{addr.entire_address}, lat: #{addr.latitude}, long: #{addr.longitude}"
    end


    it 'Geocoder is configured to raise all errors in test environment' do
      expect(Geocoder.config[:always_raise]).to eq(:all)
    end


    context 'geocode from address' do
      let(:addr) do
        addr = build(:address,
                     street_address: expected_streetaddress,
                     post_code: expected_postcode,
                     city: expected_city,
                     kommun: expected_kommun,
                     country: 'Sweden')
        addr.addressable = create(:company, num_addresses: 0)
        addr.save
        addr
      end

      it 'geocodes company address' do

        expect(addr.latitude.round(2)).to eq(56.7440.round(2)),
                                          addr_details(addr, "expected lat to be 56.744, but wasn't")
        expect(addr.longitude.round(2)).to eq(12.7276.round(2)),
                                           addr_details(addr, "expected long to be 12.728, but wasn't")
      end

      it 'changed street address' do
        addr.street_address = 'Kvarnliden 2'
        addr.validate

        expect(addr.latitude).not_to eq(orig_lat)
        expect(addr.longitude).not_to eq(orig_long)

        expect(addr.latitude.round(2)).to eq(56.7442343.round(2)),
                                          addr_details(addr, "expected lat to be 56.744, but wasn't")
        expect(addr.longitude.round(2)).to eq(12.7255982.round(2)),
                                           addr_details(addr, "expected long to be 12.726, but wasn't")
      end

      it 'changed kommun' do
        addr.kommun = create(:kommun, name: 'Halmstad Ö')
        addr.validate

        expect(addr.latitude).not_to eq(orig_lat)
        expect(addr.longitude).not_to eq(orig_long)

        expect(addr.latitude.round(2)).to eq(56.7440333.round(2)),
                                          addr_details(addr, "expected lat to be 56.744, but wasn't")
        expect(addr.longitude.round(2)).to eq(12.727637.round(2)),
                                           addr_details(addr, "expected long to be 12.728, but wasn't")
      end

      it 'changed city' do
        addr.city = 'Plingshult'
        addr.street_address = ''
        addr.post_code = ''
        addr.validate

        expect(addr.latitude).not_to eq(orig_lat)
        expect(addr.longitude).not_to eq(orig_long)

        expect(addr.latitude.round(2)).to eq(56.607677.round(2)),
                                          addr_details(addr, "expected lat to be 56.607, but wasn't")
        expect(addr.longitude.round(2)).to eq(13.251166.round(2)),
                                           addr_details(addr, "expected long to be 13.25, but wasn't")
      end

      it 'changed region' do
        new_region = create(:region, name: 'New Region', code: 'NR')
        addr.region = new_region
        addr.validate

        expect(addr.latitude).not_to eq(orig_lat)
        expect(addr.longitude).not_to eq(orig_long)

        expect(addr.latitude.round(2)).to eq(56.7440333.round(2)),
                                          addr_details(addr, "expected lat to be 56.744, but wasn't")
        expect(addr.longitude.round(2)).to eq(12.727637.round(2)),
                                           addr_details(addr, "expected long to be 12.728, but wasn't")
      end

      it 'changed country' do
        addr.country = 'Norway'
        addr.validate

        expect(addr.latitude).not_to eq(orig_lat)
        expect(addr.longitude).not_to eq(orig_long)

        expect(addr.latitude.round(2)).to eq(56.7440333.round(2)),
                                          addr_details(addr, "expected lat to be 56.744, but wasn't")
        expect(addr.longitude.round(2)).to eq(12.727637.round(2)),
                                           addr_details(addr, "expected long to be 12.728, but wasn't")
      end

      it 'if all info is nil, will at least return lat/long of Sweden' do

        addr.assign_attributes(street_address: nil, city: nil,
                               post_code: nil, kommun: nil, country: nil)

        addr.validate

        expect(addr.latitude.round(2)).to eq(60.12816100000001.round(2)),
                                          addr_details(addr, "expected lat to be 60.128, but wasn't")
        expect(addr.longitude.round(2)).to eq(18.643501.round(2)),
                                           addr_details(addr, "expected long to be 18.644, but wasn't")
      end
    end # context 'geocode from address'

    describe '#geocode_best_possible' do
      let(:address) do
        addr = build(:address,
                     street_address: 'Matarengivägen 24',
                     post_code: '957 31',
                     city: 'Övertorneå',
                     kommun: create(:kommun, name: 'Norrbotten'))
        addr.addressable = create(:company, num_addresses: 0)
        addr.save
        addr
      end

      it 'all valid address components' do
        expect(address.latitude.round(2)).to eq(66.3902539.round(2)),
                                             addr_details(address, "expected lat to be 66.390, but wasn't")
        expect(address.longitude.round(2)).to eq(23.6601303.round(2)),
                                              addr_details(address, "expected long to be 23.660, but wasn't")
      end

      it 'invalid street_address' do
        address.street_address = 'blorf'
        address.validate

        expect(address.latitude.round(2)).to eq(66.3887731.round(2)),
                                             addr_details(address, "expected lat to be 66.389, but wasn't")
        expect(address.longitude.round(2)).to eq(23.6734973.round(2)),
                                              addr_details(address, "expected long to be 23.673, but wasn't")
      end

      it 'invalid post_code, street_address' do
        address.assign_attributes(street_address: 'blorf', post_code: 'x')
        address.validate

        expect(address.latitude.round(2)).to eq(66.3884436.round(2)),
                                             addr_details(address, "expected lat to be 66.388, but wasn't")
        expect(address.longitude.round(2)).to eq(23.639283.round(2)),
                                              addr_details(address, "expected long to be 23.639, but wasn't")
      end

      it 'invalid city, post_code, street_address' do
        address.assign_attributes(street_address: 'blorf', post_code: 'x',
                                  city: 'y')
        address.validate

        expect(address.latitude.round(2)).to eq(66.8309.round(2)),
                                             addr_details(address, "expected lat to be 66.8309, but wasn't")
        expect(address.longitude.round(2)).to eq(20.39919.round(2)),
                                              addr_details(address, "expected long to be 20.39919, but wasn't")
      end

      it 'invalid city, post_code, street_address, kommun' do
        address.assign_attributes(street_address: 'blorf',
                                  post_code: 'x', city: 'y',
                                  kommun: create(:kommun, name: 'nonesuch'))
        address.validate

        expect(address.latitude.round(2)).to eq(60.12816100000001.round(2)),
                                             addr_details(address, "expected lat to be 60.128, but wasn't")
        expect(address.longitude.round(2)).to eq(18.643501.round(2)),
                                              addr_details(address, "expected long to be 18.644, but wasn't")
      end

      it 'no address info should = Sverige' do
        address.assign_attributes(street_address: nil, city: nil,
                                  post_code: nil, kommun: nil, country: nil)
        address.validate

        expect(address.latitude.round(2)).to eq(60.128161.round(2)),
                                             addr_details(address, "expected lat to be 60.128, but wasn't")
        expect(address.longitude.round(2)).to eq(18.643501.round(2)),
                                              addr_details(address, "expected long to be 18.643, but wasn't")
      end
    end #  describe '#geocode_best_possible'


    describe '#geocode_all_needed(sleep_between: 0.5, num_per_batch: 50)' do

      it 'nothing geocoded if all have latitude and longitude' do

        a_company = create(:company, num_addresses: 0)
        norbotten_region = create(:region, name: 'Norrbotten')
        overtornea_kommun = create(:kommun, name: 'Övertorneå')

        # These are real addresses in  Övertorneå Municipality in Norrbotten County:
        valid_address1 = build(:address,
                               street_address: 'Matarengivägen 24',
                               post_code: '957 31',
                               city: 'Övertorneå',
                               kommun: overtornea_kommun,
                               region: norbotten_region,
                               addressable: a_company,
                               mail: false)
        valid_address1.save

        valid_address2 = create(:address,
                                street_address: 'Skolvägen 12',
                                post_code: '957 31',
                                city: 'Övertorneå',
                                kommun: overtornea_kommun,
                                region: norbotten_region,
                                addressable: a_company)
        valid_address2.save


        need_geocoding = described_class.not_geocoded
        needed_geocoding = need_geocoding.count

        described_class.geocode_all_needed

        after_run_need_geocoding = described_class.not_geocoded.count

        expect(needed_geocoding).to eq 0
        expect(after_run_need_geocoding).to eq 0
      end

      it_behaves_like 'needs geocoding with sql UPDATE of', 'latitude=NULL'
      it_behaves_like 'needs geocoding with sql UPDATE of', 'longitude=NULL'
      it_behaves_like 'needs geocoding with sql UPDATE of', 'latitude=NULL, longitude=NULL'

      it_behaves_like 'does not need geocoding with sql UPDATE of', "street_address='new street'"
      it_behaves_like 'does not need geocoding with sql UPDATE of', "post_code='999 99'"
      it_behaves_like 'does not need geocoding with sql UPDATE of', "city='new city'"
      it_behaves_like 'does not need geocoding with sql UPDATE of', "country='new country'"

    end # describe 'geocode_all_needed(sleep_between: 0.5, num_per_batch: 50)


    describe 'do not geocode if development or testing and we have lat and long for new or unchanged' do

      let(:a_company) { create(:company, num_addresses: 0) }

      let(:norbotten_region) { create(:region, name: 'Norrbotten') }
      let(:overtornea_kommun) { create(:kommun, name: 'Övertorneå') }

      envs = %w(test development)

      envs.each do |rails_env|

        before(:all) do

          RSpec::Mocks.with_temporary_scope do
            allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("#{rails_env}"))
          end
        end

        context "Rails.env == #{rails_env}" do

          context 'has lat and long' do

            it 'a new address should NOT geocode' do
              new_address = build(:address,
                                  street_address: 'Matarengivägen 30',
                                  post_code: '957 31',
                                  city: 'Övertorneå',
                                  kommun: overtornea_kommun,
                                  region: norbotten_region,
                                  addressable: a_company)

              expect(Geocoder).to receive(:search).at_least(1).times
              new_address.save
            end

            context 'is not a new record' do

              let(:valid_saved_addr) do
                addr2 = create(:address,
                               street_address: 'Skolvägen 12',
                               post_code: '957 31',
                               city: 'Övertorneå',
                               kommun: overtornea_kommun,
                               region: norbotten_region,
                               addressable: a_company)
                addr2.save
                addr2
              end

              context 'should geocode if an geo attribute was changed' do

                it_behaves_like 'it geocodes when validated after changing', 'street_address' do
                  let(:address) do
                    addr = valid_saved_addr
                    addr.street_address = 'new street'
                    addr
                  end
                end

                it_behaves_like 'it geocodes when validated after changing', 'post_code' do
                  let(:address) do
                    addr = valid_saved_addr
                    addr.post_code = '999 99'
                    addr
                  end
                end

                it_behaves_like 'it geocodes when validated after changing', 'city' do
                  let(:address) do
                    addr = valid_saved_addr
                    addr.city = 'new city'
                    addr
                  end
                end

                it_behaves_like 'it geocodes when validated after changing', 'kommun' do
                  let(:address) do
                    addr = valid_saved_addr
                    addr.kommun = new_kommun
                    addr
                  end
                end

                it_behaves_like 'it geocodes when validated after changing', 'region' do
                  let(:address) do
                    addr = valid_saved_addr
                    addr.region = new_region
                    addr
                  end
                end

                it_behaves_like 'it geocodes when validated after changing', 'country' do
                  let(:address) do
                    addr = valid_saved_addr
                    addr.country = 'new country'
                    addr
                  end
                end

              end # context 'should geocode if an geo attribute was changed'

              context 'should not if an geo attribute was not changed' do

                it_behaves_like 'it does not geocode when validated after changing', 'mail' do
                  let(:address) do
                    addr = valid_saved_addr
                    addr.mail = 'new email'
                    addr
                  end
                end

                it 'should not gecode for a change in mail' do
                  valid_saved_addr.mail = 'hello@example.com'
                  expect(Geocoder).to receive(:search).never
                  valid_saved_addr.validate
                end

              end # context 'should not if an geo attribute was not changed'

            end #  context 'is not a new record'

          end #  context 'has lat and long'


          context 'does not have lat and long: always geocodes' do

            context 'is a new record' do
              it 'geocodes' do
                new_address = build(:address,
                                    street_address: 'Matarengivägen 30',
                                    post_code: '957 31',
                                    city: 'Övertorneå',
                                    kommun: overtornea_kommun,
                                    region: norbotten_region,
                                    addressable: a_company)
                new_address.latitude = nil

                expect(Geocoder).to receive(:search).at_least(1).times
                new_address.save
              end
            end # context 'is a new record'

            context 'is not a new record' do

              let(:addr_no_longitude) do
                addr = create(:address,
                              street_address: 'Skolvägen 12',
                              post_code: '957 31',
                              city: 'Övertorneå',
                              kommun: overtornea_kommun,
                              region: norbotten_region,
                              addressable: a_company)
                addr.save
                addr.longitude = nil
                addr
              end

              context 'geocodes if geo attribute was changed' do

                it 'street address' do
                  addr_no_longitude.longitude = nil
                  addr_no_longitude.street_address = 'new street'
                  expect(Geocoder).to receive(:search).at_least(1).times
                  addr_no_longitude.validate
                end

                it 'post code' do
                  addr_no_longitude.longitude = nil
                  addr_no_longitude.post_code = '999 99'
                  expect(Geocoder).to receive(:search).at_least(1).times
                  addr_no_longitude.validate
                end

                it 'city' do
                  addr_no_longitude.longitude = nil
                  addr_no_longitude.city = 'new city'
                  expect(Geocoder).to receive(:search).at_least(1).times
                  addr_no_longitude.validate
                end

                it 'kommun' do
                  addr_no_longitude.longitude = nil
                  addr_no_longitude.kommun = create(:kommun, name: 'New Kommun')
                  expect(Geocoder).to receive(:search).at_least(1).times
                  addr_no_longitude.validate
                end

                it 'region' do
                  addr_no_longitude.longitude = nil
                  addr_no_longitude.region = create(:region, name: 'New Region')
                  expect(Geocoder).to receive(:search).at_least(1).times
                  addr_no_longitude.validate
                end

                it 'country' do
                  addr_no_longitude.longitude = nil
                  addr_no_longitude.country = 'new country'
                  expect(Geocoder).to receive(:search).at_least(1).times
                  addr_no_longitude.validate
                end
              end

              context 'geocodes event if a non-geo attribute was changed', focus: true do

                it 'mail' do
                  addr_no_longitude.longitude = nil
                  expect(addr_no_longitude.longitude).to be_nil

                  addr_no_longitude.mail = 'hello@example.com'
                  expect(Geocoder).to receive(:search).at_least(1).times

                  addr_no_longitude.validate
                end
              end

            end # context 'is not a new record'

          end # context 'does not have lat and long: always geocodes'


          context 'has lat and long' do

            it 'a new address always geocodes' do
              new_address = build(:address,
                                  street_address: 'Matarengivägen 30',
                                  post_code: '957 31',
                                  city: 'Övertorneå',
                                  kommun: overtornea_kommun,
                                  region: norbotten_region,
                                  addressable: a_company)

              expect(Geocoder).to receive(:search).at_least(1).times
              new_address.save
            end

            context 'is not a new record' do

              let(:valid_saved_addr) do
                addr2 = create(:address,
                               street_address: 'Skolvägen 12',
                               post_code: '957 31',
                               city: 'Övertorneå',
                               kommun: overtornea_kommun,
                               region: norbotten_region,
                               addressable: a_company)
                addr2.save
                addr2
              end

              context 'geocodes if geo attribute was changed' do

                it 'street address' do
                  valid_saved_addr.street_address = 'new street'
                  expect(Geocoder).to receive(:search).at_least(1).times
                  valid_saved_addr.validate
                end

                it 'post code' do
                  valid_saved_addr.post_code = '999 99'
                  expect(Geocoder).to receive(:search).at_least(1).times
                  valid_saved_addr.validate
                end

                it 'city' do
                  valid_saved_addr.city = 'new city'
                  expect(Geocoder).to receive(:search).at_least(1).times
                  valid_saved_addr.validate
                end

                it 'kommun' do
                  valid_saved_addr.kommun = create(:kommun, name: 'New Kommun')
                  expect(Geocoder).to receive(:search).at_least(1).times
                  valid_saved_addr.validate
                end

                it 'region' do
                  valid_saved_addr.region = create(:region, name: 'New Region')
                  expect(Geocoder).to receive(:search).at_least(1).times
                  valid_saved_addr.validate
                end

                it 'country' do
                  valid_saved_addr.country = 'new country'
                  expect(Geocoder).to receive(:search).at_least(1).times
                  valid_saved_addr.validate
                end
              end

              context 'geo attribute was not changed' do

                it 'does not gecode for a change in mail' do
                  valid_saved_addr.mail = 'hello@example.com'
                  expect(Geocoder).to receive(:search).never
                  valid_saved_addr.validate
                end
              end

            end # context 'is not a new record'

          end #  context 'has lat and long'

        end # context "Rails.env == development"


      end # envs.each

      context 'Rails.env == production' do

        context 'is a new record' do
          it 'geocodes' do
            RSpec::Mocks.with_temporary_scope do
              allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

              new_address = build(:address,
                                  street_address: 'Matarengivägen 30',
                                  post_code: '957 31',
                                  city: 'Övertorneå',
                                  kommun: overtornea_kommun,
                                  region: norbotten_region,
                                  addressable: a_company)

              expect(Rails.env).to eq 'production'
              expect(Geocoder).to receive(:search).at_least(1).times
              new_address.save
            end
          end
        end

        context 'is not a new record' do

          let(:valid_saved_addr) do
            addr2 = create(:address,
                           street_address: 'Skolvägen 12',
                           post_code: '957 31',
                           city: 'Övertorneå',
                           kommun: overtornea_kommun,
                           region: norbotten_region,
                           addressable: a_company)
            addr2.save
            addr2
          end

          context 'geo attribute was changed' do

            it 'geocodes if street address changed: geocodes' do
              RSpec::Mocks.with_temporary_scope do
                allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

                valid_saved_addr.street_address = 'new street'
                expect(Geocoder).to receive(:search).at_least(1).times
                valid_saved_addr.validate
              end
            end

            it 'post code changed: geocodes' do
              RSpec::Mocks.with_temporary_scope do
                allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

                valid_saved_addr.post_code = '999 99'
                expect(Geocoder).to receive(:search).at_least(1).times
                valid_saved_addr.validate
              end
            end

            it 'city changed: geocodes' do
              RSpec::Mocks.with_temporary_scope do
                allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

                valid_saved_addr.city = 'new city'
                expect(Geocoder).to receive(:search).at_least(1).times
                valid_saved_addr.validate
              end
            end

            it 'kommun changed: geocodes' do
              RSpec::Mocks.with_temporary_scope do
                allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

                valid_saved_addr.kommun = create(:kommun, name: 'New Kommun')
                expect(Geocoder).to receive(:search).at_least(1).times
                valid_saved_addr.validate
              end
            end

            it 'region changed: geocodes' do
              RSpec::Mocks.with_temporary_scope do
                allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

                valid_saved_addr.region = create(:region, name: 'New Region')
                expect(Geocoder).to receive(:search).at_least(1).times
                valid_saved_addr.validate
              end
            end

            it 'country changed: geocodes' do
              RSpec::Mocks.with_temporary_scope do
                allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

                valid_saved_addr.country = 'new country'
                expect(Geocoder).to receive(:search).at_least(1).times
                valid_saved_addr.validate
              end
            end
          end

          context 'geo attribute was not changed' do

            it 'should not gecode for a change in mail' do
              RSpec::Mocks.with_temporary_scope do
                allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

                valid_saved_addr.mail = 'hello@example.com'
                expect(Geocoder).to receive(:search).never
                valid_saved_addr.validate
              end
            end
          end

        end # context 'is not a new record'

      end # context 'Rails.env == production'
    end # 'do not geocode if development or testing and we have lat and long for new or unchanged'

  end # describe 'geocoding'


  context '#address_array' do

    let(:address) { build(:address) }

    let(:address_pattern) do
      [address.street_address, address.post_code,
       address.city, address.kommun.name, 'Sverige']
    end


    describe 'uses the visibility level of the address' do

      # length of the list of all address visibility items/settings
      viz_items_len = described_class.address_visibility_levels.size

      # go thru all possible address visibility items (settings)
      (0..described_class.address_visibility_levels.length - 1).each do |visibility_level|
        viz_level = described_class.address_visibility_levels[visibility_level]

        it "#{viz_level}" do
          address.visibility = viz_level
          address_fields = address.address_array

          case address.visibility
            when 'none'
              expect(address_fields).to be_empty
            else
              # address_pattern[ start_index, length]
              expect(address_fields).to match_array address_pattern[visibility_level, viz_items_len]
          end
        end

      end

      describe 'specify the visibility level to use' do
        # go thru all possible address visibility items (settings)
        (0..described_class.address_visibility_levels.length - 1).each do |visibility_level|

          viz_level = described_class.address_visibility_levels[visibility_level]

          it "#{viz_level}" do
            address.visibility = described_class.max_visibility
            address_fields = address.address_array(viz_level)

            case viz_level
              when described_class.no_visibility
                expect(address_fields).to be_empty
              else
                # address_pattern[ start_index, length]
                expect(address_fields).to match_array address_pattern[visibility_level, viz_items_len]
            end
          end
        end
      end

    end

  end


  def confirm_full_address_str(addr_str, addr)
    kommun = Kommun.find(addr.kommun_id)
    expect(addr_str.include?(addr.street_address)).to be_truthy
    expect(addr_str.include?(addr.post_code)).to be_truthy
    expect(addr_str.include?(addr.city)).to be_truthy
    expect(addr_str.include?(kommun.name)).to be_truthy
    expect(addr_str.include?(addr.country)).to be_truthy
  end

end
