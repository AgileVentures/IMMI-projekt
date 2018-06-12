# frozen_string_literal: true

module Dinkurs
  class EventsCreator
    def initialize(company, events_start_date=1.day.ago.to_date)
      @company = company
      @events_start_date = events_start_date
    end

    def call
      # Business rules for storing dinkurs events in our DB:
      # 1. Clear all existing company events before fetching events
      # 2. Reject events that started earlier than "events_start_date"
      # 3. Reject events that do not have a location specified

      company.events.clear

      return if company.dinkurs_company_id.blank?

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
