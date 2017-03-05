class UsersController < ApplicationController
  before_action :authorize_user
  before_action :set_user, only: [:show, :update]


  def index
    @users = User.all.order(last_sign_in_at: :asc)
  end


  def update

    if passwords_match(user_params) && @user.update(user_params)
      redirect_to @user, notice: t('.success')
    else
      flash[:alert] = t('.error') + '  ' + t('.passwords_dont_match')
      render :show
    end

  end

  private

  def authorize_user
    authorize User
  end

  def set_user
    @user = User.find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end


  # if the password was changed, ensure the confirmation matches the 1st one entered
  def passwords_match(u_params)
    u_params.key?('password') && u_params.key?('password_confirmation') && u_params['password'] == u_params['password_confirmation']
  end
end
