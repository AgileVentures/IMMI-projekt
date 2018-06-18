class UsersController < ApplicationController
  include PaginationUtility

  before_action :set_user, except: :index
  before_action :set_app_config, only: [:show, :proof_of_membership, :update,
                                        :company_h_brand]
  before_action :authorize_user, only: [:show]
  before_action :allow_iframe_request, only: [:proof_of_membership, :company_h_brand]

  def show
  end

  def proof_of_membership
    download_or_show_image('proof_of_membership', params[:render_to], 260)
  end

  def company_h_brand
    download_or_show_image('company_h_brand', params[:render_to], 300)
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

<<<<<<< HEAD

  def download_image(type, render_to, width)
=======
  def download_or_show_image(type, render_to, width)
>>>>>>> 77e160563ea9a5931de07c33524e34352a0302fa
    html = image_html(type)

    render html: html.html_safe and return unless render_to == 'jpg'

<<<<<<< HEAD
    kit = build_kit(html, "#{type.gsub /_/, '-'}.css", width)
=======
    kit = build_kit(html, "#{type.tr('_', '-')}.css", width)
>>>>>>> 77e160563ea9a5931de07c33524e34352a0302fa

    send_data(kit.to_jpg, type: 'image/jpg', filename: "#{type}.jpeg")
  end

  def image_html(image_type)
    render_to_string(partial: image_type,
                     locals: { app_config: @app_configuration, user: @user,
                               render_to: params[:render_to]&.to_sym,
                               context: params[:context]&.to_sym,
                               company: Company.find_by_id(params[:company_id]) })
  end

  def build_kit(html, image_css, width)
    kit = IMGKit.new(html, encoding: 'UTF-8', width: width, quality: 100)
    kit.stylesheets << Rails.root.join('app', 'assets', 'stylesheets',
                                       image_css)
    kit
  end

  def authorize_user
    authorize @user
  end


  def set_user
    @user = User.find(params[:id])
  end

  def set_app_config
    # Need app config items for proof-of-membership
    @app_configuration = AdminOnly::AppConfiguration.last
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :email, :member, :password,
                                 :password_confirmation)
  end


  def payment_params
    params.require(:payment).permit(:expire_date, :notes)
  end

  def allow_iframe_request
    response.headers.delete('X-Frame-Options')
    # https://stackoverflow.com/questions/17542511/
    # cannot-display-my-rails-4-app-in-iframe-even-if-x-frame-options-is-allowall
  end


end
