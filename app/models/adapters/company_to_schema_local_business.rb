#!/usr/bin/ruby

require_relative File.join(__dir__, '../concerns/company_hmarkt_url_generator')


module Adapters

  #--------------------------
  #
  # @class Adapters::CompanyToSchemaLocalBusiness
  #
  # @desc Responsibility: (an Adapter) takes a Company and creates a
  #   schema.org local business
  #   Note that we need to create a local business so that we can have multiple
  #   locations (places).
  #
  #     Pattern: Adapter
  #       @adaptee: Company
  #       target: SchemaDotOrg::LocalBusiness  https://schema.org/LocalBusiness
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2019-02-19
  #
  # @file company_to_schema_local_business.rb
  #
  #--------------------------
  class CompanyToSchemaLocalBusiness < AbstractSchemaOrgAdapter

    include CompanyHMarktUrlGenerator

    def initialize(adaptee, url: '')
      super(adaptee)
      @target_url = url
    end

    def target_class
      SchemaDotOrg::LocalBusiness
    end


    def set_target_attributes(target)

      target.name        = @adaptee.name
      target.description = @adaptee.description
      target.url         = @target_url
      target.email       = @adaptee.email
      target.telephone   = @adaptee.phone_number
      target.image       = company_h_markt_url(@adaptee) # TODO this needs to be a permanent image and URL

      target               = AddressesIntoSchemaLocalBusiness.set_address_properties(@adaptee.addresses,
                                                                                     @adaptee.main_address,
                                                                                     target)
      target.knowsLanguage = 'sv-SE'
      target.knowsAbout    = BusinessCatsIntoKnowsString.knows_str(@adaptee.business_categories)

      target
    end


    # TODO - this should come from a helper or someplace else, not be hardcoded.  Fix when images are implemented
    def url_for_co_hbrand_image(company)
      "#{I18n.t('shf_medlemssystem_url')}/hundforetag/#{company.id}/company_h_brand"
    end


  end

end

