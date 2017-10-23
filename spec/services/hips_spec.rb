require 'rails_helper'

require_relative(File.join(__dir__, '..', '..', 'app','services','hips'))

RSpec.describe HipsService do
  let(:nil_urls) { {success: nil, error: nil, webhook: nil} }
  let(:invalid_type) do
    described_class.create_order(1, 1, 1, 'invalid_payment_type', nil_urls)
  end

  let(:valid_order) do
    described_class.create_order(1, 1, 1, 'member_fee', nil_urls)
  end

  let(:invalid_key) do
    HIPS_PRIVATE_KEY = '123'
  end

  let(:fetched_order) do
    described_class.get_order(valid_order['id'])
  end

  let(:valid_jwt_payload) do
    file = File.new('spec/fixtures/hips_service/jason_web_token.txt')
    jwt = file.read
    described_class.validate_webhook_origin(jwt)
  end

  let(:token_bad_issuer) do
    file = File.new('spec/fixtures/hips_service/token_bad_issuer.yaml')
    YAML.load(file.read)
  end

  let(:token_bad_algo) do
    file = File.new('spec/fixtures/hips_service/token_bad_algo.yaml')
    YAML.load(file.read)
  end

  describe '.create_order', :vcr do
    it 'raises exception if invalid payment_type' do
      expect { invalid_type }.to raise_exception RuntimeError
    end

    it 'returns parsed response if successful' do
      expect(valid_order).to be_instance_of(Hash)
      expect(valid_order['merchant_reference']['order_id']).to eq '1'
      expect(valid_order['status']).to eq 'pending'
      expect(valid_order['cart']['total_amount']).to eq SHF_MEMBER_FEE
    end

    it 'raises exception if unsuccessful' do
      invalid_key
      expect { valid_order }.to raise_exception(RuntimeError,
                                                'HTTP Status: 401, Unauthorized')
    end
  end

  describe '.get_order', :vcr do
    it 'returns parsed response if successful' do
      fetched_order
      expect(fetched_order).to be_instance_of(Hash)
      expect(fetched_order['id']).to eq valid_order['id']
      expect(fetched_order['merchant_reference']['order_id']).to eq '1'
    end

    it 'raises exception if unsuccessful' do
      invalid_key
      expect { fetched_order }.to raise_exception(RuntimeError,
                                                  'HTTP Status: 401, Unauthorized')
    end
  end

  describe '.validate_webhook_origin' do
    it 'returns resource data for valid jason_web_token' do
      expect(valid_jwt_payload).to be_instance_of(Hash)
    end

    it 'raises exception if not expected issuer' do
      allow(JWT).to receive(:decode).and_return(token_bad_issuer)
      expect { described_class.validate_webhook_origin('123') }
        .to raise_exception(RuntimeError, 'JWT issuer not HIPS')
    end

    it 'raises exception if not expected algorythm' do
      allow(JWT).to receive(:decode).and_return(token_bad_algo)
      expect { described_class.validate_webhook_origin('123') }
        .to raise_exception(RuntimeError, 'JWT wrong algorythm')
    end
  end
end
