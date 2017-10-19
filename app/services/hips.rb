# Interface to HIPS service API
class HipsService
  require 'httparty'

  SUCCESS_CODES = [200, 201, 202].freeze

  def self.create_order(payment_id, user_id, session_id, payment_type,
                        success_url, error_url, currency = 'SEK')

    raise 'Invalid payment type' unless payment_type == 'member_fee' ||
                                        payment_type == 'branding_fee'

    item_price = payment_type == 'member_fee' ? SHF_MEMBER_FEE : SHF_BRANDING_FEE

    response = HTTParty.post(HIPS_ORDERS_URL,
                  headers: { 'Authorization' => "Token token=#{HIPS_PRIVATE_KEY}",
                             'Content-Type' => 'application/json' },
                  debug_output: $stdout,
                  body: order_json(payment_id, user_id, session_id,
                                   payment_type, item_price, currency,
                                   success_url, error_url))

    return response.parsed_response if SUCCESS_CODES.include?(response.code)

    raise "HTTP Status: #{response.code}, #{response.message}"
  end

  def self.get_order(hips_id)

    url = HIPS_ORDERS_URL + "#{hips_id}"
    response = HTTParty.get(url,
                  headers: { 'Authorization' => "Token token=#{HIPS_PRIVATE_KEY}",
                             'Content-Type' => 'application/json' },
                  debug_output: $stdout)

    return response.parsed_response if SUCCESS_CODES.include?(response.code)

    raise "HTTP Status: #{response.code}, #{response.message}"
  end

  private_class_method def self.order_json(payment_id, user_id, session_id,
                                           payment_type, item_price, currency,
                                           success_url, error_url)

    { order_id: payment_id,
      purchase_currency: currency,
      user_session_id: session_id,
      user_identifier: user_id,
      fulfill: true,
      require_shipping: false,
      hooks: {
                user_return_url_on_success: success_url,
                user_return_url_on_fail: error_url
             },
      cart: {
              items: [ {
                          type: 'fee',
                          sku: payment_type,
                          name: payment_type,
                          quantity: 1,
                          unit_price: item_price
                        }
                      ]
            }
    }.to_json
  end
end
