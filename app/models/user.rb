# ===============================================================================================
# @class User
#
# @responsibility  A user that can log in.  Knows membership _payment_ status,
#  application status.
#
# 2021-02-19: First step towards refactoring: have existing methods call MembershipsManager methods
#   (a kind of manual delegation).
#   TODO: should any of the methods be delegated to the MembershipsManager?
#   Next steps will be to call MembershipManager methods directly where needed.
#
# TODO: should 'expires_soon' be a membership status instead of just 'informational' ?
#
# TODO: refactor proof of membership image stuff to separate class
#
class User < ApplicationRecord
  include PaymentUtility
  include ImagesUtility
  include AASM

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_destroy :adjust_related_info_for_destroy

  after_update :clear_proof_of_membership_jpg_cache,
               if: Proc.new { saved_change_to_member_photo_file_name? ||
                 saved_change_to_first_name? ||
                 saved_change_to_last_name? ||
                 saved_change_to_membership_number? }


  has_one :shf_application, dependent: :destroy
  accepts_nested_attributes_for :shf_application, update_only: true

  has_many :uploaded_files
  accepts_nested_attributes_for :uploaded_files, allow_destroy: true

  has_many :companies, through: :shf_application

  has_many :memberships, dependent: :destroy

  has_many :payments, dependent: :nullify
  # ^^ need to retain h-branding payment(s) for any associated company that
  #    is not also deleted.
  accepts_nested_attributes_for :payments

  has_many :checklists, dependent: :destroy, class_name: 'UserChecklist'

  has_attached_file :member_photo, default_url: 'photo_unavailable.png',
                    styles: { standard: ['130x130#'] }, default_style: :standard

  validates_attachment_content_type :member_photo,
                                    content_type: /\Aimage\/.*(jpg|jpeg|png)\z/
  validates_attachment_file_name :member_photo, matches: [/png\z/, /jpe?g\z/, /PNG\z/, /JPE?G\z/]

  validates :first_name, :last_name, presence: true, unless: :updating_without_name_changes
  validates :membership_number, uniqueness: true, allow_blank: true
  validates :email, email: true


  THIS_PAYMENT_TYPE = Payment::PAYMENT_TYPE_MEMBER
  MOST_RECENT_UPLOAD_METHOD = :created_at

  scope :admins, -> { where(admin: true) }
  scope :not_admins, -> { where(admin: nil).or(User.where(admin: false)) }

  # FIXME: replace this with the aasm provided scope :current_member
  scope :members, -> { where(member: true) }

  successful_payment_with_type_and_expire_date = "payments.status = '#{Payment::SUCCESSFUL}' AND" +
    " payments.payment_type = ? AND payments.expire_date = ?"

  scope :membership_expires_in_x_days, -> (num_days) { includes(:payments)
                                                         .where(successful_payment_with_type_and_expire_date,
                                                                Payment::PAYMENT_TYPE_MEMBER,
                                                                (Date.current + num_days))
                                                         .order('payments.expire_date')
                                                         .references(:payments) }

  scope :company_hbrand_expires_in_x_days, -> (num_days) { includes(:payments)
                                                             .where(successful_payment_with_type_and_expire_date,
                                                                    Payment::PAYMENT_TYPE_BRANDING,
                                                                    (Date.current + num_days))
                                                             .order('payments.expire_date')
                                                             .references(:payments) }

  scope :application_accepted, -> { joins(:shf_application).where(shf_applications: { state: 'accepted' }) }

  scope :membership_payment_current, -> { joins(:payments).where("payments.status = '#{Payment::SUCCESSFUL}' AND payments.payment_type = ? AND  payments.expire_date > ?", Payment::PAYMENT_TYPE_MEMBER, Date.current) }

  scope :agreed_to_membership_guidelines, -> { where(id: UserChecklist.top_level_for_current_membership_guidelines.completed.pluck(:user_id)) }

  # ===============================================================================================

  # TODO this should not be the responsibility of the User class. Need a MembershipManager class for this.
  # The next membership payment date
  # FIXME find all calls, replace with appropriate Membership... class
  def self.next_membership_payment_date(user_id)
    next_membership_payment_dates(user_id).first
  end

  # TODO this should not be the responsibility of the User class. Need a MembershipManager class for this.
  # FIXME find all calls, replace with appropriate Membership... class
  def self.next_membership_payment_dates(user_id)
    next_payment_dates(user_id, THIS_PAYMENT_TYPE)
  end

  def self.clear_all_proof_of_membership_jpg_caches
    all.each do |user|
      user.clear_proof_of_membership_jpg_cache
    end
  end


  def self.most_recent_upload_method
    MOST_RECENT_UPLOAD_METHOD
  end


  # encapsulate how to get a list of all states as symbols
  def self.membership_statuses
    aasm.states.map(&:name)
  end

  # All memberships statuses _and_ 'expires_soon' ('Expires soon' is not a "real" status. It is not
  #   used to track or transition to/from statuses, but it is informative to show to admins and
  #   members.  It is just _informational_.
  def self.membership_statuses_incl_informational
    aasm.states.map(&:name) + MembershipsManager.informational_statuses
  end

  # ----------------------------------------------------------------------------------------------
  # Act As State Machine (AASM)

  aasm column: 'membership_status' do
    state :not_a_member, initial: true
    state :current_member
    state :in_grace_period
    state :former_member

    after_all_transitions :set_membership_changed_info

    # You can pass the (keyword) arguments
    #    date: <Date>
    #    send_email: [true | false]
    # to methods that are called
    # @url https://github.com/aasm/aasm#callbacks

    event :start_membership do
      transitions from: [:not_a_member, :current_member, :former_member], to: :current_member, after: Proc.new {|*args| start_membership_on(*args) }
    end

    event :renew do
      transitions from: [:current_member, :in_grace_period], to: :current_member, after: Proc.new {|*args| renew_membership_on(*args) }
    end

    event :start_grace_period do
      transitions from: :current_member, to: :in_grace_period, after: Proc.new {|*args| enter_grace_period(*args) }
    end

    event :make_former_member do
      transitions from: :in_grace_period, to: :former_member, after: Proc.new {|*args| become_former_member(*args) }
    end
  end

  # This can be used to write info to logs
  def set_membership_changed_info
    @membership_changed_info = "membership status changed from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
  end

  def membership_changed_info
    @membership_changed_info ||= ''
  end

  # ----------------------------------------------------------------------------------

  def memberships_manager
    @memberships_manager ||= MembershipsManager.new
  end

  # @return [nil | Membership] - the oldest membership that covers today (Date.current)
  #   nil if no memberships are found
  def current_membership
    memberships_manager.membership_on(self, Date.current)
  end


  # @return [nil | Membership] - the most recent membership (the current membership may have expired)
  def most_recent_membership
    memberships_manager.most_recent_membership(self)
  end

  def cache_key(type)
    "user_#{id}_cache_#{type}"
  end

  def proof_of_membership_jpg
    Rails.cache.read(cache_key('pom'))
  end

  def proof_of_membership_jpg=(image)
    Rails.cache.write(cache_key('pom'), image)
  end

  def clear_proof_of_membership_jpg_cache
    Rails.cache.delete(cache_key('pom'))
  end

  def updating_without_name_changes
    # Not a new record and not saving changes to either first or last name

    # https://github.com/rails/rails/pull/25337#issuecomment-225166796
    # ^^ Useful background

    !new_record? && !(will_save_change_to_attribute?('first_name') ||
      will_save_change_to_attribute?('last_name'))
  end

  def most_recent_membership_payment
    most_recent_payment(THIS_PAYMENT_TYPE)
  end

  # Make this a current member.
  # Do nothing if the user is already a current member.
  # If not a current member, start a membership
  # TODO: Is this used?
  def make_current_member
    start_membership_on(date: Date.current) unless current_member?
  end


  def start_membership_on(date: Date.current, send_email: true)
    Memberships::NewIndividualMembershipActions.for_user(self, first_day: date, send_email: send_email)
  end


  def renew_membership_on(date: Date.current, send_email: true)
     Memberships::RenewIndividualMembershipActions.for_user(self, first_day: date, send_email: send_email)
  end


  def enter_grace_period(date: Date.current, send_email: true)
    Memberships::IndividualMembershipEnterGracePeriodActions.for_user(self, first_day: date, send_email: send_email)
  end


  def become_former_member(date: Date.current, send_email: true)
    Memberships::BecomeFormerIndividualMemberActions.for_user(self, first_day: date, send_email: send_email)
  end


  # Returns the first day of the most recent membership, where "most recent" means
  #  the one that is current
  def membership_start_date
    memberships_manager.most_recent_membership_first_day(self)
    # payment_start_date(THIS_PAYMENT_TYPE)
  end
  alias_method :membership_first_day, :membership_start_date


  # Returns the last day of the most recent membership, where "most recent" means
  #  the one that is current
  def membership_expire_date
    memberships_manager.most_recent_membership_last_day(self)
    # payment_expire_date(THIS_PAYMENT_TYPE)
  end
  alias_method :membership_last_day, :membership_expire_date

  # TODO this should not be the responsibility of the User class. Need a MembershipManager class for this.
  # FIXME change calls to either payment_notes or current_membership.notes
  def membership_payment_notes
    payment_notes(THIS_PAYMENT_TYPE)
  end


  def member_in_good_standing?(date = Date.current)
    RequirementsForMembership.requirements_met?(user: self, date: date)
  end


  # TODO this should not be the responsibility of the User class. Need a MembershipManager class for this.
  # FIXME - this is ONLY about the payments, not the membership status as a whole.
  #   so the name should be changed.  ex: membership_payments_current?  or membership_payment_term....
  def membership_current?
    # TODO can use payment_term_expired?(THIS_PAYMENT_TYPE)
    !!membership_expire_date&.future? # using '!!' will turn a nil into false
  end

  alias_method :payments_current?, :membership_current?


  def membership_expires_soon?(this_membership = most_recent_membership)
    memberships_manager.expires_soon?(self, this_membership)
  end


  # TODO this should not be the responsibility of the User class. Need a MembershipManager class for this.
  def payments_current_as_of?(this_date)
    return false if this_date.nil?

    membership_payment_expire_date = payment_expire_date(THIS_PAYMENT_TYPE)
    !membership_payment_expire_date.nil? && (membership_payment_expire_date > this_date)
  end



  # The membership term has expired, but are they still within a 'grace period'?
  def membership_expired_in_grace_period?(this_date = Date.current)
    memberships_manager.membership_in_grace_period?(self, this_date)
  end

  # the date is after the renewal grace period;
  def membership_past_grace_period_end?(this_date = Date.current)
    memberships_manager.date_after_grace_period_end?(self, this_date)
  end


  # @return [Symbol] - the membership status.
  # If the membership status is current AND the given Date
  # is on or after the date that it expires soon, return the informational status 'expires_soon'
  #
  def membership_status_incl_informational(this_membership = most_recent_membership)
    if membership_expires_soon?(this_membership)
      MembershipsManager.expires_soon_status
    else
      membership_status
    end
  end


  def today_is_valid_renewal_date?
    memberships_manager.today_is_valid_renewal_date?(self)
  end


  def valid_date_for_renewal?(this_date = Date.current)
    memberships_manager.valid_renewal_date?(self, this_date)
  end




  # Business rule: user can pay membership fee if:
  # 1. the user is not the admin (an admin cannot make a payment for a member or user)
  #      AND
  # 2. the user is a current member OR user was a current member and is still in the grace period for renewing)
  #       and they are allowed to pay the renewal membership fee
  #    OR
  #    the user has is allowed to pay the new membership fee
  #
  def allowed_to_pay_member_fee?
    return false if admin?

    if current_member? || in_grace_period?
      allowed_to_pay_renewal_member_fee?
    else
      allowed_to_pay_new_membership_fee?
    end
  end

  # A user can pay a renewal membership fee if
  #   they are a current member OR are within the renewal grace period
  #   AND they have met all of the requirements for renewing,
  #     excluding any payment required.
  def allowed_to_pay_renewal_member_fee?
    return false if admin?

    (current_member? || in_grace_period?) &&
      RequirementsForRenewal.requirements_excluding_payments_met?(self)
  end

  # A user can pay a (new) membership fee if:
  #   they are not a member OR they are a former member
  #   AND they have met all of the requirements for membership,
  #     excluding any payment required.
  def allowed_to_pay_new_membership_fee?
    return false if admin?

    (not_a_member? || former_member?) &&
      RequirementsForMembership.requirements_excluding_payments_met?(self)
  end

  # Business rule: user can pay h-brand license fee if:
  # 1. user is an admin
  # OR
  # 2. user is a member AND user is in the company
  #
  # TODO this should not be the responsibility of the User class. Need a MembershipManager class for this.
  #
  # @return [Boolean]
  def allowed_to_pay_hbrand_fee?(company)
    admin? || in_company?(company) #|| has_approved_app_for_company?(company)
  end

  def member_fee_payment_due?
    member? && !payments_current?
  end

  def has_shf_application?
    !!shf_application&.valid?
  end

  def has_approved_shf_application?
    !!shf_application&.accepted?
  end

  def member_or_admin?
    admin? || member?
  end

  def has_company_in_good_standing?
    companies.select(&:in_good_standing?).any?
  end

  def in_company?(company)
    in_company_numbered?(company.company_number)
  end

  def in_company_numbered?(company_num)
    current_member? && has_approved_app_for_company_number?(company_num)
  end

  def companies_with_approved_app
    companies.select { |co| has_approved_app_for_company?(co) }
  end

  def has_approved_app_for_company?(company)
    has_approved_app_for_company_number?(company.company_number)
  end

  def has_approved_app_for_company_number?(company_num)
   Company.find_by(company_number: company_num).accepted_applicants.include?(self)
  end

  # TODO this currently only checks the one ShfApplication that the user can have; must modify when user can have 1+ apps
  def has_app_for_company?(company)
    has_app_for_company_number?(company.company_number)
  end

  def has_app_for_company_number?(company_num)
    apps_for_company_number(company_num)&.any?
  end

  # @return [Array] all shf_applications that contain the company, sorted by the application with the expire_date furthest in the future
  # TODO this currently only checks the one ShfApplication that the user can have; must modify when user can have 1+ apps
  def apps_for_company(company)
    apps_for_company_number(company.company_number)
  end

  # @return [Array] all shf_applications that contain a company with the company_num, sorted by the application with the expire_date furthest in the future
  #   Note that right now a User can have only 1 ShfApplication, but in the future
  #   if a User can have more than 1, we want to be sure they are sorted by expire_date with the
  #    expire_date in the future as the first one and the expire_date in the past as the last one
  # TODO this currently only checks the one ShfApplication that the user can have; must modify when user can have 1+ apps
  def apps_for_company_number(company_num)
    result = shf_application&.companies&.find_by(company_number: company_num)
    result.nil? ? [] : [shf_application].sort(&sort_apps_by_when_approved)
  end

  SORT_BY_MOST_RECENT_APPROVED_DATE = lambda { |app1, app2| app2.when_approved <=> app1.when_approved }

  # @return [Lambda] - the block (lambda) to use to sort shf_applications by the when_approved date
  def sort_apps_by_when_approved
    SORT_BY_MOST_RECENT_APPROVED_DATE
  end

  def membership_guidelines_checklist_done?
    RequirementsForMembership.membership_guidelines_checklist_done?(self)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def has_full_name?
    first_name.present? && last_name.present?
  end

  ransacker :padded_membership_number do
    Arel.sql("lpad(membership_number, 20, '0')")
  end

  def get_short_proof_of_membership_url(url)
    found = self.short_proof_of_membership_url
    return found if found
    short_url = ShortenUrl.short(url)
    if short_url
      self.update_attribute(:short_proof_of_membership_url, short_url)
      short_url
    else
      url
    end
  end

  def membership_packet_sent?
    !date_membership_packet_sent.nil?
  end

  # Toggle whether or not a membership package was sent to this user.
  #
  # If the old value was "true", now set it to false.
  # If the old value was "false", now make it true and set the date sent
  #
  # @param date_sent [Time] - when the packet was sent. default = now
  # @return [Boolean] - result of updating :date_membership_packet_sent
  def toggle_membership_packet_status(date_sent = Time.zone.now)
    new_sent_time = membership_packet_sent? ? nil : date_sent
    update(date_membership_packet_sent: new_sent_time)
  end


  # TODO this doesn't belong in User.  but not sure yet where it does belong.
  # FIXME - what if someone is in the grace period? is logic correct?
  def file_uploaded_during_this_membership_term?
    return false unless current_member? || in_grace_period?

    if current_member?
      file_uploaded_on_or_after?(current_membership.first_day)
    else
      # is in_grace_period
      file_uploaded_on_or_after?(most_recent_membership.first_day)  # FIXME is this correct?
    end
  end


  def file_uploaded_on_or_after?(the_date = Date.current)
    return false if uploaded_files.blank?

    most_recent_uploaded_file.send(most_recent_upload_method) >= the_date
  end


  def files_uploaded_during_this_membership
    return uploaded_files if uploaded_files.empty? || current_membership.nil?

    uploaded_files.select{|file| file.updated_at >= current_membership.first_day}
  end


  def most_recent_uploaded_file
    uploaded_files.order(most_recent_upload_method)&.last
  end

  def most_recent_upload_method
    self.class.most_recent_upload_method
  end

  # The fact that this can no longer be private is a smell that it should be refactored out into a separate class
  def issue_membership_number
    self.membership_number = self.membership_number.blank? ? get_next_membership_number : self.membership_number
  end

  def adjust_related_info_for_destroy
    remove_photo_from_filesystem
    record_deleted_payorinfo_in_payment_notes(self.class, email)
    MembershipsManager.create_archived_memberships_for(self)
    destroy_uploaded_files
  end

  # ===============================================================================================
  private

  # TODO this should not be the responsibility of the User class. Need a MembershipManager class for this.
  def get_next_membership_number
    self.class.connection.execute("SELECT nextval('membership_number_seq')").getvalue(0, 0).to_s
  end

  # remove the associated member photo from the file system by setting it to nil
  def remove_photo_from_filesystem
    member_photo = nil
  end

  def destroy_uploaded_files
    uploaded_files.each do |uploaded_file|
      uploaded_file.actual_file = nil
      uploaded_file.destroy
    end
    save
  end

end
