#!/usr/bin/ruby


module Adapters

  #--------------------------
  #
  # @class BusinessCatsIntoKnowsString
  #
  # @desc Responsibility: Adapts (converts) SHF buisness categories into a
  #       string, prepending I18n.t('dog') before each one
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2019-03-08
  #
  # @file business_cats_to_schema_local_business.rb
  #
  #--------------------------
  class BusinessCatsIntoKnowsString


    def self.knows_str(business_categories)

      return nil if business_categories.empty?

      knows_about = []
      business_categories.each do |category|
        knows_about << "#{I18n.t('dog').capitalize} #{category.name}"
      end

      knows_about
    end

  end

end
