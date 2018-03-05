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

  def new?
    record.is_a?(Class)  # should not be an already instantiated object
  end

  def create?
    admin_or_owner?
  end


  def destroy?
    user.admin?
  end

  private

  def admin_or_owner?
    user.admin? || ( record.respond_to?(:user) &&  record.user == user )
  end

  def not_a_visitor
    !user.is_a? Visitor
  end

end
