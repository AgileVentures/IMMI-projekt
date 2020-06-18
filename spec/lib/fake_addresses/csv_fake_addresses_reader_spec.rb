require 'rails_helper'

require_relative('../../../lib/fake_addresses/csv_fake_addresses_reader')

RSpec.describe CSVFakeAddressesReader do
  let(:addresses) {
    company_overtornea = create(:company, city: 'Övertorneå')

    addr1 = create(:address, addressable: (create :company))
    addr2 = create(:address, street_address: 'Matarengivägen 24',
                   post_code:                '957 31',
                   city:                     'Övertorneå',
                   addressable:              company_overtornea)
    [addr1, addr2]
  }

  describe '.create_address' do
    before(:each) do
      create(:region, name: 'Blorf')
      create(:kommun, name: 'Flurb')
    end

    let(:address_hash) do
      { id:             11,
        street_address: 'Hundvägen 101',
        post_code:      '310 40',
        city:           'Harplinge',
        country:        'Sverige',
        region_name:    'Blorf',
        kommun_name:    'Flurb',
        latitude:       60.12816100000001,
        longitude:      18.643501,
        visibility:     "street_address", mail: "false"
      }
    end

    it 'finds the region and kommun based on their names' do
      new_address = CSVFakeAddressesReader.create_address(address_hash)
      expect(new_address.region.name).to eq 'Blorf'
      expect(new_address.kommun.name).to eq 'Flurb'
    end

    it 'assigns Stockholm as the Region if it cannot find the one named in the hash' do
      create(:region, name: 'Stockholm')

      hash_with_unknown_region = address_hash.merge({ region_name: 'not found' })
      new_address              = CSVFakeAddressesReader.create_address(hash_with_unknown_region)
      expect(new_address.region.name).to eq 'Stockholm'
    end

    it 'assigns Stockholm as the Kommun if it cannot find the one named in the hash' do
      create(:kommun, name: 'Stockholm')

      hash_with_unknown_kommun = address_hash.merge({ kommun_name: 'not found' })
      new_address              = CSVFakeAddressesReader.create_address(hash_with_unknown_kommun)
      expect(new_address.kommun.name).to eq 'Stockholm'
    end

    it 'instantiates an Address but does not save it' do
      expect(Address.count).to eq 0
      new_address = CSVFakeAddressesReader.create_address(address_hash)
      expect(new_address).to be_a(Address)

      # it is not saved to the db.
      expect(Address.count).to eq 0
    end
  end #  describe '.create_address'

  describe '.find_region_from_name' do
    it 'if the region cannot be found, use Stockholm ' do
      create(:region, name: 'Stockholm')
      expect(Region.find_by(name: 'blorfo')).to be_nil

      region_found = CSVFakeAddressesReader.find_region_from_name('blorfo')
      expect(region_found.name).to eq 'Stockholm'
    end

    it 'if Region with name = Stockholm does not exist, raise an error' do
      expect(Region.find_by(name: 'Stockholm')).to be_nil

      expect { CSVFakeAddressesReader.find_region_from_name('blorfo') }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '.find_kommun_from_name' do
    it 'if the kommun cannot be found, use Stockholm ' do
      create(:kommun, name: 'Stockholm')
      expect(Kommun.find_by(name: 'blorfo')).to be_nil

      kommun_found = CSVFakeAddressesReader.find_kommun_from_name('blorfo')
      expect(kommun_found.name).to eq 'Stockholm'
    end

    it 'if Kommun with name = Stockholm does not exist, raise an error' do
      expect(Kommun.find_by(name: 'Stockholm')).to be_nil

      expect { CSVFakeAddressesReader.find_kommun_from_name('blorfo') }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe 'create addresses from CSV file contents' do
    # must have a Company for the new addresses
    let(:fake_co) { create(:company) }

    let(:csv_data) do
      [
          { id:             11,
            street_address: 'Hundvägen 101',
            post_code:      '310 40',
            city:           'Harplinge',
            country:        'Sverige',
            region_name:    'Mertz',
            kommun_name:    'Zab',
            latitude:       60.12816100000001,
            longitude:      18.643501,
            visibility:     'street_address',
            mail:           'false' },
          { id:             12,
            street_address: 'Matarengivägen 24',
            post_code:      '957 31',
            city:           'Övertorneå',
            country:        'Sverige',
            region_name:    'Blorf',
            kommun_name:    'Flurb',
            latitude:       60.12816100000001,
            longitude:      18.643501,
            visibility:     'street_address',
            mail:           false }
      ]
    end

    before(:each) do
      create(:region, name: 'Mertz')
      create(:region, name: 'Blorf')
      create(:kommun, name: 'Zab')
      create(:kommun, name: 'Flurb')
    end

    it 'creates 1 address for each entry' do
      created_addresses = CSVFakeAddressesReader.create_addresses(csv_data)
      expect(created_addresses.size).to eq 2

      created_addresses.each do |created_address|
        expect(created_address).to be_an Address
      end
    end
  end # describe '.create_addresses'

  describe '.read_from_csv_file' do
    TEST_CSV_FN = File.join(Dir.mktmpdir('csv_test'), 'temp_csv.csv')

    before(:all) do
      # create a temp CSV file
      File.open(TEST_CSV_FN, 'w') do |tempfile|
        tempfile.print("id,street_address,post_code,city,country,region_name,kommun_name,latitude,longitude,visibility,mail\n")
        tempfile.print("11,\"Hundvägen 101\",\"310 40\",\"Harplinge\",\"Sverige\",\"Blorf\",\"Ale\",60.12816100000001,18.643501,street_address,false\n")
        tempfile.print("12,\"Matarengivägen 24\",\"957 31\",\"Övertorneå\",\"Sverige\",\"Flurb\",\"Mertz\",60.12816100000001,18.643501,street_address,false\n")
      end
    end

    before(:each) do
      create(:region, name: 'Stockholm')
      create(:region, name: 'Blorf')
      create(:kommun, name: 'Stockholm')
      create(:kommun, name: 'Ale')
    end

    let(:addresses) { CSVFakeAddressesReader.read_from_csv_file(TEST_CSV_FN) }

    it 'one entry for each Address' do
      expect(addresses.size).to eq 2
    end

    it 'creates Addresses' do
      uniq_classes = addresses.map(&:class).uniq
      expect(uniq_classes.size).to eq 1
      expect(uniq_classes.first.name).to eq 'Address'
    end
  end
end
