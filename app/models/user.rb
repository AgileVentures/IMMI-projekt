class User < ApplicationRecord
  include PaymentUtility

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_destroy { self.member_photo = nil } # remove photo file from file system

  has_many :shf_applications

  has_many :payments
  accepts_nested_attributes_for :payments

  has_attached_file :member_photo, default_url: 'photo_unavailable.png',
                    styles: { standard: ['250'] }, default_style: :standard

  validates_attachment_content_type :member_photo,
                                    content_type:  /\Aimage\/.*(jpeg|png)\z/
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
    # TODO what if a payment has already been made?  any check for that?

    member? || shf_applications.where(state: :accepted).any?
  end


  def member_fee_payment_due?
    member? && ! membership_current?
  end


  def has_shf_application?
    shf_applications.any?
  end

  def check_member_status
    # Called from Warden after user authentication - see after_sign_in.rb
    # If member payment has expired, revoke membership status.
    if member? && ! membership_current?
      update(member: false)
    end
  end


  def has_company?
    shf_applications.where.not(company_id: nil).count > 0
  end


  def shf_application
    has_shf_application? ? shf_applications.last : nil
  end


  def company
    has_company? ? shf_application.company : nil
  end


  def is_member_or_admin?
    admin? || member?
  end


  def is_in_company_numbered?(company_num)
    member? && !(companies.detect { |c| c.company_number == company_num }).nil?
  end


  def companies
    if admin?
      Company.all
    elsif member? && has_shf_application?
      cos = shf_applications.reload.map(&:company).compact
      cos.uniq(&:company_number)
    else
      [] # no_companies
    end
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
