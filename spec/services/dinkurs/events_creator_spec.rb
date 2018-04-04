# frozen_string_literal: true

require 'rails_helper'

describe Dinkurs::EventsCreator,
         vcr: { cassette_name: 'dinkurs/company_events',
                allow_playback_repeats: true } do
  let(:company) do
    create :company,
           id: 1,
           dinkurs_company_id: ENV['DINKURS_COMPANY_TEST_ID']
  end
  let(:events_hashes) { build :events_hashes }

  subject(:event_creator) { described_class.new(company) }

  it 'creating events' do
    expect { event_creator.call }.to change { Event.count } .by(9)
  end

  it 'properly fills data for events' do
    event_creator.call
    expect(Event.last.attributes)
      .to include('fee' => 0.3e3, 'dinkurs_id' => '41988', 'name' => 'stav',
                  'sign_up_url' =>
                      'https://dinkurs.se/appliance/?event_key=BLQHndUsZcZHrJhR')
  end

  it 'not creating same events twice' do
    event_creator.call
    expect { described_class.new(company).call }
      .not_to change { Event.count }
  end
end
