require_relative File.join('..', 'services', 'address_exporter')


class Company < ApplicationRecord
  include PaymentUtility

  include HasSwedishOrganization

  include Dinkurs::Errors

  before_destroy :destroy_checks

  validates_presence_of :company_number
  validates_uniqueness_of :company_number,
    message: I18n.t('activerecord.errors.models.company.attributes.company_number.taken')
  validates_length_of :company_number, is: 10
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: [:create, :update]
  validate :swedish_organisationsnummer

  before_save :sanitize_website, :sanitize_description

  has_many :company_applications
  has_many :shf_applications, through: :company_applications, dependent: :destroy

  has_many :users, through: :shf_applications
  has_many :events, dependent: :destroy

  has_many :payments, dependent: :destroy
  accepts_nested_attributes_for :payments

  has_many :business_categories, through: :shf_applications

  has_many :addresses, as: :addressable, dependent: :destroy,
           inverse_of: :addressable
  # ^^ we add the "inverse_of" option because we are validating the presence of
  # a company parent instance when we save the associated address(es).
  # See section "Validating the presence of a parent model" here:
  # https://apidock.com/rails/ActiveRecord/NestedAttributes/
  #     ClassMethods#971-Validating-presence-of-parent-in-child

  has_many :pictures, class_name: 'Ckeditor::Picture', dependent: :destroy

  accepts_nested_attributes_for :addresses, allow_destroy: true
  alias_method :categories, :business_categories
  delegate :visible, to: :addresses, prefix: true

  def approved_applications_from_members
    # Returns ActiveRecord Relation
    shf_applications.accepted.includes(:user)
      .order('users.last_name').where('users.member = ?', true)
  end

  def validate_key_and_fetch_dinkurs_events(on_update: true)
    return true if on_update and !will_save_change_to_attribute?('dinkurs_company_id')
    fetch_dinkurs_events
    true
  rescue Dinkurs::Errors::InvalidKey
    errors.add(:dinkurs_company_id, :invalid)
    return false
  end

  def fetch_dinkurs_events
    events.clear
    return if dinkurs_company_id.blank?
    Dinkurs::EventsCreator.new(self, events_start_date).call
  end

  def events_start_date
    # Fetch events that start on or after this date
    1.day.ago.to_date
  end

  def any_visible_addresses?
    addresses_visible.any?
  end

  def categories_names
    categories.select(:name).distinct.order(:name).pluck(:name)
  end

  def addresses_region_names
    addresses.joins(:region).select('regions.name').distinct.pluck('regions.name')
  end

  def kommuns_names
    addresses.joins(:kommun).select('kommuns.name').distinct.pluck('kommuns.name')
  end

  def most_recent_branding_payment
    most_recent_payment(Payment::PAYMENT_TYPE_BRANDING)
  end

  def branding_expire_date
    payment_expire_date(Payment::PAYMENT_TYPE_BRANDING)
  end

  def branding_payment_notes
    payment_notes(Payment::PAYMENT_TYPE_BRANDING)
  end

  def branding_license?
    branding_expire_date&.future?
  end

  def self.next_branding_payment_dates(company_id)
    next_payment_dates(company_id, Payment::PAYMENT_TYPE_BRANDING)
  end


  # All addresses for a company are complete AND the name is not blank
  # must qualify name with 'companies' because there are other tables that use 'name' and if
  # this scope is combined with a clause for a different table that also uses 'name',
  # SQL won't know which table to get 'name' from
  #  name could be NULL or it could be an empty string
  def self.complete
    where.not('companies.name' => '',
              id: Address.lacking_region.pluck(:addressable_id))
  end

  def self.branding_licensed
    # All companies (distinct) with at least one unexpired branding payment
    joins(:payments).merge(Payment.branding_fee.completed.unexpired).distinct
  end

  def self.address_visible
    # Return ActiveRecord::Relation object for all companies (distinct) with at
    # least one visible address
    joins(:addresses).where.not('addresses.visibility = ?', 'none').distinct
  end

  def self.with_members
    joins(:shf_applications)
      .where('shf_applications.state = ?', :accepted)
      .joins(:users).where('users.member = ?', true).distinct
  end

  def self.searchable
    # Criteria limiting visibility of companies to non-admin users
    complete.with_members.branding_licensed
  end

  def destroy_checks

    error_if_has_applications?

  end


  # do not delete a Company if it has ShfApplications that are accepted
  def error_if_has_applications?
    shf_applications.reload

    if shf_applications.where.not(state: 'being_destroyed').any?
      errors.add(:base, 'activerecord.errors.models.company.attributes.company_has_active_memberships')
      # Rails 5: must throw
      throw(:abort)
    end

    true

  end


  def main_address

    return addresses.mail_address.includes(:region)[0] if addresses.mail_address.exists?

    return addresses.includes(:region).first if addresses.exists?

    new_address = Address.new(addressable: self)
    addresses << new_address
    new_address
  end


  def se_mailing_csv_str
      AddressExporter.se_mailing_csv_str( main_address )
  end


  private


  # clean the value for the website so we don't store potential XSS
  #  strip out anything that might start with 'script' (like 'javascript')
  #  to help prevent XSS attacks
  def sanitize_website
    self.website = InputSanitizer.sanitize_url(website)
  end

  def sanitize_description
    self.description = InputSanitizer.sanitize_html(description)
  end

end
