require 'rails_helper'
require_relative(File.join( SERVICES_PATH, 'address_exporter'))


RSpec.describe AddressExporter do

  describe '#se_mailing_csv_str(address)' do


    let(:a_company) { FactoryBot.create(:company, num_addresses: 0) }

    let(:norbotten_region) { FactoryBot.create(:region, name: 'Norrbotten') }
    let(:overtornea_kommun) { FactoryBot.create(:kommun, name: 'Övertorneå') }

    let(:valid_address1) { addr1 = FactoryBot.create(:address,
                                                      street_address: 'Matarengivägen 24',
                                                      post_code: '957 31',
                                                      city: 'Övertorneå',
                                                      kommun: overtornea_kommun,
                                                      region: norbotten_region,
                                                      addressable: a_company)
    addr1
    }


    def post_code_str(post_code)
      "'#{post_code}"
    end


    it 'handles a nil address' do

      expected_str = Array.new(6, '').join(',')

      expect(AddressExporter.se_mailing_csv_str(nil)).to eq expected_str

    end


    it 'is a comma separated string' do

      expected_str = '"' + valid_address1.street_address + '",'
      expected_str << "#{post_code_str valid_address1.post_code},\"#{valid_address1.city}\",#{valid_address1.kommun.name },#{valid_address1.region.name},Sverige"

      expect(AddressExporter.se_mailing_csv_str(valid_address1)).to eq expected_str
    end


    describe 'puts double quotes around the street address' do

      it 'nil street address' do

        nil_street = valid_address1.update(street_address: nil)

        export_str = AddressExporter.se_mailing_csv_str(valid_address1)

        expect(export_str).to match(/"",'957 31,"Övertorneå",/)
      end

      it 'valid street address' do

        export_str = AddressExporter.se_mailing_csv_str(valid_address1)

        expect(export_str).to match(/"Matarengivägen 24",/)
      end

    end


    it "post_code starts with a single quote (') so spreadsheets will see it as text, not a number (so any spaces are not lost)" do

      export_str = AddressExporter.se_mailing_csv_str(valid_address1)

      expect(export_str).to match(/957 31/)
      expect(export_str).not_to match(/95731/)

    end


    it 'handles a nil kommun' do

      valid_address1.kommun = nil

      expected_str = '"' + valid_address1.street_address + '",'
      expected_str << "#{post_code_str valid_address1.post_code},\"#{valid_address1.city}\",,#{valid_address1.region.name},Sverige"

      expect(AddressExporter.se_mailing_csv_str(valid_address1)).to eq expected_str

    end

    it 'handles a nil region' do

      valid_address1.region = nil

      expected_str = '"' + valid_address1.street_address + '",'
      expected_str << "#{post_code_str valid_address1.post_code},\"#{valid_address1.city}\",#{valid_address1.kommun.name },,Sverige"

      expect(AddressExporter.se_mailing_csv_str(valid_address1)).to eq expected_str

    end

    it "will use whatever is stored for the country" do

      valid_address1.country = "Sweeeeeden"

      export_str = AddressExporter.se_mailing_csv_str(valid_address1)

      expect(export_str).to match(/Sweeeeeden/)
      expect(export_str).not_to match(/SE-Sweden/)
    end


  end

end
