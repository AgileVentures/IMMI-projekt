# frozen_string_literal: true

module Dinkurs
  class Client
    BASE_URL = ENV['SHF_DINKURS_XML_URL']

    def initialize(dinkurs_company_id)
      @dinkurs_company_id = dinkurs_company_id
    end

    def company_events_hash
      request_dinkurs_for_company.parsed_response
    end

    private

    attr_reader :dinkurs_company_id

    def request_dinkurs_for_company
      HTTParty.get("#{BASE_URL}?company_key=#{dinkurs_company_id}")
    end
  end
end
