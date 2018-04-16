# frozen_string_literal: true

require 'rails_helper'

describe Dinkurs::Client, vcr: { cassette_name: 'dinkurs/company_events' } do
  subject(:dinkurs_client) do
    described_class.new(ENV['DINKURS_COMPANY_TEST_ID'])
  end

  it '#company_events_hash returns hash' do
    expect(dinkurs_client.company_events_hash).to be_a(Hash)
  end

  it 'returns proper number of events' do
    expect(dinkurs_client.company_events_hash['events']['event'].count)
      .to eq(11)
  end
end
