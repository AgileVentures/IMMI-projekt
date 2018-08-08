class UsersController < ApplicationController
  include PaginationUtility
  include ImagesUtility

  before_action :set_user, except: :index
  before_action :set_app_config, only: [:show, :proof_of_membership, :update]
  before_action :authorize_user, only: [:show]
  before_action :allow_iframe_request, only: [:proof_of_membership]

  def show
  end

  def proof_of_membership
    image_html = image_html('proof_of_membership', @app_configuration, @user)
    if params[:render_to] == 'jpg'
      download_image('proof_of_membership', 260, image_html)
    else
      show_image(image_html)
    end
  end

  def index
    authorize User
    self.params = fix_FB_changed_q_params(self.params)

    action_params, @items_count, items_per_page = process_pagination_params('user')

    if action_params then
      @filter_are_members = action_params[:membership_filter] == '1'
      @filter_are_not_members = action_params[:membership_filter] == '2'
    end
    @filter_ignore_membership = !(@filter_are_members || @filter_are_not_members)

    membership_filter = 'member = true' if @filter_are_members
    membership_filter = 'member = false' if @filter_are_not_members

    @q = User.ransack(action_params)

    @users = @q.result.includes(:shf_application).where(membership_filter).page(params[:page]).per_page(items_per_page)

    render partial: 'users_list', locals: { q: @q, users: @users, items_count: @items_count } if request.xhr?

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


  def edit_status
    raise 'Unsupported request' unless request.xhr?
    authorize User

    payment = @user.most_recent_membership_payment

    @user.update!(user_params) && (payment ?
                                       payment.update!(payment_params) : true)

    render partial: 'member_payment_status', locals: { user: @user }

  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
    render partial: 'member_payment_status',
           locals: { user: @user, error: t('users.update.error') }
  end


  private

  def authorize_user
    authorize @user
  end


  def set_user
    @user = User.find_by_id(params[:id]) || Visitor.new
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :email, :member, :password,
                                 :password_confirmation)
  end


  def payment_params
    params.require(:payment).permit(:expire_date, :notes)
  end

end
