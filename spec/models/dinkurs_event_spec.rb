require 'rails_helper'

require 'pp'

require_relative(File.join(__dir__, '..', '..', 'app', 'services', 'dinkurs_service'))


RSpec.describe DinkursEvent, type: :model do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:dinkurs_event)).to be_valid
    end

    it 'creates a new dinkurs event for a company' do
      company = create(:company)
      new_dk_event1 = create(:dinkurs_event, company: company)
      expect(new_dk_event1.company.company_number).to eq(company.company_number)
    end

    it 'creates a new dinkurs event id from a sequence' do
      company = create(:company)
      new_dk_event1 = create(:dinkurs_event, company: company)
      new_dk_event2 = create(:dinkurs_event, company: company)
      expect(new_dk_event1.dinkurs_id).not_to eq(new_dk_event2.dinkurs_id)
    end

  end


  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :dinkurs_id }

    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :place }
    it { is_expected.to have_db_column :place_geometry_location }
    it { is_expected.to have_db_column :host }

    it { is_expected.to have_db_column :fee }
    it { is_expected.to have_db_column :fee_tax }

    it { is_expected.to have_db_column :pub } # date
    it { is_expected.to have_db_column :apply } # date
    it { is_expected.to have_db_column :start } # date
    it { is_expected.to have_db_column :stop } # date

    it { is_expected.to have_db_column :participant_number }
    it { is_expected.to have_db_column :participant_reserve }

    it { is_expected.to have_db_column :participants }

    it { is_expected.to have_db_column :occasions }
    it { is_expected.to have_db_column :group }

    it { is_expected.to have_db_column :position } # number
    it { is_expected.to have_db_column :instructor_1 }
    it { is_expected.to have_db_column :instructor_2 }
    it { is_expected.to have_db_column :instructor_3 }


    it { is_expected.to have_db_column :infotext }
    it { is_expected.to have_db_column :commenttext }


    it { is_expected.to have_db_column :ticket_info }

    it { is_expected.to have_db_column :key } # unique identifier for DinKurs used to construct the event_url_key ?
    it { is_expected.to have_db_column :url_id }
    it { is_expected.to have_db_column :url_key }

    it { is_expected.to have_db_column :completion_text }
    it { is_expected.to have_db_column :aftertext }

    it { is_expected.to have_db_column :dates }

  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :dinkurs_id }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :start }
    it { is_expected.to validate_presence_of :key }
    it { is_expected.to validate_presence_of :url_id }
    it { is_expected.to validate_presence_of :url_key }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:company) }
  end

  describe 'create from an event Hash' do

    it 'valid event info hash as returned from DinKurs.se' do

      event_hash = { 'event_id' => ['1234'],
                     'event_name' => { '__content__' => 'This Event' },
                     'event_place' => { '__content__' => 'Hundistan' },
                     'event_start' => { '__content__' => '2017-11-19' },
                     'event_stop' => { '__content__' => '2017-11-29' },
                     'event_pub' => { '__content__' => '2017-10-01' },
                     'event_key' => { '__content__' => 'key123' },
                     'event_url_id' => { '__content__' => '456789' },
                     'event_url_key' => { '__content__' => 'key123_456789' },
      }

      new_dkev = DinkursEvent.new_from_event_hash(event_hash)
      expect(new_dkev.dinkurs_id).to eq '1234'
      expect(new_dkev.name).to eq 'This Event'
      expect(new_dkev.place).to eq 'Hundistan'
      expect(new_dkev.start).to eq Date.parse('2017-11-19')
      expect(new_dkev.stop).to eq Date.parse('2017-11-29')
      expect(new_dkev.pub).to eq Date.parse('2017-10-01')
      expect(new_dkev.key).to eq 'key123'
      expect(new_dkev.url_id).to eq '456789'
      expect(new_dkev.url_key).to eq 'key123_456789'


    end

  end


  describe '.key_content' do

    it 'nil if the key is not found' do
      expect(described_class.key_content({ 'blorf' => { '__content__' => 123 } }, 'not_found_key')).to be_nil

    end

    it 'nil if _content_ is not the key in the nested hash' do
      expect(described_class.key_content({ 'blorf' => { '_not_content_' => 123 } }, 'blorf')).to be_nil
    end

    it "the value ['key']['_content_']" do
      expect(described_class.key_content({ 'blorf' => { '__content__' => 123 } }, 'blorf')).to eq 123
    end
  end


  describe '.key_content_date' do
    it 'nil if key not found' do
      expect(described_class.key_content_date({ 'blorf' => { '__content__' => '2017-11-29' } }, 'not_found_key')).to be_nil
    end

    it 'nil if value is not a String' do
      expect(described_class.key_content_date({ 'blorf' => { '__content__' => 42 } }, 'blorf')).to be_nil
    end

    it 'date if hash has key and is a string' do
      expect(described_class.key_content_date({ 'blorf' => { '__content__' => '2017-11-29' } }, 'blorf')).to eq Date.parse('2017-11-29')
    end
  end
end
