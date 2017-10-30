# Interface to HIPS service API
# https://static.hips.com/doc/api/index.html?shell#introduction
class HipsService
  require 'httparty'

  SUCCESS_CODES = [200, 201, 202].freeze

  JWT_ALGORITHM = 'RS256'
  JWT_ISSUER = 'hips.com'

  def self.create_order(user_id, session_id, payment_data, urls)

    raise 'Invalid payment type' unless
      payment_data[:type] == Payment::PAYMENT_TYPE_MEMBER ||
      payment_data[:type] == Payment::PAYMENT_TYPE_BRANDING

    item_price = payment_data[:type] == Payment::PAYMENT_TYPE_MEMBER ?
      SHF_MEMBER_FEE : SHF_BRANDING_FEE

    response = HTTParty.post(HIPS_ORDERS_URL,
                  headers: { 'Authorization' => "Token token=#{HIPS_PRIVATE_KEY}",
                             'Content-Type' => 'application/json' },
                  debug_output: $stdout,
                  body: order_json(user_id, session_id, payment_data,
                                   item_price, urls))

    parsed_response = response.parsed_response

    return parsed_response if SUCCESS_CODES.include?(response.code)

    error = parsed_response['error']

    # Wrap cause exception within HTTP error exception so both appear in log
    begin
      raise "Error: #{error['type']}, #{error['message']}"
    rescue RuntimeError
      raise "HTTP Status: #{response.code}, #{response.message}"
    end
  end

  def self.get_order(hips_id)

    url = HIPS_ORDERS_URL + "#{hips_id}"
    response = HTTParty.get(url,
                  headers: { 'Authorization' => "Token token=#{HIPS_PRIVATE_KEY}",
                             'Content-Type' => 'application/json' },
                  debug_output: $stdout)

    return response.parsed_response if SUCCESS_CODES.include?(response.code)

    begin
      raise "Error: #{error['type']}, #{error['message']}"
    rescue RuntimeError
      raise "HTTP Status: #{response.code}, #{response.message}"
    end
  end

  def self.validate_webhook_origin(jwt)
    token = JWT.decode(jwt, HIPS_RSA_KEY, true, algorithm: JWT_ALGORITHM)

    raise 'JWT issuer not HIPS' unless token[0]['iss'] == JWT_ISSUER

    raise 'JWT wrong algorithm' unless token[1]['alg'] == JWT_ALGORITHM

    token[0]['data']['resource']
  end

  private_class_method def self.order_json(user_id, session_id,
                                           payment_data, item_price, urls)

    { order_id: payment_data[:id],
      purchase_currency: payment_data[:currency],
      user_session_id: session_id,
      user_identifier: user_id,
      fulfill: true,
      require_shipping: false,
      hooks: {
                user_return_url_on_success: urls[:success],
                user_return_url_on_fail: urls[:error],
                webhook_url: urls[:webhook]
             },
      cart: {
              items: [ {
                          type: 'fee',
                          sku: payment_data[:type],
                          name: payment_data[:type],
                          quantity: 1,
                          unit_price: item_price
                        }
                      ]
            }
    }.to_json
  end
end
