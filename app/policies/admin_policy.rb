class AdminPolicy < Struct.new(:user)

  def authorized?
    user.admin?
  end

end
