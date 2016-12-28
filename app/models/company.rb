class Company < ApplicationRecord

  include HasSwedishOrganization

  validates_presence_of :company_number
  validates_uniqueness_of :company_number, message: I18n.t('activerecord.errors.models.company.company_number.taken')
  validates_length_of :company_number, is: 10
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: [:create, :update]
  validate :swedish_organisationsnummer

  has_many :business_categories, through: :membership_applications

  has_many :membership_applications

  belongs_to :region

end
