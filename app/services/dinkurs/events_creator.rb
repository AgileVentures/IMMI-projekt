# frozen_string_literal: true

module Dinkurs
  class EventsCreator
    def initialize(company, update_after_date = nil)
      @company = company
      @update_after_date = update_after_date
    end

    def call
      dinkurs_events_hashes.each do |event|
        event_modified_date = event.delete(:last_modified_in_dinkurs)
        next if update_after_date && event_modified_date <= update_after_date

        Event.find_or_create_by(dinkurs_id: event.delete(:dinkurs_id))
             .update(event)
      end
    end

    private

    attr_reader :company, :update_after_date

    def dinkurs_events_hashes
      Dinkurs::EventsParser
        .new(dinkurs_events.dig('events', 'event'), company.id)
        .call
    end

    def current_events_keys
      @current_events_keys ||= Event.pluck(:dinkurs_id)
    end

    def dinkurs_events
      Dinkurs::Client.new(company.dinkurs_company_id).company_events_hash
    end
  end
end
