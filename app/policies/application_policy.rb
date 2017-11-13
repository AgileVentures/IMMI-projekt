class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def show?
    admin_or_owner?
  end

  def index?
    user.admin?
  end

  def update?
    admin_or_owner?
  end

  def edit?
    update?
  end


  def destroy?
    user.admin?
  end

  private

  def admin_or_owner?
    user.admin? || record.user == user
  end

end
