require 'rails_helper'


RSpec.describe SchemaDotOrg::Thing, type: :model do

  let(:thing1) {
    thing             = described_class.new
    thing.name        = 'thing1'
    thing.description = 'description1'
    thing.url         = 'https:/thing1/'
    thing
  }

  let(:sub_thing) {
    sub_t             = described_class.new
    sub_t.name        = 'sub-t'
    sub_t.description = 'sub-t desc'
    sub_t
  }

  describe 'validations' do
    it { is_expected.to(validate_presence_of :name) }
  end


  describe '_to_json_struct' do

    it 'values for simple attributes' do
      expect(thing1._to_json_struct).to eq({ "@type"       => "Thing",
                                             'description' => 'description1',
                                             'name'        => 'thing1',
                                             'url'         => 'https:/thing1/' })
    end


    describe 'does not include entries if value is nil' do

      it 'name is nil' do
        thing1.name = nil
        expect(thing1._to_json_struct).to eq({ "@type"       => "Thing",
                                               'description' => 'description1',
                                               'url'         => 'https:/thing1/' })
      end

      it 'everything is nil' do
        thing1.name        = nil
        thing1.description = nil
        thing1.url         = nil
        expect(thing1._to_json_struct).to eq({ "@type" => "Thing" })
      end
    end


    describe 'sends .to_json_struct to get the value if an item responds to :to_json_struct' do

      it 'does not respond to :to_json_struct' do
        thing             = described_class.new
        thing.name        = 'thing1'
        thing.description = [1, 2, 3]

        expect(thing._to_json_struct).to eq({ "@type" => "Thing", "description" => [1, 2, 3], "name" => "thing1" })
      end

      it 'does respond to :to_json_struct' do
        thing             = described_class.new
        thing.name        = 'thing1'
        thing.description = sub_thing
        expect(thing._to_json_struct).to eq({ "@type"       => "Thing",
                                              "description" => { "@type" => "Thing", "description" => "sub-t desc", "name" => "sub-t" },
                                              "name"        => "thing1" })
      end
    end


    describe 'loops thru lists and gets the json for each' do


      let(:sub_b) { ['b', 'B', 'bb'] }
      let(:sub_a) { ['A', sub_b, sub_thing] }

      let(:simple_list) { [1, 2, 3, 'z'] }

      # We make the name and description lists.  Which is weird,
      # but exercises the functionality.
      let(:thing2) {
        thing             = described_class.new
        thing.name        = simple_list
        thing.description = [sub_a, 9, 8, 7]
        thing.url         = 'https:/thing2/'
        thing
      }

      it 'lists are recursed down into' do
        expect(thing2._to_json_struct['@type']).to eq 'Thing'
        expect(thing2._to_json_struct['name']).to match_array([1, 2, 3, 'z'])
        expect(thing2._to_json_struct['description']).to match_array([["A",
                                                                       ["b", "B", "bb"],
                                                                       { "name"        => "sub-t",
                                                                         "description" => "sub-t desc" }
                                                                      ],
                                                                      9, 8, 7])
        expect(thing2._to_json_struct['url']).to eq 'https:/thing2/'
      end
    end

  end


  # This test isn't necessary.  But it's good to know it all works.
  describe 'to_ld_json' do

    it 'values for all attributes' do
      expect(thing1.to_ld_json).to eq "<script type=\"application/ld+json\">\n{" +
                                          "\"@context\":\"http://schema.org\"," +
                                          "\"@type\":\"Thing\"," +
                                          "\"@id\":\"https:/thing1/\"," +
                                          "\"name\":\"thing1\"," +
                                          "\"description\":\"description1\"," +
                                          "\"url\":\"https:/thing1/\"" +
                                          "}\n</script>"
    end

    it 'name is nil' do
      thing1.name = nil
      expect(thing1.to_ld_json).to eq "<script type=\"application/ld+json\">\n{" +
                                          "\"@context\":\"http://schema.org\"," +
                                          "\"@type\":\"Thing\"," +
                                          "\"@id\":\"https:/thing1/\"," +
                                          "\"description\":\"description1\"," +
                                          "\"url\":\"https:/thing1/\"" +
                                          "}\n</script>"
    end

    it 'everything is nil' do
      thing1.name        = nil
      thing1.description = nil
      thing1.url         = nil
      expect(thing1.to_ld_json).to eq "<script type=\"application/ld+json\">\n{" +
                                          "\"@context\":\"http://schema.org\"," +
                                          "\"@type\":\"Thing\"" +
                                          "}\n</script>"
    end

  end

end
