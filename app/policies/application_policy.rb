class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def show?
    edit?
  end

  def update?
    @record.user == @user
  end

  def edit?
    update?
  end

end
