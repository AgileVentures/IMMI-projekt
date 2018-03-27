# frozen_string_literal: true

require 'rails_helper'

describe Dinkurs::Client, :vcr do
  VCR.insert_cassette('dinkurs/company_events')

  subject(:dinkurs_client) do
    described_class.new(ENV['DINKURS_COMPANY_TEST_ID'])
  end

  it '#company_events_hash returns hash' do
    expect(dinkurs_client.company_events_hash).to be_a(Hash)
  end

  it 'returns proper number of event' do
    expect(dinkurs_client.company_events_hash['events']['event'].count)
      .to eq(9)
  end
end
