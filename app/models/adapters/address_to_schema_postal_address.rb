#!/usr/bin/ruby


module Adapters

  #--------------------------
  #
  # @class Adapters::AddressToSchemaPostalAddress
  #
  # @desc Responsibility: (an Adapter) takes an Address and creates a
  #   schema.org PostalAddress
  #     Pattern: Adapter
  #       @adaptee: Address
  #       target: SchemaDotOrg::PostalAddress  https://schema.org/PostalAddress
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2019-02-19
  #
  # @file company_to_schema_postal_address.rb
  #
  #--------------------------
  class AddressToSchemaPostalAddress < AbstractSchemaOrgAdapter


    def target_class
      SchemaDotOrg::PostalAddress
    end


    def set_target_attributes(target)
      
      target.streetAddress = @adaptee.street_address
      target.postalCode = @adaptee.post_code
      target.addressRegion = @adaptee.region.name unless @adaptee.region.nil?
      target.addressLocality = @adaptee.city
      target.addressCountry = @adaptee.country

      target
    end

  end

end

