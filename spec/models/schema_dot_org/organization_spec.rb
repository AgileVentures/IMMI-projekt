require 'rails_helper'


RSpec.describe SchemaDotOrg::Organization, type: :model do

  let(:complete_company) {
    o               = described_class.new
    o.name          = 'org1'
    o.description   = 'description1'
    o.url           = 'https:/org1/'
    o.email         = 'org1@example.com'
    o.memberOf      = 'Sverigeshundföretagare'
    o.knowsLanguage = 'sv-SE'
    o.telephone     = '134 948494 01'
    o.location      = '12345 TBD Address'
    o.image         = 'https://example.com/some-image.jpg'
    o
  }


  it '_to_json_struct' do
    expect(complete_company._to_json_struct).to eq({"@type" => "Organization",
                                                       "description"   => "description1",
                                                       "email"         => "org1@example.com",
                                                       "image"         => "https://example.com/some-image.jpg",
                                                       "memberOf"      => "Sverigeshundföretagare",
                                                       "knowsLanguage" => "sv-SE",
                                                       "location"      => "12345 TBD Address",
                                                       "name"          => "org1",
                                                       "telephone"     => "134 948494 01",
                                                       "url"           => "https:/org1/"
                                                   })
  end

  describe 'to_ld_json' do

    it 'has a location' do
      to_ld_json   = complete_company.to_ld_json
      script_start = /<script type="application\/ld\+json">(\s)*/
      script_end   = /(\s)*<\/script>/
      expect(to_ld_json).to match(script_start)
      expect(to_ld_json).to match(script_end)

      ld_json_hash_str = to_ld_json.sub(script_start, '').sub(script_end, '')
      ld_json_hash     = JSON.parse(ld_json_hash_str)

      # convert to a Hash because the order might be different
      expect(ld_json_hash).to eq({ "@context"      => "http://schema.org",
                                   "@type"         => "Organization",
                                   "@id"           => "https:/org1/",
                                   "name"          => "org1",
                                   "description"   => "description1",
                                   "url"           => "https:/org1/",
                                   "email"         => "org1@example.com",
                                   "memberOf"      => "Sverigeshundföretagare",
                                   "knowsLanguage" => "sv-SE",
                                   "telephone"     => "134 948494 01",
                                   "location"      => "12345 TBD Address",
                                   "image"         => "https://example.com/some-image.jpg" })
    end


    it 'no location' do

      co_no_address               = described_class.new
      co_no_address.name          = 'org1'
      co_no_address.description   = 'description1'
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
                                   "@type"         => "Organization",
                                   "@id"           => "https:/org1/",
                                   "name"          => "org1",
                                   "description"   => "description1",
                                   "url"           => "https:/org1/",
                                   "email"         => "org1@example.com",
                                   "memberOf"      => "Sverigeshundföretagare",
                                   "knowsLanguage" => "sv-SE",
                                   "telephone"     => "134 948494 01",
                                   "image"         => "https://example.com/some-image.jpg" })
    end

  end

end
