class CompanyApplication < ApplicationRecord
  belongs_to :company
  belongs_to :shf_application

  validates_presence_of :company, :shf_application

  validates_uniqueness_of :company_id, scope: :shf_application
end
