require 'rails_helper'
require 'email_spec/rspec'

require 'shared_examples/shared_conditions'


RSpec.describe DinkursFetch, type: :model do

  let(:mock_log) { instance_double("ActivityLogger") }

  let(:condition) { build(:condition, timing: Backup::TIMING_EVERY_DAY) }
  let(:today) { Time.now.strftime '%Y-%m-%d' }

  let(:company_with_dinkurs_id) do
    create(:company, dinkurs_company_id: ENV['DINKURS_COMPANY_TEST_ID'])
  end

  let(:company_without_dinkurs_id) { create(:company) }

  describe '.condition_response' do
    it_behaves_like 'it validates timings in .condition_response', [:every_day] do
      let(:tested_condition) { condition }
    end

    context 'Fetch Dinkurs events', vcr: { cassette_name: 'dinkurs/company_events' } do

      around(:each) do |example|
        Timecop.freeze(Time.zone.local(2018, 6, 1))
        example.run
        Timecop.return
      end

      it 'Fetches events for companies with dinkurs_id' do
        allow(mock_log).to receive(:record)

        expect{ described_class.condition_response(condition, mock_log) }
          .to change { company_with_dinkurs_id.events.count }.by(3)
      end

      it 'Writes to log file with events count' do
        company_with_dinkurs_id

        expect(mock_log).to receive(:record).with('info', "Company #{company_with_dinkurs_id.id}: 3 events.")

        described_class.condition_response(condition, mock_log)
      end

      it 'Does not write to log file for company without dinkurs_id' do
        company_without_dinkurs_id

        expect(mock_log).not_to receive(:record)

        described_class.condition_response(condition, mock_log)
      end

    end
  end
end
