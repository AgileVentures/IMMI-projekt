class User < ApplicationRecord
  has_many :membership_applications
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :payments
  accepts_nested_attributes_for :payments

  validates_presence_of :first_name, :last_name, unless: Proc.new {!new_record? && !(first_name_changed? || last_name_changed?)}
  validates_uniqueness_of :membership_number, allow_blank: true

  scope :are_members, lambda {
    User.all.select { | user | user.member? }
  }

  scope :are_not_members, lambda {
    User.all.reject { | user | user.member? }
  }

  def most_recent_payment
    payments.completed.order(:created_at).last
  end

  def membership_expire_date
    most_recent_payment&.expire_date
  end

  def payment_notes
    most_recent_payment&.notes
  end

  def self.next_payment_dates(user_id)
    # Business rules:
    # start_date = prior payment expire date + 1 day
    # expire_date = start_date + 1 year - 1 day
    # (special rules apply for remainder of 2017)
    user = find(user_id)

    if user.membership_expire_date
      start_date = user.most_recent_payment.expire_date + 1.day
    else
      start_date = Date.current
    end
    if Date.today.year == 2017
      expire_date = Date.new(2018, 12, 31)
    else
      expire_date = start_date + 1.year - 1.day
    end
    [start_date, expire_date]
  end

  def allow_pay_member_fee?
    # Business rule: user can pay membership fee if:
    # 1. user == member, or
    # 2. user has at least one application with status == :accepted

    member? || membership_applications.where(state: :accepted).any?
  end

  def has_membership_application?
    membership_applications.any?
  end


  def has_company?
    membership_applications.where.not(company_id: nil).count > 0
  end


  def membership_application
    has_membership_application? ? membership_applications.last : nil
  end


  def company
    has_company? ? membership_application.company : nil
  end


  def admin?
    admin
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
    elsif is_member_or_admin? && has_membership_application?
      cos = membership_applications.reload.map(&:company).compact
      cos.uniq(&:company_number)
    else
      [] # no_companies
    end
  end


  def full_name
    "#{first_name} #{last_name}"
  end


  def grant_membership
    update(member: true, membership_number: issue_membership_number)
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
