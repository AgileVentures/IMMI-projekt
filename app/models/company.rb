class Company < ApplicationRecord

  include HasSwedishOrganization

  before_destroy :destroy_checks

  validates_presence_of :company_number
  validates_uniqueness_of :company_number, message: I18n.t('activerecord.errors.models.company.company_number.taken')
  validates_length_of :company_number, is: 10
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: [:create, :update]
  validate :swedish_organisationsnummer

  has_many :business_categories, through: :membership_applications

  has_many :membership_applications, dependent: :destroy, inverse_of: :company

  belongs_to :region

  # must qualify name with 'company' because there are other tables that use 'name' and if
  # this scope is combined with a clause for a different table that also uses 'name',
  # SQL won't know which table to get 'name' from
  #  name could be NULL or it could be an empty string
  scope :complete, -> { where('"companies"."name" <> :blank_name AND region_id IS NOT NULL',
                              { blank_name: '' }) }


  def destroy_checks

    error_if_has_accepted_applications?

  end


  # do not delete a Company if it has MembershipApplications that are accepted
  def error_if_has_accepted_applications?

    membership_applications.reload

    if membership_applications.select(&:is_accepted?).count != 0
      errors.add(:base, 'activerecord.errors.models.company.company_has_active_memberships')
      # Rails 5: must throw
      throw(:abort)
    end

    true

  end
end
