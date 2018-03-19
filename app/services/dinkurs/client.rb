module Dinkurs
  class Client
    BASE_URL = 'https://dinkurs.se/lxml.asp'

    def initialize(company_id)
      @company_id = company_id
    end

    def fetch_company_events

    end

    def request_dinkurs_for_company
      Net::HTTP.get(BASE_URL, "?company_key=#{company_id}")
    end

    private

    attr_reader :company_id
  end
end
