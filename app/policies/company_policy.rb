class CompanyPolicy < ApplicationPolicy


  def show?
    true
  end


  def index?
    is_admin?
  end


  def new?
    is_admin?
  end

  def create?
    new?
  end

  def update?
    is_admin? || @user
  end


  def edit?
    update?
  end


  def destroy?
    is_admin?
  end


  private
  def is_admin?
    @user.admin? if @user
  end
end