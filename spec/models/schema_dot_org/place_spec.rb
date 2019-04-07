require 'rails_helper'


RSpec.describe SchemaDotOrg::Place, type: :model do

  let(:item) {
    place = described_class.new

    address = SchemaDotOrg::PostalAddress.new
    address.streetAddress = 'street address'
    address.addressCountry = 'address country'
    place.address = address

    geo = SchemaDotOrg::GeoCoordinates.new
    geo.latitude = 'latitude'
    geo.longitude = 'longitude'
    place.geo = geo

    place
  }


  it '_to_json_struct' do
    expect(item._to_json_struct).to eq({"@type"=>"Place",
                                        "address" => {
                                            "@type"=>"PostalAddress",
                                            "streetAddress" => 'street address',
                                            "addressCountry" => 'address country'
                                        },
                                            "geo" => {
                                                "@type"=>"GeoCoordinates",
                                                "latitude"  => 'latitude',
                                                "longitude" => 'longitude'
                                            }
                                      })
  end


  it 'no address' do
    place = described_class.new

    geo = SchemaDotOrg::GeoCoordinates.new
    geo.latitude = 'latitude'
    geo.longitude = 'longitude'
    place.geo = geo

    expect(place._to_json_struct).to eq({"@type"=>"Place",
                                           "geo" => {
                                               "@type"=>"GeoCoordinates",
                                               "latitude"  => 'latitude',
                                               "longitude" => 'longitude'
                                           }
                                       })
  end


  it 'no geo coordinates' do
    place = described_class.new

    address = SchemaDotOrg::PostalAddress.new
    address.streetAddress = 'street address'
    address.addressCountry = 'address country'
    place.address = address

    expect(place._to_json_struct).to eq({"@type"=>"Place",
                                            "address" => {
                                                "@type"=>"PostalAddress",
                                                "streetAddress" => 'street address',
                                                "addressCountry" => 'address country'
                                            }
                                        })
  end


end
