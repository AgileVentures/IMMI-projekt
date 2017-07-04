class ShfDocumentPolicy < ApplicationPolicy


  def index?
    user.is_member_or_admin? if user
  end

  def update?
    user.admin?
  end


  def show?
    user.admin?
  end

  def contents_show?
    index?
  end

  def contents_edit?
    update?
  end

  def contents_update?
    update?
  end

  def new?
    create?
  end


  def create?
    user.admin?
  end

  def minutes_and_static_pages?
    index?
  end

end
