class ShfApplicationsController < ApplicationController
  include PaginationUtility

  before_action :get_shf_application, except: [:information, :index, :new, :create]
  before_action :authorize_shf_application
  before_action :set_other_waiting_reason, only: [:show, :edit, :update, :need_info]
  before_action :set_allowed_file_types, only: [:edit, :new, :update, :create]

  def new
    @shf_application = ShfApplication.new(user: current_user)
    @company = Company.new
    @all_business_categories = BusinessCategory.all
    @uploaded_file = @shf_application.uploaded_files.build
  end


  def index
    authorize ShfApplication

    self.params = fix_FB_changed_q_params(self.params)

    session[:shf_application_items_selection] ||= 'All' if current_user.admin?

    action_params, @items_count, items_per_page =
        process_pagination_params('shf_application')


    @search_params = ShfApplication.includes(:user).ransack(action_params)

    @shf_applications = @search_params
                            .result
                            .includes(:business_categories)
                            .includes(:user)
                            .page(params[:page]).per_page(items_per_page)

    render partial: 'shf_applications_list' if request.xhr?

  end


  def show
    @categories = @shf_application.business_categories
  end


  def edit
    @company = @shf_application.companies.first
    load_update_objects
  end


  def create

    @shf_application = ShfApplication.new(shf_application_params
                                          .merge(user: current_user))

    set_companies_for_application

    if @shf_application.save

      file_uploads_successful = new_file_uploaded(params)

      send_new_app_emails(@shf_application)

      if file_uploads_successful
        helpers.flash_message(:notice, t('.success', email_address: @shf_application.contact_email))
        redirect_to information_path
      else
        helpers.flash_message(:notice, t('.success_with_file_problem'))
        load_update_objects
        render :edit
      end

    else
      create_error(t('.error'))
    end
  end


  def update
    if request.xhr?

      if params[:member_app_waiting_reasons] && params[:member_app_waiting_reasons] != "#{@other_waiting_reason_value}"
        @shf_application
            .update(member_app_waiting_reasons_id: params[:member_app_waiting_reasons],
                    custom_reason_text: nil)
        head :ok
      else
        render plain: "#{@other_waiting_reason_value}"
      end

      if params[:custom_reason_text]
        @shf_application.update(custom_reason_text: params[:custom_reason_text],
                                member_app_waiting_reasons_id: nil)
        head :ok
      end

    else

      set_companies_for_application

      company_valid = @company.valid?

      if @shf_application.update(shf_application_params) && company_valid

        if new_file_uploaded params

          check_and_mark_if_ready_for_review params['shf_application'] if params.fetch('shf_application', false)

          respond_to do |format|
            format.js do
              head :ok # just let the receiver know everything is OK. no need to render anything
            end

            rendering(format, shf_application_params)

          end

        else
          update_error(t('.error'))
        end

      else
        @shf_application.errors.add(:companies, :blank) unless company_valid
        update_error(t('.error'))
      end

    end
  end


  def information

  end


  def destroy
    @shf_application = ShfApplication.find(params[:id]) # we don't need to fetch the categories
    @shf_application.destroy
    redirect_to shf_applications_url, notice: t('shf_applications.application_deleted')
  end


  def start_review
    simple_state_change(:start_review!, t('.success'), t('.error'))
  end


  def accept

    begin
      @shf_application.accept!
      helpers.flash_message(:notice, t('shf_applications.accept.success'))
      redirect_to edit_shf_application_url(@shf_application)
      return
    rescue => e
      helpers.flash_message(:alert, t('.error') + e.message)
      redirect_to edit_shf_application_path(@shf_application)
    end
  end


  def reject
    simple_state_change(:reject!, t('shf_applications.reject.success'), t('.error'))
  end


  def need_info
    simple_state_change(:ask_applicant_for_info!, t('.success'), t('.error'))
  end


  def cancel_need_info

    # empty out the reason for waiting info
    @shf_application.waiting_reason = nil
    @shf_application.custom_reason_text = nil

    simple_state_change(:cancel_waiting_for_applicant!, t('.success'), t('.error'))
  end


  private

  def rendering(format, params)
    format.html do
      helpers.flash_message(:notice, t('.success'))
      redirect_to define_path(evaluate_update(params))
    end
  end

  def define_path(user_deleted_file)
    return edit_shf_application_path(@shf_application) if user_deleted_file
    shf_application_path(@shf_application)
  end

  def evaluate_update(params)
    params.has_key?('uploaded_files_attributes').&('_destroy')
  end

  def shf_application_params
    params.require(:shf_application).permit(*policy(@shf_application || ShfApplication).permitted_attributes)
  end


  def get_shf_application
    @shf_application = ShfApplication.find(params[:id])
    @categories = @shf_application.business_categories
  end


  def authorize_shf_application
    @shf_application.nil? ? (authorize ShfApplication) : (authorize @shf_application)
  end


  def check_and_mark_if_ready_for_review(app_params)
    if app_params.fetch('marked_ready_for_review', false) && app_params['marked_ready_for_review'] != "0"
      @shf_application.is_ready_for_review!
    end
  end


  def set_other_waiting_reason
    @other_waiting_reason_value = '-1'
    @other_waiting_reason_text = t('admin_only.member_app_waiting_reasons.other_custom_reason')
  end


  def set_allowed_file_types
    @allowed_file_types = UploadedFile::ALLOWED_FILE_TYPES
  end


  def new_file_uploaded(params)

    successful = true

    if (uploaded_files = params['uploaded_file'])

      uploaded_files['actual_files']&.each do |uploaded_file|

        @uploaded_file = @shf_application.uploaded_files.create(actual_file: uploaded_file)

        if @uploaded_file.valid?
          helpers.flash_message(:notice, t('shf_applications.uploads.file_was_uploaded',
                                           filename: @uploaded_file.actual_file_file_name))
          successful = successful & true
        else
          @shf_application.uploaded_files.delete(@uploaded_file)
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
      @shf_application.send state_method
      helpers.flash_message(:notice, success_msg)
      render :show
    rescue => e
      helpers.flash_message(:error, error_msg + e.message)
      render :show
    end
  end


  def create_error(error_message)
    helpers.flash_message(:alert, error_message)
    @all_business_categories = BusinessCategory.all
    render :new
  end


  def update_error(error_message)

    if request.xhr?
      render json: @shf_application.errors.full_messages, status: :unprocessable_entity if request.xhr?
    else
      helpers.flash_message(:alert, error_message)
      load_update_objects
      render :edit
    end

  end

  def load_update_objects
    @all_business_categories = BusinessCategory.all
    @new_company = Company.new   # In case user wants to create a new company
  end

  def set_companies_for_application
    if (company = Company.find_by_company_number(params[:company_number]))
      @company = company
      @shf_application.companies = [company]
    else
      @company = Company.new(company_number: params[:company_number])
      # @shf_application.companies.clear
    end
  end


  def send_new_app_emails(new_shf_app)

    ShfApplicationMailer.acknowledge_received(new_shf_app).deliver_now
    send_new_shf_application_notice_to_admins(new_shf_app)

  end


  def send_new_shf_application_notice_to_admins(new_shf_app)
    User.admins.each do |admin|
      AdminMailer.new_shf_application_received(new_shf_app, admin).deliver_now
    end
  end


end
