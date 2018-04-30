# frozen_string_literal: true

module Dinkurs
  class EventsParser
    def initialize(dinkurs_events, company_id)
      @dinkurs_events = dinkurs_events
      @company_id = company_id
    end

    def call
      dinkurs_events.map do |event|
        prepare_event_hash(event)
      end
    end

    private

    attr_reader :dinkurs_events, :company_id

    def prepare_event_hash(event)
      { dinkurs_id: event['event_id'].first,
        name: event.dig('event_name', '__content__'),
        last_modified_in_dinkurs:
            event.dig('event_modstamp', '__content__').to_date,
        fee: event.dig('event_fee', '__content__').to_f,
        start_date: event.dig('event_start', '__content__').to_date,
        description: event.dig('event_infotext', '__content__'),
        sign_up_url: event.dig('event_url_key', '__content__'),
        company_id: company_id }
    end
  end
end
