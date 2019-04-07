#!/usr/bin/ruby


module Adapters

  #--------------------------
  #
  # @class AddressesIntoSchemaLocalBusiness
  #
  # @desc Responsibility: Adapts (converts) SHF addresses and adds them to a
  #       schema.org LocalBusiness
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2019-03-08
  #
  # @file addresses_to_schema_local_business.rb
  #
  #--------------------------
  class AddressesIntoSchemaLocalBusiness


    def self.set_address_properties(addresses, main_address, local_biz)

      local_biz = set_main_address(main_address, local_biz)

      unless addresses.empty?
        # for multiple addresses, list multiple locations, each with an address and geo coordinates
        if addresses.size > 1
          local_biz.location = []
          addresses.each { |address| add_address_to_location(address, local_biz.location) }
        end
      end

      local_biz
    end


    def self.set_main_address(main_addr, local_biz)
      local_biz.address = AddressToSchemaPostalAddress.new(main_addr).as_target
      local_biz.geo     = AddressToSchemaGeoCoordinates.new(main_addr).as_target
      local_biz
    end


    def self.add_address_to_location(address, location)
      location << AddressToSchemaPlace.new(address).as_target
      location
    end
  end

end
