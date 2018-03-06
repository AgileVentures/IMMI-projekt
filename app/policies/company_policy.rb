class CompanyPolicy < ApplicationPolicy
  include PoliciesHelper

  def show?
    true
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
    user.admin? || is_in_company?(record)
  end

  def edit_payment?
    user.admin?
  end

end
