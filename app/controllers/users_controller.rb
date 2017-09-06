class UsersController < ApplicationController
  before_action :authorize_user
  before_action :set_user, except: :index


  def index
    @q = User.ransack(params[:q])
    @users = @q.result.includes(:membership_applications)

    @filter_ignore_membership = true
    @filter_are_members = params.include?(:are_members) && params[:are_members] == 'true'
    @filter_are_not_members = params.include?(:are_members) && params[:are_members] == 'false'

    %w(are_members are_not_members).each do | filter |
      if self.instance_variable_get("@filter_#{filter}")
        @users = @users.send(filter)
        @filter_ignore_membership = false
      end
    end

    render partial: 'users_list', locals: { q: @q, users: @users } if request.xhr?
  end


  def update

    if @user.update(user_params)
      redirect_to @user, notice: t('.success')
    else
      helpers.flash_message(:alert, t('.error'))

      @user.errors.full_messages.each { |err_message| helpers.flash_message(:alert, err_message) }

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


end
