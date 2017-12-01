class MembershipApplicationsController < ApplicationController
  include PaginationUtility

  before_action :get_membership_application, except: [:information, :index, :new, :create]
  before_action :authorize_membership_application, only: [:update, :show, :edit]
  before_action :set_other_waiting_reason, only: [:show, :edit, :update, :need_info]


  def new
    @membership_application = MembershipApplication.new(user: current_user)
    @all_business_categories = BusinessCategory.all
    @uploaded_file = @membership_application.uploaded_files.build
  end


  def index
    authorize MembershipApplication

    session[:membership_application_items_selection] ||= 'All' if current_user.admin?

    action_params, @items_count, items_per_page =
      process_pagination_params('membership_application')

    @search_params = MembershipApplication.includes(:user).ransack(action_params)

    @membership_applications = @search_params
                                   .result
                                   .includes(:business_categories)
                                   .includes(:user)
                                   .page(params[:page]).per_page(items_per_page)

    render partial: 'membership_applications_list' if request.xhr?
  end


  def show
    @categories = @membership_application.business_categories
  end


  def edit
    @all_business_categories = BusinessCategory.all
  end


  def create
    @membership_application = MembershipApplication.new(user: current_user)
    @membership_application.update(membership_application_params)
    if @membership_application.save

      if new_file_uploaded(params)
        helpers.flash_message(:notice, t('.success', email_address: @membership_application.contact_email))
        redirect_to root_path
      else
        create_error(t('.error'))
      end


      MembershipApplicationMailer.acknowledge_received(@membership_application).deliver

    else
      create_error(t('.error'))
    end
  end


  def update
    if request.xhr?

      if params[:member_app_waiting_reasons] && params[:member_app_waiting_reasons] != "#{@other_waiting_reason_value}"
        @membership_application
            .update(member_app_waiting_reasons_id: params[:member_app_waiting_reasons],
                    custom_reason_text: nil)
        head :ok
      else
        render plain: "#{@other_waiting_reason_value}"
      end

      if params[:custom_reason_text]
        @membership_application.update(custom_reason_text: params[:custom_reason_text],
                                       member_app_waiting_reasons_id: nil)
        head :ok
      end

    elsif @membership_application.update(membership_application_params)

      if new_file_uploaded params

        check_and_mark_if_ready_for_review params['membership_application'] if params.fetch('membership_application', false)

        respond_to do |format|
          format.js do
            head :ok # just let the receiver know everything is OK. no need to render anything
          end

          format.html do
            helpers.flash_message(:notice, t('.success'))
            redirect_to membership_application_path(@membership_application)
          end

        end

      else
        update_error(t('.error'))
      end

    else
      update_error(t('.error'))
    end

  end


  def check_and_mark_if_ready_for_review(app_params)
    if app_params.fetch('marked_ready_for_review', false) && app_params['marked_ready_for_review'] != "0"
      @membership_application.is_ready_for_review!
    end
  end


  def information

  end


  def destroy
    @membership_application = MembershipApplication.find(params[:id]) # we don't need to fetch the categories
    @membership_application.destroy
    redirect_to membership_applications_url, notice: t('membership_applications.application_deleted')
  end


  def start_review
    simple_state_change(:start_review!, t('.success'), t('.error'))
  end


  def accept

    begin
      @membership_application.accept!
      helpers.flash_message(:notice, t('membership_applications.accept.success'))
      redirect_to edit_membership_application_url(@membership_application)
      return
    rescue => e
      helpers.flash_message(:alert, t('.error') + e.message)
      redirect_to edit_membership_application_path(@membership_application)
    end
  end


  def reject
    simple_state_change(:reject!, t('membership_applications.reject.success'), t('.error'))
  end


  def need_info
    simple_state_change(:ask_applicant_for_info!, t('.success'), t('.error'))
  end


  def cancel_need_info

    # empty out the reason for waiting info
    @membership_application.waiting_reason = nil
    @membership_application.custom_reason_text = nil

    simple_state_change(:cancel_waiting_for_applicant!, t('.success'), t('.error'))
  end


  private
  def membership_application_params
    params.require(:membership_application).permit(*policy(@membership_application || MembershipApplication).permitted_attributes)
  end


  def get_membership_application
    @membership_application = MembershipApplication.find(params[:id])
    @categories = @membership_application.business_categories
  end


  def authorize_membership_application
    authorize @membership_application
  end


  def set_other_waiting_reason
    @other_waiting_reason_value = '-1'
    @other_waiting_reason_text = t('admin_only.member_app_waiting_reasons.other_custom_reason')
  end


  def new_file_uploaded(params)

    successful = true

    if (uploaded_files = params['uploaded_file'])

      uploaded_files['actual_files']&.each do |uploaded_file|

        @uploaded_file = @membership_application.uploaded_files.create(actual_file: uploaded_file)

        if @uploaded_file.valid?
          helpers.flash_message(:notice, t('membership_applications.uploads.file_was_uploaded',
                                           filename: @uploaded_file.actual_file_file_name))
          successful = successful & true
        else
          helpers.flash_message :alert, @uploaded_file.errors.messages.values.uniq.flatten.join(' ')
          successful = successful & false
        end

      end

    else # no file to upload, so all is OK. (no errors encountered since we didn't do anything)
      successful
    end

    successful
  end


  def simple_state_change(state_method, success_msg, error_msg)
    begin
      @membership_application.send state_method
      helpers.flash_message(:notice, success_msg)
      render :show
    rescue => e
      helpers.flash_message(:error, error_msg + e.message)
      render :show
    end
  end


  def create_error(error_message)
    helpers.flash_message(:alert, error_message)
    current_user.membership_applications.reload
    render :new
  end


  def update_error(error_message)

    if request.xhr?
      render json: @membership_application.errors.full_messages, status: :unprocessable_entity if request.xhr?
    else
      helpers.flash_message(:alert, error_message)
      render :edit
    end

  end


end
