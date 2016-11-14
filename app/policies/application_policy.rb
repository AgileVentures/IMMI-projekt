class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def manage?
    @user.admin?
  end

  def index?
    @user.admin?
  end

  def update?
    @record.user == @user || @user.admin?
  end

  def edit?
    update?
  end

end
