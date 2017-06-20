class PagePolicy < Struct.new(:user, :record)

  def destroy?
    user.admin?
  end

  def show?
    user_is_member?
  end


  def index?
    user_is_member?
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


  private
  def user_is_member?
    (user.is_member? || user.admin?)
  end

end
