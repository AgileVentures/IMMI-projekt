class AdminPolicy < Struct.new(:user)

  def authorized?
    is_admin?
  end


  private
  def is_admin?
    user.admin? if user
  end

end