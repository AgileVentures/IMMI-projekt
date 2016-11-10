class MembershipApplication < ApplicationRecord
  validates_length_of :company_number, is: 10
end
