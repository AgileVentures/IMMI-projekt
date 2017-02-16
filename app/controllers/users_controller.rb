class UsersController < ApplicationController
  def index
    authorize User

    @users = User.all.order(last_sign_in_at: :asc)
  end
end
