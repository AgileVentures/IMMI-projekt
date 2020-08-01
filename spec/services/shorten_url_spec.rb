require 'rails_helper'

describe ShortenUrl do

  let(:mock_log) { instance_double("ActivityLogger") }
  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)
  end


  describe '.short' do
    it 'creates shortened link' do
      VCR.use_cassette('shorten_url/short') do
        shortened_url = ShortenUrl.short 'http://sverigeshundforetagare.se/anvandare/2/proof_of_membership'
        expect(shortened_url).to match 'tinyurl.com/ya6sa84h'
      end
    end
    it 'if the service raises an error, returns nil and writes to the log' do
      VCR.use_cassette('shorten_url/error') do

        expect(mock_log).to receive(:error).with("Exception: HTTParty::Error")
        expect(mock_log).to receive(:error).with("Attempted URL: /")
        expect(mock_log).to receive(:error).with("Response body: ERROR")
        expect(mock_log).to receive(:error).with("HTTP code: 200")

        shortened_url = ShortenUrl.short '/'
        expect(shortened_url).to eq nil
      end
    end
  end
end
