class CompanyPolicy < ApplicationPolicy
  include PoliciesHelper

  def show?
    true
  end

  def index?
    true
  end

  def new?
    not_a_visitor
  end

  def create?
    new?
  end

  def update?
    user.admin? || is_in_company?(record)
  end

  def edit_payment?
    user.admin?
  end

end
