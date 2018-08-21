class User < ApplicationRecord
  include PaymentUtility

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_destroy { self.member_photo = nil } # remove photo file from file system

  has_one :shf_application, dependent: :destroy

  has_many :companies, through: :shf_application

  has_many :payments, dependent: :nullify
  # ^^ need to retain h-branding payment(s) for any associated company that
  #    is not also deleted.
  accepts_nested_attributes_for :payments

  has_attached_file :member_photo, default_url: 'photo_unavailable.png',
                    styles: { standard: ['130x130#'] }, default_style: :standard

  validates_attachment_content_type :member_photo,
                                    content_type:  /\Aimage\/.*(jpg|jpeg|png)\z/
  validates_attachment_file_name :member_photo, matches: [/png\z/, /jpe?g\z/, /PNG\z/,/JPE?G\z/]

  validates :first_name, :last_name, presence: true, unless: :updating_without_name_changes

  def updating_without_name_changes
    # Not a new record and not saving changes to either first or last name

    # https://github.com/rails/rails/pull/25337#issuecomment-225166796
    # ^^ Useful background

    !new_record? && !(will_save_change_to_attribute?('first_name') ||
                      will_save_change_to_attribute?('last_name'))
  end

  validates :membership_number, uniqueness: true, allow_blank: true

  scope :admins, -> { where(admin: true) }

  scope :members, -> { where(member: true) }

  def most_recent_membership_payment
    most_recent_payment(Payment::PAYMENT_TYPE_MEMBER)
  end

  def membership_expire_date
    payment_expire_date(Payment::PAYMENT_TYPE_MEMBER)
  end

  def membership_payment_notes
    payment_notes(Payment::PAYMENT_TYPE_MEMBER)
  end

  def membership_current?
    membership_expire_date&.future?
  end

  def self.next_membership_payment_dates(user_id)
    next_payment_dates(user_id, Payment::PAYMENT_TYPE_MEMBER)
  end

  def allow_pay_member_fee?
    # Business rule: user can pay membership fee if:
    # 1. user == member, or
    # 2. user has at least one application with status == :accepted
    # What if a payment has already been made?  any check for that?

    member? || shf_application&.accepted?
  end


  def member_fee_payment_due?
    member? && ! membership_current?
  end


  def has_shf_application?
    shf_application&.valid?
  end

  def check_member_status
    # Called from Warden after user authentication - see after_sign_in.rb
    # If member payment has expired, revoke membership status.
    if member? && ! membership_current?
      update(member: false)
    end
  end


  def member_or_admin?
    admin? || member?
  end


  def in_company_numbered?(company_num)
    member? && shf_application&.companies&.where(company_number: company_num)&.any?
  end


  def full_name
    "#{first_name} #{last_name}"
  end

  def has_full_name?
    first_name.present? && last_name.present?
  end


  def grant_membership(send_email: true)
    return if self.member && self.membership_number.present?

    update(member: true, membership_number: issue_membership_number)
    MemberMailer.membership_granted(self).deliver if send_email
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

  private

  def issue_membership_number
    self.membership_number = self.membership_number.blank? ? get_next_membership_number : self.membership_number
  end


  def get_next_membership_number
    self.class.connection.execute("SELECT nextval('membership_number_seq')").getvalue(0,0).to_s
  end

end
