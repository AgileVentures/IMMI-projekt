class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def edit_status?
    user.admin?
  end

  def show?
    user.admin? || record.id == user.id
  end
end
