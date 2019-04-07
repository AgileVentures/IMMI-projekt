#!/usr/bin/ruby



module SchemaDotOrg

  #--------------------------
  #
  # @class GeoCoordinates
  #         https://schema.org/GeoCoordinates
  #   This is just a subset of the properties of the schema.org GeoCoordinates type
  #
  # @desc Responsibility: "The geographic coordinates of a place or event."
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2019-02-19
  #
  # @file geo_coordinates.rb
  #
  #--------------------------
  class GeoCoordinates < Thing

    attr_accessor :latitude, :longitude

  end

end
