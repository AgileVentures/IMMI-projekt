class MembershipApplication < ApplicationRecord
  belongs_to :user
  validates_presence_of :company_name,
                        :company_number,
                        :company_email,
                        :contact_person,
                        :status
  validates_length_of :company_number, is: 10
  validates_format_of :company_email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: [:create, :update]

end
