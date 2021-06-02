class CompanyPolicy < ApplicationPolicy
  include PoliciesHelper

  # Admin can always see (show) any company
  # A User in the company can see it
  #
  # If the company information is complete, then it can be shown to anyone,
  #  else (if the information is not complete), it cannot be shown.
  def show?
    return true if user.admin? || is_in_company?(record)

    record.information_complete? ? true : false
  end

  def index?
    true
  end

  def new?
    user.admin?
  end

  def create?
    # User needs to be able to create a company within the context of
    # creating a membership application
    not_a_visitor
  end

  def update?
    user.admin? || (is_in_company?(record) && user.current_member?)
  end

  def edit_payment?
    user.admin?
  end

  def fetch_from_dinkurs?
    user.admin? || is_in_company?(record.company) # TODO this is true only if the user's single ShfApplication is for the company AND the application is accepted
    # FIXME will need to adjust this when implementing user has many ShfApplications
  end

  def view_complete_status?
    # FIXME will need to adjust this when implementing user has many ShfApplications; should have the user check this (currently, record = the company)
    user.admin? || record&.accepted_applicants.include?(user)
  end
end
