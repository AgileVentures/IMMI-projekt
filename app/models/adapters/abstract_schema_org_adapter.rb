#!/usr/bin/ruby


module Adapters

  #--------------------------
  #
  # @class Adapters::AbstractSchemaOrgAdapter
  #
  # @desc Responsibility: abstract class that implements the minimum needed
  #   to _adapt_ one object to another.
  #
  #     Pattern: Adapter
  #       https://en.wikipedia.org/wiki/Software_design_pattern
  #       https://en.wikipedia.org/wiki/Adapter_pattern
  #       https://www.oodesign.com/
  #       https://bogdanvlviv.com/posts/ruby/patterns/design-patterns-in-ruby.html
  #
  #   Subclasses must implement:
  #       target_class
  #       set_target_attributes
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2019-02-19
  #
  # @file company_to_schema_org_adapter.rb
  #
  #--------------------------
  class AbstractSchemaOrgAdapter

    def initialize(adaptee)
      raise ArgumentError, "#{self.class.name} #{__method__} must have a non-nil object as the argument" if adaptee.nil?

      @adaptee = adaptee
    end


    # subclasses should return a class for the target so that
    # a new one can be instantiated in :as_target
    #
    def target_class
      raise NoMethodError, "subclasses must return a class for the target (to implement #{__method__})"
    end


    def to_schema_org
      as_target
    end


    def as_target
      target = target_class.new
      set_target_attributes(target)
    end

    alias_method :to_target, :as_target

    # subclasses should set the values/attributes of target in this method
    # and then return it.
    # Use @adaptee to set the values in (= adapt them to) target
    def set_target_attributes(_target)
      raise NoMethodError, "subclasses must implement #{__method__}"
    end
  end

end

