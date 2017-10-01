class AddressPolicy < ApplicationPolicy
  include PoliciesHelper

  def new?
    user.admin? || is_in_company?(record.addressable)
  end

  def create?
    new?
  end

  def edit?
    new?
  end

  def update?
    new?
  end

  def destroy?
    new?
  end

  def set_address_type?
    new?
  end
end
