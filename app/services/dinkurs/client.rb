module Dinkurs
  class Client
    BASE_URL = ENV['DINKURS_XML_URL']

    def initialize(company_id)
      @company_id = company_id
    end

    def company_events_hash
      request_dinkurs_for_company.parsed_response
    end

    private
    attr_reader :company_id

    def request_dinkurs_for_company
      HTTParty.get("#{BASE_URL}?company_key=#{company_id}")
    end
  end
end
