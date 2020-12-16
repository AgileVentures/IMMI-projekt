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

  around(:each) do |example|
    travel_to(Time.zone.local(2018, 6, 1)) do
     example.run
    end
  end

  it 'creating events' do
    expect { event_creator.call }.to change { Event.count }.by(3)
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


  context 'bad event format received from Dinkurs' do

    it 'raises InvalidFormat error and displays the source information' do
      # This happened on 11 August 2020:
      #   Failure! Failure! undefined method `dig' for #<String:0x0000000008be2140> 2020-08-12 02:01:41 UTC
      #   SHF: DinkursFetch | Aug 11th

      allow_any_instance_of(Dinkurs::Client).to receive(:company_events_hash).and_return('some string')
      expect{ subject.call }.to raise_error(Dinkurs::Errors::InvalidFormat, 'Could not get event info from: "some string"')
    end

    it 'any error raised by anything during the call continues up (is not stopped or changed)' do
      allow_any_instance_of(Dinkurs::Client).to receive(:company_events_hash).and_raise(Dinkurs::Errors::InvalidFormat, 'bad error message')
      expect{ subject.call }.to raise_error(Dinkurs::Errors::InvalidFormat, 'bad error message')
    end
  end
end
