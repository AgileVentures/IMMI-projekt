class AddressPolicy < ApplicationPolicy

  def new?
    return true if user.admin?

    case record
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
end
