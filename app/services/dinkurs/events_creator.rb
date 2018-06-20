# frozen_string_literal: true

module Dinkurs

  module Errors
    class InvalidKey < StandardError
    end
  end

  INVALID_KEY_MSG = 'Non existent company key'

  class EventsCreator
    def initialize(company, events_start_date=1.day.ago.to_date)
      @company = company
      @events_start_date = events_start_date
    end

    def call
      # Business rules for fetching dinkurs events:
      # 1. Reject events that started earlier than "events_start_date"
      # 2. Reject events that do not have a location specified

      return unless (events_hashes = dinkurs_events_hashes)

      events_hashes.each do |event|
        next if event[:start_date] < events_start_date ||
                event[:location].blank?

        Event.create(event)
      end
    end

    private

    attr_reader :company, :events_start_date

    def dinkurs_events_hashes
      raise InvalidKey if dinkurs_events[:company] == INVALID_KEY_MSG

      events_data = dinkurs_events.dig('events', 'event')
      events_data = [events_data] if events_data.is_a? Hash
      # ^^ Parser expects an array of events.  HTTParty only returns an
      #    an array if there are multiple events, otherwise a Hash
      Dinkurs::EventsParser
        .new(events_data, company.id)
        .call
    end

    def dinkurs_events
      Dinkurs::Client.new(company.dinkurs_company_id).company_events_hash
    end
  end
end
