class AddressPolicy < ApplicationPolicy

  def new?
    return true if user.admin?

    case record.actionable
    when Company
      is_in_company?
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
