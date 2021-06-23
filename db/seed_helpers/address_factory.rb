require 'smarter_csv'

require_relative('../seed_helpers.rb')
require_relative '../require_all_seeders_and_helpers'

require_relative File.join(Rails.root, 'lib/fake_addresses/csv_fake_addresses_reader')

module SeedHelpers

  #--------------------------
  #
  # @class AddressFactory
  #
  # @desc Responsibility:  Create a new address either from cached info or from scratch
  # Create it from a list of already created addresses (=cached info),
  # or if that list is empty,
  # create it from Faker info.
  #
  # The list of already created addresses is read from a CSV file.
  # The CSV filename is from ENV['SHF_SEED_FAKE_ADDR_CSV_FILE'] or, if that
  # doesn't exist, the default CSV filename.
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  #
  #
  class AddressFactory

    DEFAULT_FAKE_ADDR_DIR = File.join(Rails.root, 'db')
    DEFAULT_FAKE_ADDR_FILENAME = 'fake-addresses-89--2018-12-12.csv' unless defined?(DEFAULT_FAKE_ADDR_FILENAME)


    def initialize(regions, kommuns)
      @regions = regions
      @kommuns = kommuns
      @fake_addresses_csv_filename = nil
      @already_constructed_addresses = nil
    end


    def default_csv_filename
      DEFAULT_FAKE_ADDR_FILENAME
    end


    # Note that the CSV file is expected to be in this directory
    def fake_addresses_csv_filename
      @fake_addresses_csv_filename ||= File.join(DEFAULT_FAKE_ADDR_DIR, (ENV.fetch('SHF_SEED_FAKE_ADDR_CSV_FILE', default_csv_filename)))
    end


    # if needed, load addresses from the csv file of fake addresses
    def already_constructed_addresses
      @already_constructed_addresses ||= CSVFakeAddressesReader.read_from_csv_file(fake_addresses_csv_filename).shuffle
    end


    def num_regions
      @num_regions ||= @regions.size
    end


    def num_kommuns
      @num_kommuns ||= @kommuns.size
    end


    # Create a new address and save it
    #
    # First try to use an already constructed address.
    #
    # If there are no more already constructed addresses,
    # create a new address from scratch.
    #
    # Note that an address from the already constructed addresses must be saved
    # _without_ validation.  Otherwise it will be geocoded, which defeats the
    # whole purpose of using an already constructed address.
    #
    def make_n_save_a_new_address(addressable_entity)

      if can_use_already_constructed_address?
        new_address = get_an_already_constructed_address(addressable_entity)
      else
        new_address = create_a_new_address(addressable_entity)
      end

      new_address
    end


    # @return [Boolean] - can we get an address from a list of already constructed
    #                     addresses?
    def can_use_already_constructed_address?
      !already_constructed_addresses.empty?
    end


    # Get an already constructed address, assign the addressable entity,
    # remove it from the list of already constructed addresses
    # and save it.
    #
    # If we cannot get an address, return nil
    #
    # We ensure that each address is used just once by
    # removing it from the list of already constructed addresses.
    #
    # @param addressable_entity [] - the addressable object that we will associate with the address
    # @return [Address] - an address that is saved but _not_ validated
    def get_an_already_constructed_address(addressable_entity)

      constructed_address = already_constructed_addresses.pop

      unless constructed_address.nil?
        constructed_address.addressable = addressable_entity
        constructed_address.save(validations: false)
      end

      constructed_address
    end


    # Create a new address.  This will have to be geocoded, which takes time.
    def create_a_new_address(addressable_entity)

      addr = Address.new(addressable: addressable_entity,
                         city: FFaker::AddressSE.city,
                         street_address: FFaker::AddressSE.street_address,
                         post_code: FFaker::AddressSE.zip_code,
                         region: @regions[FFaker.rand(0..(num_regions - 1))],
                         kommun: @kommuns[FFaker.rand(0..(num_kommuns - 1))],
                         visibility: 'street_address')
      tell " Creating a new address: #{addr.street_address} #{addr.city}. (Will geolocate when saving it)"
      addr.save
      addr
    end

    # This makes it easy to stub this message, e.g. during testing so it doesn't actually do anything
    def tell(message)
      puts message
    end
  end # AddressFactory

end
