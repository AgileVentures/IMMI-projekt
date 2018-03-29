# frozen_string_literal: true

require 'rails_helper'

describe Dinkurs::EventsCreator do
  let(:company) do
    create :company,
           id: 1,
           dinkurs_company_id: ENV['DINKURS_COMPANY_TEST_ID']
  end
  let(:events_hashes) { build :events_hashes }

  subject(:event_creator) { described_class.new(company) }

  before do
    VCR.insert_cassette('dinkurs/company_events')
  end

  after { VCR.eject_cassette }

  it 'creating events' do
    expect { event_creator.call }.to change { Event.count }.by(9)
  end

  it 'properly fills data for events' do
    event_creator.call
    expect(Event.last.attributes)
      .to include('fee' => 0.3e3, 'dinkurs_id' => '41988', 'name' => 'stav',
                  'sing_up_url' =>
                      'https://dinkurs.se/appliance/?event_key=BLQHndUsZcZHrJhR')
  end
end
