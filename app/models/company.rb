class Company < ApplicationRecord
  validates_presence_of :company_number
  validates_length_of :company_number, is: 10
end
