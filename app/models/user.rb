class User < ApplicationRecord
  include PaymentUtility

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_destroy { self.member_photo = nil } # remove photo file from file system

  has_one :shf_application

  has_many :companies, through: :shf_application

  has_many :payments
  accepts_nested_attributes_for :payments

  has_attached_file :member_photo, default_url: 'photo_unavailable.png',
                    styles: { standard: ['130x130#'] }, default_style: :standard

  validates_attachment_content_type :member_photo,
                                    content_type:  /\Aimage\/.*(jpg|jpeg|png)\z/
  validates_attachment_file_name :member_photo, matches: [/png\z/, /jpe?g\z/]

  validates_presence_of :first_name, :last_name, unless: Proc.new {!new_record? && !(first_name_changed? || last_name_changed?)}
  validates_uniqueness_of :membership_number, allow_blank: true

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

    member? || shf_application&.accepted?
  end

  def has_shf_application?
    ! shf_application.nil? && shf_application.valid?
  end

  def check_member_status
    # Called from Warden after user authentication - see after_sign_in.rb
    # If member payment has expired, revoke membership status.
    if member? && ! membership_current?
      update(member: false)
    end
  end


  def has_company?
    companies.any?
  end


  def company
    companies.last
  end

  def companies
    return Company.all if admin?

    super
  end


  def member_or_admin?
    admin? || member?
  end


  def in_company_numbered?(company_num)
    member? && companies.where(company_number: company_num).any?
  end


  def full_name
    "#{first_name} #{last_name}"
  end


  def grant_membership(send_email: true)
    return if self.member && self.membership_number.present?

    update(member: true, membership_number: issue_membership_number)
    MemberMailer.membership_granted(self).deliver if send_email
  end


  ransacker :padded_membership_number do
    Arel.sql("lpad(membership_number, 20, '0')")
  end

  private

  def issue_membership_number
    self.membership_number = self.membership_number.blank? ? get_next_membership_number : self.membership_number
  end


  def get_next_membership_number
    self.class.connection.execute("SELECT nextval('membership_number_seq')").getvalue(0,0).to_s
  end

end
