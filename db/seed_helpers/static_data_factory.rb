require_relative '../seed_helpers'
require_relative('../seed_helpers.rb')

#--------------------------
#
# @class SeedHelpers::StaticDataFactory
#
# @desc Responsibility: seed static data (Regions, Kommuns, BusinessCategories)
#    and cache it for easy acceess by other classes
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   6/23/21
#
#--------------------------

module SeedHelpers
  class StaticDataFactory

    attr_writer :address_factory

    # Initialize the instance vars
    #
    # @regions, @kommuns, and @business_categories are initialized using
    # lazy initialization - only when they're called.
    def initialize
      @regions     = nil
      @kommuns     = nil
      @business_categories = nil
      @address_factory = AddressFactory.new(regions, kommuns)
    end


    # use lazy initialization; cache all Regions
    def regions
      @regions ||= Region.all.to_a
    end

    # use lazy initialization; cache all Kommuns
    def kommuns
      @kommuns ||= Kommun.all.to_a
    end

    # use lazy initialization; cache all BusinessCategory
    def business_categories
      @business_categories ||= BusinessCategory.all.to_a
    end

    def address_factory
      @address_factory ||= AddressFactory.new(regions, kommuns)
    end

  end
end
