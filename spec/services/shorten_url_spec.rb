require 'rails_helper'

describe ShortenUrl do
  describe '.short' do
    it 'creates shortened link' do
      VCR.use_cassette('shorten_url/short') do
        shortened_url = ShortenUrl.short 'http://sverigeshundforetagare.se/anvandare/2/proof_of_membership'
        expect(shortened_url).to match 'tinyurl.com/ya6sa84h'
      end
    end
    it 'if the service raises an error, returns nil and writes to the log' do
      VCR.use_cassette('shorten_url/error') do
        expect(ActivityLogger).to receive(:open)
        shortened_url = ShortenUrl.short '/'
        expect(shortened_url).to eq nil
      end
    end
  end
end
