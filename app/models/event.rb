class Event < ApplicationRecord
  has_one :address, as: :addressable
  belongs_to :company
end
