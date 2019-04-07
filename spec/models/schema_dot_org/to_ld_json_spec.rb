require 'rails_helper'


class SchemaDotOrg::TestJsonLd

  include SchemaDotOrg::ToLdJson


  def url
    'this is the url'
  end


  def _to_json_struct
    { '_to_json_struct': '_to_json_struct value',
      'nil value':       nil
    }
  end
end

class TestMissingMethods
  include SchemaDotOrg::ToLdJson
end


RSpec.describe SchemaDotOrg::ToLdJson do


  let(:test_json_ld) { SchemaDotOrg::TestJsonLd.new }
  let(:to_json_result) { Regexp.new('{"@context":"http://schema.org","@type":"TestJsonLd","@id":"this is the url","_to_json_struct":"_to_json_struct value"}') }

  let(:missing_to_json_struct) { TestMissingMethods.new }

  describe 'to_ld_json' do

    let(:to_json_ld_start) { Regexp.new('^<script type="application\/ld\+json">') }
    let(:to_json_ld_end) { Regexp.new('<\/script>$') }


    it "starts with '<script type=\"application/ld+json\">'" do
      expect(test_json_ld.to_ld_json).to match(to_json_ld_start)
    end

    it "ends with '</script>'" do
      expect(test_json_ld.to_ld_json).to match(to_json_ld_end)
    end

    it 'the middle is :to_json with root == true' do
      expect(test_json_ld.to_ld_json).to match(to_json_result)
    end

  end


  describe 'to_json' do

    it 'starts with  "@context" => "http://schema.org"' do
      expect(test_json_ld.to_json).to match(Regexp.new(to_json_result))
    end


    describe 'sets @id to self.url if responds_to? :url' do

      context 'does not respond_to? :url' do

        it '@id' do
          allow(missing_to_json_struct).to receive(:_to_json_struct).and_return({})
          expect(missing_to_json_struct.to_json).to eq("{\"@context\":\"http://schema.org\",\"@type\":\"TestMissingMethods\"}")
        end
      end


      context 'respond_to? :url is true' do

        it 'calls :url to get the value for @id' do
          expect(test_json_ld).to receive(:url).and_call_original
          test_json_ld.to_json
        end
      end


      it 'subclass overrides :url' do

        class TestOverridesUrlMethod < SchemaDotOrg::TestJsonLd

          def url
            'this is different in the subclass'
          end
        end

        test_overrides_url = TestOverridesUrlMethod.new
        expect(test_overrides_url).to receive(:url).and_call_original
        test_overrides_url.to_json

      end

    end
  end


  describe 'to_json_sub' do
    it 'does not have @context...' do
      expect(test_json_ld.to_json_sub).to match(/^{"@type":"TestJsonLd"/)
    end
  end

  describe 'to_json_struct' do

    it 'uses the class name as the @type with no leading <module>::' do
      expect(test_json_ld.to_json_struct).to include("@type" => 'TestJsonLd')
    end

    it 'does not include nil Hash values' do
      expect(test_json_ld.to_json_struct).not_to include(:'nil value')
    end

    it 'calls _to_json_struct for rest of the Hash content' do
      expect(test_json_ld).to receive(:_to_json_struct).and_call_original
      test_json_ld.to_json_struct
    end
  end


  describe '_to_json_struct' do

    it 'subclasses must implement' do
      expect { missing_to_json_struct._to_json_struct }.to raise_exception NoMethodError
    end

  end

end
