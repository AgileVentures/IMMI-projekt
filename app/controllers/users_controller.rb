class UsersController < ApplicationController

  include RobotsMetaTagShowActionOnly
  include SetAppConfiguration
  include PaginationUtility
  include ImagesUtility

  LOG_FILE = LogfileNamer.name_for('users')

  before_action :set_user, except: [:index, :toggle_membership_package_sent]
  before_action :set_app_config, only: [:show, :proof_of_membership, :update, :edit_status]
  before_action :authorize_user, only: [:show]
  before_action :allow_iframe_request, only: [:proof_of_membership]

  ARE_MEMBERS_CLAUSE = 'member = true'.freeze
  ARE_NOT_MEMBERS_CLAUSE = 'member = false'.freeze

  #================================================================================

  def show
  end

  def proof_of_membership
    render_as = request.format.to_sym

    if render_as == :jpg
      jpg_image = @user.proof_of_membership_jpg

      unless jpg_image
        jpg_image = create_image_jpg('proof_of_membership', 260, @app_configuration, @user)
        @user.proof_of_membership_jpg = jpg_image
      end

      download_image('proof_of_membership', jpg_image, send_as(params[:context]))
    else
      image_html = image_html('proof_of_membership', @app_configuration,
                              @user, render_as, params[:context])
      show_image(image_html)
    end
  end

  def index
    authorize User
    self.params = fix_FB_changed_q_params(self.params)

    action_params, @items_count, items_per_page = process_pagination_params('user')

    if action_params
      @filter_are_members = action_params[:membership_filter] == '1'
      @filter_are_not_members = action_params[:membership_filter] == '2'
    end
    @filter_ignore_membership = !(@filter_are_members || @filter_are_not_members)

    membership_filter = if @filter_are_members
                          ARE_MEMBERS_CLAUSE
                        elsif @filter_are_not_members
                          ARE_NOT_MEMBERS_CLAUSE
                        else
                          ''
                        end

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


  # Manually change the membership status and/or last day and/or notes
  # FIXME: This does too much.  Let the admin change/add a membership note any time, separately from this.
  def edit_status
    raise 'Unsupported request' unless request.xhr?
    authorize User

    admin_change_note = ''
    last_day_param = Date.new(membership_params['last_day(1i)'].to_i, membership_params['last_day(2i)'].to_i, membership_params['last_day(3i)'].to_i)

    if @user.current_member?
      current_membership = @user.current_membership
      if user_params[:member] == 'true'
        if last_day_param < Date.current
          admin_change_note << end_membership_and_note(@user, current_membership, last_day_param)
        elsif last_day_param != current_membership.last_day
          admin_change_note << change_membership_last_day_and_note(current_membership, last_day_param)
        end
      else
        admin_change_note << end_membership_yesterday_and_note(@user, current_membership)
      end
    else
      if user_params[:member] == 'true'
        @user.start_membership!(date: Date.current)
        current_membership = @user.current_membership
        admin_change_note << t('memberships.auto_added_notes.started_on', first_day: Date.current )
        if last_day_param != current_membership.last_day
          admin_change_note << change_membership_last_day_and_note(current_membership, last_day_param)
        end
      end
    end
    admin_change_note = "| #{t('memberships.auto_added_notes.changed_by_admin', changed_timestamp: Time.zone.now)}: #{admin_change_note} |" unless admin_change_note.blank?
    membership_note = membership_params.fetch(:notes, '') + admin_change_note
    current_membership.update!(notes: membership_note) if current_membership

    if @user.member?
      render partial: 'show_for_member', locals: { user: @user, current_user: @current_user, app_config: @app_configuration }
    else
      render partial: 'show_for_applicant', locals: { user: @user, current_user: @current_user }
    end


  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
    render partial: 'membership_term_status',
           locals: { user: @user, error: t('users.update.error') }
  end


  # Toggle whether or not a membership package was sent to a user.
  #
  # Just return a success or fail with error message.  Don't
  # render a new page.  Just update info as needed and send
  # 'success' or 'fail' info back.
  def toggle_membership_package_sent

    authorize User

    user =  User.find_by_id(params[:user_id])
    if user
      user.toggle_membership_packet_status

      respond_to do |format|
        format.json { head :ok }
      end

    else
      raise ActiveRecord::RecordNotFound,  "User not found! user_id = #{params[:user_id]}"
    end

  end


  def destroy
    @user.destroy

    ActivityLogger.open(LOG_FILE, 'Manage Users', 'Delete') do |log|
      log.record('info', "User #{@user.id}, #{@user.full_name} (#{@user.email})")
    end

    redirect_back(fallback_location: users_path, notice: t('.success'))
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
    params.require(:user).permit(:name, :email, :member, :membership_status,
                                 :password,
                                 :password_confirmation,
                                 :date_membership_packet_sent)
  end


  def membership_params
    params.require(:membership).permit(:member_number, :first_day, :last_day, :notes)
  end


  def payment_params
    params.require(:payment).permit(:expire_date, :notes)
  end

  # Set @user to @current_user for situations where the current user
  # is the one viewing and requesting the controller actions.
  def set_user_to_current_user
    @user = @current_user
  end


  def end_membership_yesterday_and_note(user, membership)
    end_membership_and_note(user, membership, Date.current - 1.day)
  end


  def end_membership_and_note(user, membership, last_day)
    return unless membership

    note = t('memberships.auto_added_notes.ended_on', new_last_day: last_day, original_last_day: membership.last_day)
    user.update!(membership_status: :not_a_member, member: false)
    membership.update!(last_day: last_day)
    MembershipStatusUpdater.instance.user_updated(membership.user)
    note
  end


  def change_membership_last_day_and_note(membership, new_last_day)
    return unless membership

    note = t('memberships.auto_added_notes.last_day_changed',  original_last_day: membership.last_day, new_last_day: new_last_day)
    membership.update!(last_day: new_last_day)
    MembershipStatusUpdater.instance.user_updated(membership.user)
    note
  end
end
