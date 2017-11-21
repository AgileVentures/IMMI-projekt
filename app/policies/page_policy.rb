class PagePolicy < Struct.new(:user, :record)

  def destroy?
    user.admin?
  end

  def show?
    user.is_member_or_admin?
  end


  def index?
    show?
  end


  def new?
    user.admin?
  end


  def create?
    new?
  end


  def update?
    user.admin?
  end


  def edit?
    update?
  end
end
