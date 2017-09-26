class AddressPolicy < ApplicationPolicy
  include PoliciesHelper

  def new?
    return true if user.admin?

    case record.addressable
    when Company
      is_in_company? record.addressable
    end
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
