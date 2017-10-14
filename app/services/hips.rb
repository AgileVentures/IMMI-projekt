# Interface to HIPS service API
class HipsService
  require 'httparty'

  def self.create_order(order_id, user_id, session_id,
                        order_type, currency = 'SEK')

    raise 'Invalid order type' unless order_type == 'member_fee' ||
                                      order_type == 'branding_fee'

    item_price = order_type == 'member_fee' ? SHF_MEMBER_FEE : SHF_BRANDING_FEE

    HTTParty.post(HIPS_ORDERS_URL,
                  headers: { 'Authorization' => "Token token=#{HIPS_PRIVATE_KEY}",
                             'Content-Type' => 'application/json' },
                  debug_output: $stdout,
                  body: order_json(order_id, user_id, session_id,
                                   order_type, item_price, currency)
    ).parsed_response
  end

  def self.order_json(order_id, user_id, session_id,
                      order_type, item_price, currency)

    { order_id: order_id,
      purchase_currency: currency,
      user_session_id: session_id,
      user_identifier: user_id,
      fulfill: true,
      require_shipping: false,
      cart: {
              items: [ {
                          type: 'fee',
                          sku: order_type,
                          name: order_type,
                          quantity: 1,
                          unit_price: item_price
                        }
                      ]

            }
    }.to_json
  end
end
