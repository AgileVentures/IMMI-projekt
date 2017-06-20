class BusinessCategoryPolicy < ApplicationPolicy

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
    user.admin?
  end


  def update?
    user.admin?
  end


  def edit?
    user.admin?
  end


end
