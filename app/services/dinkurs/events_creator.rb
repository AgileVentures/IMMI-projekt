# frozen_string_literal: true

module Dinkurs
  class EventsCreator
    def initialize(company)
      @company = company
    end

    def call
      Event.create!(missed_events_hashes)
    end

    private

    attr_reader :company

    def all_events_hashes
      Dinkurs::EventsParser
          .new(dinkurs_events.dig('events', 'event'), company.id)
          .call
    end

    def missed_events_hashes
      all_events_hashes.reject do |event_hash|
        event_hash[:dinkurs_id].in?(current_events_keys)
      end
    end

    def current_events_keys
      @current_events_keys ||= Event.pluck(:dinkurs_id)
    end

    def dinkurs_events
      Dinkurs::Client.new(company.dinkurs_company_id).company_events_hash
    end
  end
end
