# @class User
#
# @responsibilty  A user that can log in.  Knows membership _payment_ status,
#  application status.
#
# FIXME only the class RequirementsForMembership should respond to questions
#   about whether a user is current member. (Ex: RequirementsForMembership.requirements_met?({ user: approved_and_paid }) )
#
class User < ApplicationRecord
  include PaymentUtility
  include ImagesUtility

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_destroy :adjust_related_info_for_destroy

  has_one :shf_application, dependent: :destroy
  accepts_nested_attributes_for :shf_application, update_only: true

  has_many :uploaded_files
  accepts_nested_attributes_for :uploaded_files, allow_destroy: true

  has_many :companies, through: :shf_application

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

  THIS_PAYMENT_TYPE = Payment::PAYMENT_TYPE_MEMBER


  scope :admins, -> { where(admin: true) }
  scope :not_admins, -> { where(admin: nil).or(User.where(admin: false)) }

  # FIXME: this is not accurate; DO NOT USE. (Need to carefully remove any use.)  Other checks may need to be done.
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

  scope :paid_on_or_after_guidelines_reqd, -> { joins(:payments).where("payments.status = '#{Payment::SUCCESSFUL}' AND payments.payment_type = ? AND  payments.created_at >= ?", Payment::PAYMENT_TYPE_MEMBER, UserChecklistManager.membership_guidelines_reqd_start_date) }

  scope :agreed_to_membership_guidelines, -> { where(id: UserChecklist.top_level_for_current_membership_guidelines.completed.pluck(:user_id)) }

  scope :current_members, -> { application_accepted.membership_payment_current }


  # -----------------------------------

  # TODO this should not be the responsibility of the User class. Need a MembershipManager class for this.
  # The next membership payment date
  def self.next_membership_payment_date(user_id)
    next_membership_payment_dates(user_id).first
  end


  # TODO this should not be the responsibility of the User class. Need a MembershipManager class for this.
  def self.next_membership_payment_dates(user_id)
    next_payment_dates(user_id, THIS_PAYMENT_TYPE)
  end


  # ----------------------------------

  after_update :clear_proof_of_membership_jpg_cache,
               if: Proc.new { saved_change_to_member_photo_file_name? ||
                              saved_change_to_first_name? ||
                              saved_change_to_last_name? ||
                              saved_change_to_membership_number? }

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

  def self.clear_all_proof_of_membership_jpg_caches
    all.each do |user|
      user.clear_proof_of_membership_jpg_cache
    end
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


  # TODO this should not be the responsibility of the User class. Need a MembershipManager class for this.
  def membership_start_date
    payment_start_date(THIS_PAYMENT_TYPE)
  end


  # TODO this should not be the responsibility of the User class. Need a MembershipManager class for this.
  def membership_expire_date
    payment_expire_date(THIS_PAYMENT_TYPE)
  end


  # TODO this should not be the responsibility of the User class. Need a MembershipManager class for this.
  def membership_payment_notes
    payment_notes(THIS_PAYMENT_TYPE)
  end


  # TODO this should not be the responsibility of the User class. Need a MembershipManager class for this.
  # FIXME - this is ONLY about the payments, not the membership status as a whole.
  #   so the name should be changed.  ex: membership_payments_current?  or membership_payment_term....
  def membership_current?
    # TODO can use term_expired?(THIS_PAYMENT_TYPE)
    !!membership_expire_date&.future? # using '!!' will turn a nil into false
  end


  # TODO this should not be the responsibility of the User class. Need a MembershipManager class for this.
  # FIXME - this is ONLY about the payments, not the membership status as a whole.
  #   so the name should be changed.  ex: membership_payments_current_as_of?
  def membership_current_as_of?(this_date)
    return false if this_date.nil?

    membership_payment_expire_date = membership_expire_date
    !membership_payment_expire_date.nil? && (membership_payment_expire_date > this_date)
  end


  # User has an approved membership application and
  # is up to date (current) on membership payments
  def membership_app_and_payments_current?
    has_approved_shf_application? && membership_current?
  end


  # User has an approved membership application and
  # is up to date (current) on membership payments
  def membership_app_and_payments_current_as_of?(this_date)
    has_approved_shf_application? && membership_current_as_of?(this_date)
  end


  # Business rule: user can pay membership fee if:
  # 1. the user is not the admin (an admin cannot make a payment for a member or user)
  #      AND
  # 2. the user is a member
  #     OR
  #    ( user has at least one application with status == :accepted
  #       AND
  #       ( user has checked all ethical guidelines if they have to)
  #    )
  #
  # What if a payment has already been made?  any check for that?
  # TODO this should not be the responsibility of the User class. Need a MembershipManager class for this.
  def allowed_to_pay_member_fee?
    # FIXME: use membership_current? instead of member?
    !admin? && (member? || (shf_application&.accepted? && UserChecklistManager.completed_membership_guidelines_if_reqd?(self)))
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
    # FIXME: should member? be used here?
    member? && !membership_current?
  end


  def has_shf_application?
    shf_application&.valid?
  end


  def has_approved_shf_application?
    shf_application&.accepted?
  end


  def member_or_admin?
    admin? || member?
  end


  def in_company?(company)
    in_company_numbered?(company.company_number)
  end


  def in_company_numbered?(company_num)
    member? && has_approved_app_for_company_number?(company_num)
  end


  def has_approved_app_for_company?(company)
    has_approved_app_for_company_number?(company.company_number)
  end


  def has_approved_app_for_company_number?(company_num)
    has_app_for_company_number?(company_num) && apps_for_company_number(company_num).first.accepted?
  end


  def has_app_for_company?(company)
    has_app_for_company_number?(company.company_number)
  end


  def has_app_for_company_number?(company_num)
    apps_for_company_number(company_num)&.any?
  end


  # @return [Array] all shf_applications that contain the company, sorted by the application with the expire_date furthest in the future
  def apps_for_company(company)
    apps_for_company_number(company.company_number)
  end


  # @return [Array] all shf_applications that contain a company with the company_num, sorted by the application with the expire_date furthest in the future
  #   Note that right now a User can have only 1 ShfApplication, but in the future
  #   if a User can have more than 1, we want to be sure they are sorted by expire_date with the
  #    expire_date in the future as the first one and the expire_date in the past as the last one
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


  # The fact that this can no longer be private is a smell that it should be refactored out into a separate class
  def issue_membership_number
    self.membership_number = self.membership_number.blank? ? get_next_membership_number : self.membership_number
  end


  def adjust_related_info_for_destroy
    remove_photo_from_filesystem
    record_deleted_payorinfo_in_payment_notes(self.class, email)
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
