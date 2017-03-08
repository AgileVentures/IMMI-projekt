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

  has_many :addresses, as: :addressable, dependent: :destroy

  accepts_nested_attributes_for :addresses, allow_destroy: true


  # All addresses for a company are complete AND the name is not blank
  # must qualify name with 'company' because there are other tables that use 'name' and if
  # this scope is combined with a clause for a different table that also uses 'name',
  # SQL won't know which table to get 'name' from
  #  name could be NULL or it could be an empty string

  def self.complete

    have_no_regions = Address.lacking_region.where(addressable_type: 'Company').distinct.pluck(:addressable_id)

    if have_no_regions.count > 0
      where('"companies"."name" <> :blank_name AND "companies"."id" NOT IN (:address_lacking_region)',
            { blank_name: '',
             address_lacking_region: have_no_regions })
    else
      where('"companies"."name" <> ? ', '' )
    end

  end


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

  def main_address
    addresses.first
  end


end
