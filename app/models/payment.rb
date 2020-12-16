require 'observer'

class Payment < ApplicationRecord

  include Observable
  include UpdatedAtRange

  after_initialize :add_observers
  #  before_destroy :delete_observers  # TODO is this needed?


  belongs_to :user
  belongs_to :company, optional: true # used for branding_fee

  validates_presence_of :user, :payment_type, :status, :start_date, :expire_date
  validates_presence_of :hips_id, on: :update

  PAYMENT_TYPE_MEMBER   = 'member_fee'
  PAYMENT_TYPE_BRANDING = 'branding_fee'

  NOTES_DEFAULT_PAYOR = 'User'
  NOTES_UNKNOWN_EMAIL = '<email unknown>'
  NOTES_SEPARATOR = '; '  unless defined?(NOTES_SEPARATOR)


  # This hash maps a HIPS order status to an SHF payment status.
  # The payment values are stored in the DB and exposed to the user.
  # (The user is paying a fee to SHF (payment).  In order to process that
  #  payment, we create a HIPS order and pass that to HIPS, which then
  #  processes that order (that is, has the user pay for the order).
  #  Note that here, "payment" refers to the SHF Payment, and "order" to
  #  the HIPS order).
  # Note that successful order payment (on the HIPS side) is represented by
  # order status 'successful'.  On the SHF side, that translates to a
  # completed payment ('paid') for the user fee (e.g. a membership fee).
  ORDER_PAYMENT_STATUS = {
    nil          => 'skapad',  # created
    'pending'    => 'avvaktan',
    'successful' => 'betald',   # paid
    'expired'    => 'utgånget',
    'awaiting_payments' => 'Väntar på betalning' # awaiting payment
  }.freeze

  CREATED = ORDER_PAYMENT_STATUS[nil]
  PENDING = ORDER_PAYMENT_STATUS['pending']
  SUCCESSFUL = ORDER_PAYMENT_STATUS['successful']
  EXPIRED = ORDER_PAYMENT_STATUS['expired']
  AWAITING_PAYMENTS = ORDER_PAYMENT_STATUS['awaiting_payments']


  NO_HIPS_ID = 'none'

  UNKNOWN_ORDER_STATUS = 'unknown'


  validates :status, inclusion: ORDER_PAYMENT_STATUS.values

  scope :completed, -> { where(status: SUCCESSFUL) }

  scope :unexpired, -> { where('expire_date >= ?', Time.zone.today ) }

  scope PAYMENT_TYPE_MEMBER.to_sym, -> { where(payment_type: PAYMENT_TYPE_MEMBER) }

  scope PAYMENT_TYPE_BRANDING.to_sym, -> { where(payment_type: PAYMENT_TYPE_BRANDING) }

  after_update :clear_proof_of_membership_image_cache,
               if: Proc.new { saved_change_to_expire_date? }

  def clear_proof_of_membership_image_cache
    user.clear_proof_of_membership_jpg_cache
  end

  def self.membership_payment_type
    PAYMENT_TYPE_MEMBER
  end

  def self.branding_license_payment_type
    PAYMENT_TYPE_BRANDING
  end


  def add_observers
    add_observer MembershipStatusUpdater.instance, :payment_made
  end


  def self.order_to_payment_status(order_status)
    ORDER_PAYMENT_STATUS.fetch(order_status, UNKNOWN_ORDER_STATUS)
  end


  # Return all Payments that cover any days in the given year
  # (used to help determine the total amount of money for all of the days in a given year)
  #
  # all payments that start in the given year OR
  # all payments that expire in the given year OR
  # (all payments that start_date < given year AND expire_date > given year)  (ex: the payment covered 3 years, including the given year)
  # This uses the by_star gem for the scopes (ex: by_year(), before(), after() )
  def self.covering_year(year)
    year_start = DateTime.new(year,1,1)
    year_end = year_start.end_of_year

    by_year(year, field: :start_date).
        or(by_year(year, field: :expire_date)).
        or(before(year_start, field: :start_date).after(year_end, field: :expire_date)).distinct
  end

  # The transaction was successful.  The transaction might depend on an external system (e.g. HIPS).
  # This method is called so we can do whatever it is we need to do
  # (e.g. set the status, notify observers, etc.).
  def successfully_completed
    self.update(status: SUCCESSFUL)
    changed
    notify_observers(self)
  end


  def note_payor_deleted(payor_type = NOTES_DEFAULT_PAYOR,
                         payor_email = NOTES_UNKNOWN_EMAIL,
                         deleted_time = Time.zone.now)
    deleted_note = "#{payor_type} #{payor_email} for this payment was deleted on #{deleted_time}"
    update(notes: (notes.nil? ? deleted_note : "#{notes}#{NOTES_SEPARATOR}#{deleted_note}") )
  end


  def membership_payment_type
    self.class.membership_payment_type  # this could also be done with delegation
  end


  def branding_license_payment_type
    self.class.branding_license_payment_type  # this could also be done with delegation
  end


  def membership_payment?
    self.payment_type == membership_payment_type
  end

  def branding_license_payment?
    self.payment_type == branding_license_payment_type
  end
end
