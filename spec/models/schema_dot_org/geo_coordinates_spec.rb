require 'rails_helper'


RSpec.describe SchemaDotOrg::GeoCoordinates, type: :model do

  let(:item) {
    geo           = described_class.new
    geo.latitude  = 'latitude value'
    geo.longitude = 'longitude value'
    geo
  }

  describe '#_to_json_struct' do

    it 'has both latitude and longitude' do
      item           = described_class.new
      item.latitude  = 'latitude value'
      item.longitude = 'longitude value'

      expect(item._to_json_struct).to eq({ "@type" => "GeoCoordinates",
                                           "latitude"  => 'latitude value',
                                           "longitude" => 'longitude value'
                                         })
    end

  end

end
