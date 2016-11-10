class MembershipApplication < ApplicationRecord
  validates_presence_of :company_name,
                        :company_number,
                        :company_email,
                        :contact_person
  validates_length_of :company_number, is: 10
end
