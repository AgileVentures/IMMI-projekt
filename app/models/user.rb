class User < ApplicationRecord
  has_many :membership_applications
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :first_name, :last_name, unless: Proc.new {!new_record? && !(first_name_changed? || last_name_changed?)}
  validates_uniqueness_of :membership_number, allow_blank: true

  scope :are_members, lambda {
    User.all.select { | user | user.is_member? }
  }

  scope :are_not_members, lambda {
    User.all.reject { | user | user.is_member? }
  }

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


  def is_member?
    has_membership_application? && (membership_applications.select{|m| m.is_member? }.count > 0 )
  end


  def is_member_or_admin?
    admin? || is_member?
  end


  def is_in_company_numbered?(company_num)
    is_member? && !(companies.detect { |c| c.company_number == company_num }).nil?
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


  def issue_membership_number
    self.membership_number = self.membership_number.blank? ? get_next_membership_number : self.membership_number
  end

  private

  def get_next_membership_number
    self.class.connection.execute("SELECT nextval('membership_number_seq')").getvalue(0,0).to_s
  end


end
