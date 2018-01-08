class DinkursEventPolicy < ApplicationPolicy
  include PoliciesHelper


  def new?
    user.admin?
  end


  def create?
    new?
  end


  def show?
    true
  end


  def index?
    true
  end


  def update?
    user.admin? || is_in_company?(record.company)
  end


  def edit?
    update?
  end


end
