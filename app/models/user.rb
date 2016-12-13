class User < ApplicationRecord
  has_many :membership_applications
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  def has_membership_application?
    membership_applications.size > 0
  end


  def has_company?
    has_membership_application? && (membership_applications.select { |app| app.company }).count > 0
  end


  def membership_application
    has_membership_application? ? membership_applications.last : nil
  end


  def company
    has_company? ? membership_application.company : nil
  end


  def is_member?
    is_member
  end


  def is_member_or_admin?
    admin? || is_member?
  end

end
