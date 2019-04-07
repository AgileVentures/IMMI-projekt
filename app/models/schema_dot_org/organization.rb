#!/usr/bin/ruby



module SchemaDotOrg

  #--------------------------
  #
  # @class Organization
  #         https://schema.org/Organization
  #   This is just a subset of the properties of the schema.org Organization type
  #
  # @desc Responsibility: "An organization such as a school, NGO, corporation, club, etc."
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2019-02-19
  #
  # @file organization.rb
  #
  #--------------------------
  class Organization < Thing

    attr_accessor :email,
                  :telephone,
                  :location,
                  :address,
                  :geo,
                  :image,
                  :memberOf,
                  :knowsAbout,
                  :knowsLanguage
  end

end
