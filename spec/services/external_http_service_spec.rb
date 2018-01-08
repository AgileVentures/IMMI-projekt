require 'rails_helper'

require 'httparty/response'

require_relative(File.join(__dir__, '..', '..', 'app', 'services', 'external_http_service'))

# record: :new_episodes


# 'fetched_response' must contain the response. ex:
#      it_behaves_like 'a successful company events fetch' do
#           let(:fetched_response) { valid_fetched_event }
#      end
#
RSpec.shared_examples 'a successful http fetch' do

  it 'is a Hash' do
    expect(fetched_response).to be_instance_of(Hash)
  end

  it 'events is the top level' do
    expect(fetched_response.keys).to match_array(['events'])
  end


end


RSpec.describe ExternalHTTPService, :vcr do

  # use this block to ensure the response is in UTF-8 (and not ASCII which may be binary):
  VCR.configure do |c|
    c.before_record do |i|
      i.response.body.force_encoding('UTF-8')
    end
  end


  describe '.get_response' do
    # TODO - how to test this?

    it 'is a Hash' do
      #pending
    #  expect(fetched_response).to be_instance_of(Hash)
    end


  end


  it '.response_url' do
    expect { described_class.response_url(['12345']) }.to raise_error NotImplementedError, "You must define the 'response_url' class method."
  end


  describe '.response_headers' do

    it 'is an empty hash' do
      expect(described_class.response_headers).to eq Hash.new
    end
  end


  describe 'return_immediately?' do

    it 'true when response.code is a success code (200)' do
      mocked_response = double("response", code: 200)
      expect(described_class.return_immediately?(mocked_response)).to be_truthy
    end

    it 'false when response.code is not a success code (500)' do
      mocked_response = double("response", code: 500)
      expect(described_class.return_immediately?(mocked_response)).to be_falsey
    end

    it 'false when response is nil' do
      expect(described_class.return_immediately?(nil)).to be_falsey
    end

    it 'false when response.code is nil' do
      mocked_response = double("response", code: nil)
      expect(described_class.return_immediately?(mocked_response)).to be_falsey
    end

  end


  describe '.process returns the argument (child classes can do something different)' do

    it 'nil argument returns nil' do
      expect(described_class.process(nil)).to be_nil
    end

    it 'a string argument returns the string' do
      expect(described_class.process('a string argument')).to eq 'a string argument'
    end

  end


  it '.return_after_processing? returns false (child classes can do something different' do
    expect(described_class.return_after_processing?(nil)).to be_falsey
  end


  describe '.set_error use response[:error] by default; child classes can do something different' do

    it "returns the value of response['error']" do
      response = { 'error' => 'the error value' }
      expect(described_class.set_error(response)).to eq 'the error value'
    end

    it 'nil when response is nil' do
      expect(described_class.set_error(nil)).to be_nil
    end

    it "nil when response does not have 'error' key" do
      response = {}
      expect(described_class.set_error(response)).to be_nil
    end

  end

end
