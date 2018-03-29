# frozen_string_literal: true

module Dinkurs
  class EventsCreator
    def initialize(company)
      @company = company
    end

    def call
      Event.create!(events_hashes)
    end

    private

    attr_reader :company

    def events_hashes
      Dinkurs::EventsParser
        .new(dinkurs_events.dig('events', 'event'), company.id)
        .call
    end

    def dinkurs_events
      Dinkurs::Client.new(company.dinkurs_company_id).company_events_hash
    end
  end
end
