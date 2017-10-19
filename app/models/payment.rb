class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :company, optional: true # used for branding_fee

  validates_presence_of :user, :payment_type, :status
end
