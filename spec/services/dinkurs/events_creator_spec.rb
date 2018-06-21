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

  subject(:event_creator) { described_class.new(company) }

  it 'creating events' do
    Timecop.freeze(Time.zone.local(2018, 6, 1))

    expect { event_creator.call }.to change { Event.count }.by(3)

    Timecop.return
  end

  it 'properly fills data for events' do
    event_creator.call
    expect(Event.last.attributes)
      .to include('fee' => 2368, 'dinkurs_id' => '48712',
                  'name' => 'Deltagarhantering har aldrig varit enklare!',
                  'sign_up_url' =>
                    'https://dinkurs.se/appliance/?event_key=kNzMWFFQTWKBgLPM')
  end

  context 'when date given' do
    subject(:event_creator) do
      described_class.new(company, '2017-07-06 00:00:00'.to_time)
    end

    it 'updates event if last_modified_in_dinkurs date after given date' do
      expect { event_creator.call }.to change { Event.count }.by(4)
    end
  end
end
