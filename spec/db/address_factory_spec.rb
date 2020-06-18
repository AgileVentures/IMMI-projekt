require 'rails_helper'

require_relative File.join(Rails.root, 'db/seed_helpers/address_factory')


ENV_SEED_FAKE_CSV_FNAME_KEY = 'SHF_SEED_FAKE_ADDR_CSV_FILE' unless defined?(ENV_SEED_FAKE_CSV_FNAME_KEY)


RSpec.describe SeedHelper::AddressFactory do

  SEED_DB_DIR = File.join(Rails.root, 'db') unless defined?(SEED_DB_DIR)
  EMPTY_CSV_FILENAME = 'fake-addresses-empty.csv' unless defined?(EMPTY_CSV_FILENAME)

  # CSV file content for 10 fake addresses with geocoding
  AF_FAKE_ADDRESSES              = "street_address,post_code,city,country,region_name,kommun_name,latitude,longitude,visibility,mail\n" +
      '"Engelbrektsgatan 80","06875","Strömstad","Sverige","Online","Nässjö",57.6530377,14.6981554,street_address,false' + "\n" +
      '"Skaraborgsgatan 9b","08247","Laholm","Sverige","Gävleborg","Ockelbo",60.9197006,16.5426709711809,street_address,false' + "\n" +
      '"Surtsögatan 9a","64 898","Solna","Sverige","Sverige","Norsjö",64.93630935,19.4762167086367,street_address,false' + "\n" +
      '"Huvudfabriksgatan 4a","56 407","Nyköping","Sverige","Värmland","Flen",59.0567823,16.5893,street_address,false' + "\n" unless defined?(AF_FAKE_ADDRESSES)

  AF_FAKE_ADDRESSES_CSV_FILENAME = "fake-addresses-4-#{Time.now.to_i}.csv" unless defined?(AF_FAKE_ADDRESSES_CSV_FILENAME)


  before(:all) do
    create_empty_file(SEED_DB_DIR, EMPTY_CSV_FILENAME)
    create_csv_file(SEED_DB_DIR, AF_FAKE_ADDRESSES_CSV_FILENAME, AF_FAKE_ADDRESSES)
  end

  after(:all) do
    # remove the CSV files created
    remove_file(SEED_DB_DIR, EMPTY_CSV_FILENAME)
    remove_file(SEED_DB_DIR, AF_FAKE_ADDRESSES_CSV_FILENAME)
  end


  let(:address_factory) do

    create(:region, name: 'Online')
    create(:region, name: 'Sverige')
    create(:region, name: 'Stockholm')
    create(:region, name: 'Gävleborg')
    create(:region, name: 'Värmland')

    create(:kommun, name: 'Stockholm')
    create(:kommun, name: 'Ale')
    create(:kommun, name: 'Nässjö')
    create(:kommun, name: 'Ockelbo')
    create(:kommun, name: 'Norsjö')
    create(:kommun, name: 'Flen')

    SeedHelper::AddressFactory.new(Region.all, Kommun.all)

  end


  describe 'fake_addresses_csv_filename' do

    context 'ENV[ENV_SEED_FAKE_CSV_FNAME_KEY] is not defined' do

      it 'uses the DEFAULT csv filename with the db directory prepended' do
        orig_env_csv_fn = ENV.fetch(ENV_SEED_FAKE_CSV_FNAME_KEY, nil)

        RSpec::Mocks.with_temporary_scope do
          env = ENV.to_hash
          env.delete(ENV_SEED_FAKE_CSV_FNAME_KEY)
          stub_const('ENV', env)

          expect(address_factory.fake_addresses_csv_filename).to eq File.join(Rails.root, 'db', described_class::DEFAULT_FAKE_ADDR_FILENAME)
        end

        ENV[ENV_SEED_FAKE_CSV_FNAME_KEY] = orig_env_csv_fn unless orig_env_csv_fn.nil?
      end
    end

    context 'ENV[ENV_SEED_FAKE_CSV_FNAME_KEY] is defined' do

      it 'gets the CSV filename from the ENV value and adds the db directory' do
        RSpec::Mocks.with_temporary_scope do
          stub_const('ENV', ENV.to_hash.merge({ ENV_SEED_FAKE_CSV_FNAME_KEY => 'fake_addresses.csv' }))
          allow_any_instance_of(SeedHelper::AddressFactory).to receive(:tell).and_return(false)

          expect(address_factory.fake_addresses_csv_filename).to eq File.join(Rails.root, 'db', 'fake_addresses.csv')
        end
      end
    end
  end


  describe 'already_constructed_addresses' do

    it 'reads addresses from the CSV file' do

      RSpec::Mocks.with_temporary_scope do
        stub_const('ENV', ENV.to_hash.merge({ ENV_SEED_FAKE_CSV_FNAME_KEY => AF_FAKE_ADDRESSES_CSV_FILENAME }))
        allow_any_instance_of(SeedHelper::AddressFactory).to receive(:tell).and_return(false)

        expect(address_factory.already_constructed_addresses.size).to eq 4
        classes_read = address_factory.already_constructed_addresses.map(&:class).uniq
        expect(classes_read.size).to eq 1
        expect(classes_read.first).to eq Address

      end # RSpec::Mocks

    end


    it 'if the CSV file is empty, already_constructed_addresses = [] (empty array)' do
      RSpec::Mocks.with_temporary_scope do
        stub_const('ENV', ENV.to_hash.merge({ ENV_SEED_FAKE_CSV_FNAME_KEY => EMPTY_CSV_FILENAME }))

        address_factory.already_constructed_addresses

        expect(address_factory.already_constructed_addresses).to eq []
      end # RSpec::Mocks
    end

  end


  describe 'make_n_save_a_new_address(addressable_entity)' do

    let(:company) {  Company.new(company_number: '6225354437',
                                           email:          'fake_co@example.com',
                                           name:           'SomeCompany',
                                           phone_number:   '123123123',
                                           website:        'http://www.example.com')
    }

    context 'no already constructed addresses' do

      it 'if there are no already constructed addresses, an Address is created and geocoded' do
        allow(address_factory).to receive(:already_constructed_addresses).and_return([])
        allow_any_instance_of(SeedHelper::AddressFactory).to receive(:tell).and_return(false)

        expect(address_factory).to receive(:create_a_new_address).and_call_original
        expect(Geocoder).to receive(:search).at_least(1).times

        address_factory.make_n_save_a_new_address(company)
      end

    end # context 'no already constructed addresses'


    context 'there are constructed addresses' do

      it 'uses an already constructed address; none created, none geocoded' do
        RSpec::Mocks.with_temporary_scope do
          stub_const('ENV', ENV.to_hash.merge({ ENV_SEED_FAKE_CSV_FNAME_KEY => AF_FAKE_ADDRESSES_CSV_FILENAME }))

          expect(Geocoder).to receive(:search).never
          expect(address_factory).to receive(:create_a_new_address).never

          #address_factory.already_constructed_addresses

          address_factory.make_n_save_a_new_address(company)
        end
      end


      it 'removes the address from the list of already constructed addresses' do
        RSpec::Mocks.with_temporary_scope do
          stub_const('ENV', ENV.to_hash.merge({ ENV_SEED_FAKE_CSV_FNAME_KEY => AF_FAKE_ADDRESSES_CSV_FILENAME }))

          expect(address_factory.already_constructed_addresses.size).to eq 4

          address_factory.make_n_save_a_new_address(company)
          expect(address_factory.already_constructed_addresses.size).to eq 3

        end
      end

    end # context 'there are constructed addresses'

  end

  #----------------------------------------------------------------------------

  # Create an empty file in the given directory if it doesn't already exist
  #
  # @param fullpath [String] - the full path where the file should be created
  # @param filename [String] - the filename to create
  # @return [String] - the absolute pathname of the file
  def create_empty_file(fullpath, filename)
    fullname = File.join(fullpath, filename)
    File.new(fullname, 'w') unless File.exist?(fullname)
    File.absolute_path(fullname)
  end


  # Create a file with the given content. Ensure it doesn't already exist
  #
  # @param fullpath [String] - the full path where the file should be created
  # @param filename [String] - the filename to create
  # @return [String] - the absolute pathname of the file
  def create_csv_file(fullpath, filename, file_contents)
    fullname = File.join(fullpath, filename)

    raise IOError("#{fullname} already exists. It needs to be created but cannot.") if File.exist?(fullname)
    File.open(fullname, 'w') do |csv_file|
      csv_file.puts file_contents
    end
    File.absolute_path(fullname)
  end


  def remove_file(dir, filename)
    fullname = File.join(dir, filename)
    File.delete(fullname) if File.exist?(fullname)
  end


end
