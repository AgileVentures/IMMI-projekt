class CompanyPolicy < ApplicationPolicy


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
    new?
  end

  def update?
   user.admin? || is_in_company?
  end



  private

  def is_in_company?
    @user.is_in_company_numbered?(@record.company_number)
  end
end
