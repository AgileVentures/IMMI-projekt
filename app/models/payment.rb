class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :company, optional: true # used for branding_fee

  validates_presence_of :user, :payment_type, :status

  ORDER_PAYMENT_STATUS = {
    nil          => 'skapad',  # created
    'pending'    => 'avvaktan',
    'successful' => 'betald',   # paid
    'expired'    => 'utgånget',
    'awaiting_payments' => 'väntar på betalningar'
  }.freeze

  validates :status, inclusion: ORDER_PAYMENT_STATUS.values

  def self.order_to_payment_status(order_status)
    ORDER_PAYMENT_STATUS.fetch(order_status, 'unknown')
  end
end
