require 'rails_helper'


RSpec.describe SchemaDotOrg::LocalBusiness, type: :model do

  let(:complete_company) do
    co               = described_class.new
    co.name          = 'org1'
    co.description   = '1 address'
    co.url           = 'https:/org1/'
    co.email         = 'org1@example.com'
    co.memberOf      = 'Sverigeshundföretagare'
    co.knowsLanguage = 'sv-SE'
    co.telephone     = '134 948494 01'

    addr                     = SchemaDotOrg::PostalAddress.new
    addr.streetAddress       = 'street address'
    addr.postOfficeBoxNumber = '3a'
    addr.postalCode          = '01010101 01'
    addr.addressRegion       = 'Blorfish'
    addr.addressLocality     = 'Blorf county'
    addr.addressCountry      = 'Blorfland'
    co.address               = addr

    geo           = SchemaDotOrg::GeoCoordinates.new
    geo.latitude  = 3
    geo.longitude = 4
    co.geo        = geo

    co.image = 'https://example.com/some-image.jpg'
    co
  end


  let(:mult_addr_co) do
    co               = described_class.new
    co.name          = 'org2'
    co.description   = 'multiple addresses'
    co.url           = 'https:/org1/'
    co.email         = 'org1@example.com'
    co.memberOf      = 'Sverigeshundföretagare'
    co.knowsLanguage = 'sv-SE'
    co.telephone     = '134 948494 01'
    co.location      = []

    addr1                     = SchemaDotOrg::PostalAddress.new
    addr1.streetAddress       = 'street address'
    addr1.postOfficeBoxNumber = '3a'
    addr1.postalCode          = '01010101 01'
    addr1.addressRegion       = 'Blorfish'
    addr1.addressLocality     = 'Blorf county'
    addr1.addressCountry      = 'Blorfland'

    geo1           = SchemaDotOrg::GeoCoordinates.new
    geo1.latitude  = 3
    geo1.longitude = 4

    place1         = SchemaDotOrg::Place.new
    place1.address = addr1
    place1.geo     = geo1

    co.address = addr1
    co.geo     = geo1
    co.location << place1

    addr2                 = SchemaDotOrg::PostalAddress.new
    addr2.streetAddress   = 'street address2'
    addr2.postalCode      = '2'
    addr2.addressRegion   = 'Blorfish2'
    addr2.addressLocality = 'Blorf2 county'
    addr2.addressCountry  = 'Blorf2land'

    geo2           = SchemaDotOrg::GeoCoordinates.new
    geo2.latitude  = 6
    geo2.longitude = 8

    place2         = SchemaDotOrg::Place.new
    place2.address = addr2
    place2.geo     = geo2
    co.location << place2

    addr3                 = SchemaDotOrg::PostalAddress.new
    addr3.streetAddress   = 'street address3'
    addr3.postalCode      = '3'
    addr3.addressRegion   = 'Blorfish3'
    addr3.addressLocality = 'Blorf3 county'
    addr3.addressCountry  = 'Blorf3land'
    geo3                  = SchemaDotOrg::GeoCoordinates.new
    geo3.latitude         = 9
    geo3.longitude        = 12

    place3         = SchemaDotOrg::Place.new
    place3.address = addr3
    place3.geo     = geo3
    co.location << place3

    co.image = 'https://example.com/some-image.jpg'
    co
  end


  describe '_to_json_struct' do

    it '1 address' do
      expect(complete_company._to_json_struct).to eq({ "@type"         => "LocalBusiness",
                                                       "description"   => "1 address",
                                                       "email"         => "org1@example.com",
                                                       "image"         => "https://example.com/some-image.jpg",
                                                       "memberOf"      => "Sverigeshundföretagare",
                                                       "knowsLanguage" => "sv-SE",
                                                       "address"       => {
                                                           "@type"               => "PostalAddress",
                                                           "streetAddress"       => 'street address',
                                                           "postOfficeBoxNumber" => '3a',
                                                           "postalCode"          => '01010101 01',
                                                           "addressRegion"       => 'Blorfish',
                                                           "addressLocality"     => 'Blorf county',
                                                           "addressCountry"      => 'Blorfland'
                                                       },
                                                       "geo"           => {
                                                           "@type"     => "GeoCoordinates",
                                                           "latitude"  => 3,
                                                           "longitude" => 4
                                                       },
                                                       "name"          => "org1",
                                                       "telephone"     => "134 948494 01",
                                                       "url"           => "https:/org1/"
                                                     })
    end


    it 'multiple addresses' do
      expect(mult_addr_co._to_json_struct).to eq({
                                                     "@type"         => "LocalBusiness",
                                                     "description"   => "multiple addresses",
                                                     "email"         => "org1@example.com",
                                                     "image"         => "https://example.com/some-image.jpg",
                                                     "memberOf"      => "Sverigeshundföretagare",
                                                     "knowsLanguage" => "sv-SE",
                                                     "address"       => {
                                                         "@type"               => "PostalAddress",
                                                         "streetAddress"       => 'street address',
                                                         "postOfficeBoxNumber" => '3a',
                                                         "postalCode"          => '01010101 01',
                                                         "addressRegion"       => 'Blorfish',
                                                         "addressLocality"     => 'Blorf county',
                                                         "addressCountry"      => 'Blorfland'
                                                     },
                                                     "geo"           => {
                                                         "@type"     => "GeoCoordinates",
                                                         "latitude"  => 3,
                                                         "longitude" => 4
                                                     },
                                                     "name"          => "org2",
                                                     "telephone"     => "134 948494 01",
                                                     "url"           => "https:/org1/",
                                                     "location"      => [
                                                         { "@type"   => "Place",
                                                           "address" => {
                                                               "@type"               => "PostalAddress",
                                                               "streetAddress"       => 'street address',
                                                               "postOfficeBoxNumber" => '3a',
                                                               "postalCode"          => '01010101 01',
                                                               "addressRegion"       => 'Blorfish',
                                                               "addressLocality"     => 'Blorf county',
                                                               "addressCountry"      => 'Blorfland'
                                                           },
                                                           "geo"     => {
                                                               "@type"     => "GeoCoordinates",
                                                               "latitude"  => 3,
                                                               "longitude" => 4
                                                           }
                                                         },
                                                         { "@type"   => "Place",
                                                           "address" => {
                                                               "@type"           => "PostalAddress",
                                                               "streetAddress"   => 'street address2',
                                                               "postalCode"      => '2',
                                                               "addressRegion"   => 'Blorfish2',
                                                               "addressLocality" => 'Blorf2 county',
                                                               "addressCountry"  => 'Blorf2land'
                                                           },
                                                           "geo"     => {
                                                               "@type"     => "GeoCoordinates",
                                                               "latitude"  => 6,
                                                               "longitude" => 8
                                                           }
                                                         },
                                                         { "@type"   => "Place",
                                                           "address" => {
                                                               "@type"           => "PostalAddress",
                                                               "streetAddress"   => 'street address3',
                                                               "postalCode"      => '3',
                                                               "addressRegion"   => 'Blorfish3',
                                                               "addressLocality" => 'Blorf3 county',
                                                               "addressCountry"  => 'Blorf3land'
                                                           },
                                                           "geo"     => {
                                                               "@type"     => "GeoCoordinates",
                                                               "latitude"  => 9,
                                                               "longitude" => 12
                                                           }
                                                         }
                                                     ]
                                                 })
    end
  end


  describe 'to_ld_json' do

    it 'has 1 address' do
      to_ld_json   = complete_company.to_ld_json
      script_start = /<script type="application\/ld\+json">(\s)*/
      script_end   = /(\s)*<\/script>/
      expect(to_ld_json).to match(script_start)
      expect(to_ld_json).to match(script_end)

      ld_json_hash_str = to_ld_json.sub(script_start, '').sub(script_end, '')
      ld_json_hash     = JSON.parse(ld_json_hash_str)

      # convert to a Hash because the order might be different
      expect(ld_json_hash).to eq({ "@context"      => "http://schema.org",
                                   "@type"         => "LocalBusiness",
                                   "@id"           => "https:/org1/",
                                   "name"          => "org1",
                                   "description"   => "1 address",
                                   "url"           => "https:/org1/",
                                   "email"         => "org1@example.com",
                                   "memberOf"      => "Sverigeshundföretagare",
                                   "knowsLanguage" => "sv-SE",
                                   "telephone"     => "134 948494 01",
                                   "address"       => {
                                       "@type"               => "PostalAddress",
                                       "streetAddress"       => 'street address',
                                       "postOfficeBoxNumber" => '3a',
                                       "postalCode"          => '01010101 01',
                                       "addressRegion"       => 'Blorfish',
                                       "addressLocality"     => 'Blorf county',
                                       "addressCountry"      => 'Blorfland'
                                   },
                                   "geo"           => {
                                       "@type"     => "GeoCoordinates",
                                       "latitude"  => 3,
                                       "longitude" => 4
                                   },

                                   "image"         => "https://example.com/some-image.jpg" })
    end


    it 'mulitple addresses' do

      to_ld_json   = mult_addr_co.to_ld_json
      script_start = /<script type="application\/ld\+json">(\s)*/
      script_end   = /(\s)*<\/script>/
      expect(to_ld_json).to match(script_start)
      expect(to_ld_json).to match(script_end)

      ld_json_hash_str = to_ld_json.sub(script_start, '').sub(script_end, '')
      ld_json_hash     = JSON.parse(ld_json_hash_str)

      expect(ld_json_hash).to eq({ "@context"      => "http://schema.org",
                                   "@type"         => "LocalBusiness",
                                   "@id"           => "https:/org1/",
                                   "name"          => "org2",
                                   "description"   => "multiple addresses",
                                   "url"           => "https:/org1/",
                                   "email"         => "org1@example.com",
                                   "memberOf"      => "Sverigeshundföretagare",
                                   "knowsLanguage" => "sv-SE",
                                   "telephone"     => "134 948494 01",
                                   "address"       => {
                                       "@type"               => "PostalAddress",
                                       "streetAddress"       => 'street address',
                                       "postOfficeBoxNumber" => '3a',
                                       "postalCode"          => '01010101 01',
                                       "addressRegion"       => 'Blorfish',
                                       "addressLocality"     => 'Blorf county',
                                       "addressCountry"      => 'Blorfland'
                                   },
                                   "geo"           => {
                                       "@type"     => "GeoCoordinates",
                                       "latitude"  => 3,
                                       "longitude" => 4
                                   },

                                   "image"         => "https://example.com/some-image.jpg",

                                   "location"      => [
                                       { "@type"   => "Place",
                                         "address" => {
                                             "@type"               => "PostalAddress",
                                             "addressCountry"      => "Blorfland",
                                             "addressLocality"     => "Blorf county",
                                             "addressRegion"       => "Blorfish",
                                             "postOfficeBoxNumber" => "3a",
                                             "postalCode"          => "01010101 01",
                                             "streetAddress"       => "street address" },
                                         "geo"     => {
                                             "@type" => "GeoCoordinates", "latitude" => 3, "longitude" => 4 }
                                       },
                                       { "@type"   => "Place",
                                         "address" => {
                                             "@type"           => "PostalAddress",
                                             "addressCountry"  => "Blorf2land",
                                             "addressLocality" => "Blorf2 county",
                                             "addressRegion"   => "Blorfish2",
                                             "postalCode"      => "2",
                                             "streetAddress"   => "street address2" },
                                         "geo"     => {
                                             "@type" => "GeoCoordinates", "latitude" => 6, "longitude" => 8 }
                                       },
                                       { "@type"   => "Place",
                                         "address" => {
                                             "@type"           => "PostalAddress",
                                             "addressCountry"  => "Blorf3land",
                                             "addressLocality" => "Blorf3 county",
                                             "addressRegion"   => "Blorfish3", "postalCode" => "3",
                                             "streetAddress"   => "street address3" },
                                         "geo"     => {
                                             "@type" => "GeoCoordinates", "latitude" => 9, "longitude" => 12 }
                                       }
                                   ]
                                 })

    end


    it 'no address' do

      co_no_address               = described_class.new
      co_no_address.name          = 'org1'
      co_no_address.description   = 'no address'
      co_no_address.url           = 'https:/org1/'
      co_no_address.email         = 'org1@example.com'
      co_no_address.memberOf      = 'Sverigeshundföretagare'
      co_no_address.knowsLanguage = 'sv-SE'
      co_no_address.telephone     = '134 948494 01'
      co_no_address.image         = 'https://example.com/some-image.jpg'

      to_ld_json   = co_no_address.to_ld_json
      script_start = /<script type="application\/ld\+json">(\s)*/
      script_end   = /(\s)*<\/script>/
      expect(to_ld_json).to match(script_start)
      expect(to_ld_json).to match(script_end)

      ld_json_hash_str = to_ld_json.sub(script_start, '').sub(script_end, '')
      ld_json_hash     = JSON.parse(ld_json_hash_str)

      # convert to a Hash because the order might be different
      expect(ld_json_hash).to eq({ "@context"      => "http://schema.org",
                                   "@type"         => "LocalBusiness",
                                   "@id"           => "https:/org1/",
                                   "name"          => "org1",
                                   "description"   => "no address",
                                   "url"           => "https:/org1/",
                                   "email"         => "org1@example.com",
                                   "memberOf"      => "Sverigeshundföretagare",
                                   "knowsLanguage" => "sv-SE",
                                   "telephone"     => "134 948494 01",
                                   "image"         => "https://example.com/some-image.jpg" })
    end

  end

end
