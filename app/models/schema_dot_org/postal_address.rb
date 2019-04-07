#!/usr/bin/ruby



module SchemaDotOrg

  #--------------------------
  #
  # @class PostalAddress
  #         https://schema.org/PostalAddress
  #   This is just a subset of the properties of the schema.org PostalAddress type
  #
  # @desc Responsibility: "The mailing address."
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2019-02-19
  #
  # @file postal_address.rb
  #
  #--------------------------
  class PostalAddress < Thing

    attr_accessor :streetAddress,
                  :postOfficeBoxNumber,
                  :postalCode,
                  :addressRegion,
                  :addressLocality,
                  :addressCountry

  end

end
