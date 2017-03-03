class MembershipApplicationsController < ApplicationController
  before_action :get_membership_application, except: [:information, :index, :new, :create]
  before_action :authorize_membership_application, only: [:update, :show, :edit]


  def new
    @membership_application = MembershipApplication.new
    @all_business_categories = BusinessCategory.all
    @uploaded_file = @membership_application.uploaded_files.build
  end


  def index
    authorize MembershipApplication

    @search_params = MembershipApplication.ransack(params[:q])

    @membership_applications = @search_params
                                   .result
                                   .includes(:business_categories)
                                   .page(params[:page]).per_page(10)

    render partial: 'membership_applications_list' if request.xhr?
  end


  def show
    @categories = @membership_application.business_categories
  end


  def edit
    @all_business_categories = BusinessCategory.all
  end


  def create
    @membership_application = current_user.membership_applications.build(membership_application_params)
    if @membership_application.save

      if new_file_uploaded(params)
        helpers.flash_message(:notice, t('.success'))
        redirect_to root_path
      else
        helpers.flash_message(:alert, t('.error'))
        current_user.membership_applications.reload
        render :new
      end

    else
      helpers.flash_message(:alert, t('.error'))
      current_user.membership_applications.reload
      render :new
    end
  end


  def update
    if @membership_application.update(membership_application_params)

      if new_file_uploaded params

        check_and_mark_if_ready_for_review params['membership_application'] if params.fetch('membership_application', false)

        helpers.flash_message(:notice, t('.success'))
        render :show

      else
        helpers.flash_message(:alert, t('.error'))
        redirect_to edit_membership_application_path(@membership_application)
      end

    else
      helpers.flash_message(:alert, t('.error'))
      redirect_to edit_membership_application_path(@membership_application)
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
    @membership_application = MembershipApplication.find(params[:id])  # we don't need to fetch the categories
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
      helpers.flash_message(:notice, t('membership_applications.update.enter_member_number'))
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


end
