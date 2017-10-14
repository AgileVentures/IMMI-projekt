class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :company, optional: true # used for branding_fee

  validates_presence_of :user, :payment_type, :status

  STATUS = { NEW:     'User initiated payment',
             PENDING: 'HIPS order pending',
             WAITING: 'HIPS order awaiting payment',
             EXPIRED: 'HIPS order expired',
             PAID:    'HIPS order successful' }

  validates :status, inclusion: STATUS.values
end
