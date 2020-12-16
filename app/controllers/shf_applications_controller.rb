class ShfApplicationsController < ApplicationController

  include RobotsMetaTagAllActions
  include PaginationUtility

  before_action :get_shf_application, except: [:information, :index, :new, :create]
  before_action :authorize_shf_application, except: [:get_edit_row_business_category,
                                                     :get_display_row_business_category,
                                                     :business_subcategories]
  before_action :set_other_waiting_reason,
    only: [:show, :edit, :update_reason_waiting, :need_info]
  before_action :set_allowed_file_types, only: [:edit, :new, :update, :create]

  def new
    unless current_user.has_full_name?
      msg = t('.need_to_enter_name_html',
              edit_profile: helpers.link_to(t('devise.registrations.edit.title'),
              edit_user_registration_path))
      helpers.flash_message(:alert, msg)
      redirect_back(fallback_location: root_path) and return
    end
    @new_company = Company.new # object for company_create_modal
    @shf_application = ShfApplication.new(user: current_user)
    @all_business_categories = BusinessCategory.all.roots.order(:name)
    @uploaded_file = @shf_application.uploaded_files.build
  end


  def index
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

    respond_to :js, :html
  end


  def show
    @categories = @shf_application.business_categories
  end

  def get_edit_row_business_category
    business_category = BusinessCategory.find(params[:business_category_id])
    subcategories = @shf_application.business_subcategories(business_category)

    edit_row = render_to_string(partial: 'business_category_edit_row',
                                locals: { shf_application: @shf_application,
                                          business_category: business_category,
                                          subcategories: subcategories,
                                          language: @locale })
    respond_to do |format|
      format.js do
        render json: { business_category_id: business_category.id,
                       edit_row: edit_row }
      end
    end
  end

  def get_display_row_business_category
    business_category = BusinessCategory.find(params[:business_category_id])
    display_row = render_to_string(partial: 'business_category_display_row',
                                   locals: { shf_application: @shf_application,
                                             business_category: business_category })

    respond_to do |format|
      format.js do
        render json: { business_category_id: business_category.id,
                       display_row: display_row }
      end
    end
  end

  def business_subcategories
    business_category = BusinessCategory.find(params[:business_category_id])

    @shf_application.set_business_subcategories(business_category,
                          BusinessCategory.where(id: params[:subcategories]))

    display_row = render_to_string(partial: 'business_category_display_row',
                                   locals: { shf_application: @shf_application,
                                             business_category: business_category })

    respond_to do |format|
      format.js do
        render json: { business_category_id: business_category.id,
                       display_row: display_row }
      end
    end
  end


  def edit
    load_update_objects(@shf_application.company_numbers)
  end


  def create
    @shf_application = ShfApplication.new(shf_application_params
                                          .merge(user: current_user))

    numbers_str = params[:company_number]

    companies_and_numbers, all_valid = validate_company_numbers(@shf_application,
                                                                numbers_str)

    @shf_application.companies = companies_and_numbers[:companies] if all_valid

    file_delivery_selected = user_selected_file_delivery_option?

    if all_valid && @shf_application.save

      if process_upload_files_without_error?(params)

        unless set_flash_messages_for_missing_application_files?(@shf_application,
                                                                file_delivery_selected,
                                                                'create')
          helpers.flash_message(:notice,
                                t('.success', email_address: @shf_application.contact_email))
        end

        redirect_to user_path(@shf_application.user)

      else
        helpers.flash_message(:notice, t('.success_with_file_problem'))
        load_update_objects(numbers_str)
        render :edit
      end

      send_new_app_emails(@shf_application)
    else
      create_or_update_error(t('.error'), companies_and_numbers, numbers_str, :new)
    end
  end


  def update
    numbers_str = params[:company_number]

    companies_and_numbers, all_valid = validate_company_numbers(@shf_application,
                                                                numbers_str)

    @shf_application.companies = companies_and_numbers[:companies] if all_valid

    file_delivery_selected = user_selected_file_delivery_option?

    if all_valid && @shf_application.update(shf_application_params) && process_upload_files_without_error?(params)

      check_and_mark_if_ready_for_review(params['shf_application'])

      unless set_flash_messages_for_missing_application_files?(@shf_application,
                                                              file_delivery_selected,
                                                              'update')
        helpers.flash_message(:notice, t('.success'))
      end

      redirect_to define_path(evaluate_update(params))
    else

      create_or_update_error(t('.error'), companies_and_numbers, numbers_str, :edit)
    end
  end

  def remove_attachment
    if @shf_application.update(shf_application_params)

      respond_to do |format|
        format.js do
          uploaded_html = render_to_string(partial: 'uploaded_files_list',
                                           locals: { shf_application: @shf_application })
          render json: { uploaded_html: uploaded_html, status: :ok }
        end
      end
    else
      respond_to do |format|
        format.js { render json: { status: :unprocessable_entity } }
      end
    end
  end

  def update_reason_waiting

    if (reason_id = params[:member_app_waiting_reasons])

      if reason_id == @other_waiting_reason_value
        render plain: 'true' and return
      end

      @shf_application
          .update(member_app_waiting_reasons_id: reason_id,
                  custom_reason_text: nil)
    else

      @shf_application.update(custom_reason_text: params[:custom_reason_text],
                              member_app_waiting_reasons_id: nil)
    end

    head :ok

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
    rescue => exception
      helpers.flash_message(:alert, t('.error') + exception.message)
    ensure
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

  def set_flash_messages_for_missing_application_files?(shf_application,
                                                       file_delivery_selected,
                                                       action)

    return false if shf_application.uploaded_files.present?

    helpers.flash_message(:notice,
      t("shf_applications.#{action}.success_with_app_files_missing"))

    if file_delivery_selected

      if shf_application.file_delivery_method.default_option
        helpers.flash_message(:warn,
          t("shf_applications.#{action}.upload_file_or_select_method"))
      else
        helpers.flash_message(:warn,
          t("shf_applications.#{action}.remember_to_deliver_files"))
      end

    else

      helpers.flash_message(:warn,
        t("shf_applications.#{action}.upload_file_or_select_method"))
    end
    true
  end

  def user_selected_file_delivery_option?
    file_delivery_selected = false

    method_id = params[:shf_application][:file_delivery_method_id]
    current_method = @shf_application.file_delivery_method

    if method_id.present? && (!current_method || current_method.id != method_id)
      @shf_application.file_delivery_selection_date = Date.current
      file_delivery_selected = true
    end

    file_delivery_selected
  end

  def define_path(user_deleted_file)
    return edit_shf_application_path(@shf_application) if user_deleted_file
    shf_application_path(@shf_application)
  end

  def evaluate_update(params)
    params.dig(:shf_application, :uploaded_files_attributes)&.key?('_destroy')
  end

  def shf_application_params
    params.require(:shf_application).permit(*policy(@shf_application || ShfApplication).permitted_attributes)
  end


  def get_shf_application
    @shf_application = ShfApplication.find(params[:id])
    @categories = @shf_application.business_categories
  end


  def authorize_shf_application
    @shf_application ? (authorize @shf_application) : (authorize ShfApplication)
  end


  def check_and_mark_if_ready_for_review(app_params)
    return unless app_params

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


  def process_upload_files_without_error?(params)
    # Returns true if no errors, false otherwise
    # (*true* return value does NOT mean that one or more files were actually uploaded)

    successful = true

    if (uploaded_files = params['uploaded_file'])

      uploaded_files['actual_files']&.each do |uploaded_file|

        # An admin might be uploading a file for a users's application.
        # The uploaded file should belong_to the user, not the admin.
        @uploaded_file = @shf_application.uploaded_files.create(actual_file: uploaded_file,
                                                                user: @shf_application.user)

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
    end

    successful
  end


  def simple_state_change(state_method, success_msg, error_msg)
    begin
      @shf_application.send state_method
      helpers.flash_message(:notice, success_msg)
    rescue => exception
      helpers.flash_message(:error, error_msg + exception.message)
    ensure
      render :show
    end
  end


  def create_or_update_error(error_message, companies_and_numbers,
                             company_numbers_str, render_me)

    # User.accepts_nested_attributes_for :shf_application will add a second
    # validation - for the file delivery method - to the model errors hash.
    # This means model errors will have 2 errors for the same problem (File
    # delivery method not selected by the user).  This line removes one of those:
    @shf_application.errors.delete(:"user.shf_application.file_delivery_method")

    @shf_application = add_company_errors_to_model(@shf_application,
                                                   companies_and_numbers)

    error_message = add_upload_file_again_error(error_message) if params['uploaded_file']

    helpers.flash_message(:alert, error_message)
    load_update_objects(company_numbers_str)
    render render_me
  end


  def add_company_errors_to_model(application, companies_and_numbers)
    # see #validate_company_numbers for structure of companies_and_numbers

    numbers = companies_and_numbers[:numbers]
    numbers.each_index do |idx|

      unless numbers[idx]
        application.errors.add(:companies, :blank)
        break
      end

      unless companies_and_numbers[:companies][idx]
        application.errors.add(:companies, :not_found, value: numbers[idx])
      end

    end
    application
  end


  def add_upload_file_again_error(orig_error_message)
    orig_error_message + "\n" + t('shf_applications.uploads.please_upload_again')
  end


  def load_update_objects(numbers_str)
    @company_numbers = numbers_str
    @all_business_categories = BusinessCategory.all.roots.order(:name)
    @new_company = Company.new   # In case user wants to create a new company
  end

  def validate_company_numbers(application, numbers_str)
    # Validates company numbers specified in shf application form
    # (also, strips dash(es) from number since only digits allowed)
    # Returns two parameters:
    #  >> a hash with two keys:
    #     :numbers => array of company numbers
    #     :companies => array of companies (nil if not in DB)
    #  >> true/false indicating whether *all* company numbers are valid

    companies = []
    numbers   = []

    if ! numbers_str # delete-file action params do not include company numbers
      application.companies.each do |company|
        companies << company
        numbers   << company.company_number
      end
    else

      numbers_str.split(/(?:\s*,+\s*|\s+)/).each do |number|
        number = number.delete('-')

        # Remove duplicates
        next if numbers.include?(number)

        company = Company.find_by(company_number: number)

        companies << company
        numbers   << number

      end

    end

    [{ companies: companies, numbers: numbers }, ! companies.include?(nil)]
  end


  def send_new_app_emails(new_shf_app)

    begin
      ShfApplicationMailer.acknowledge_received(new_shf_app).deliver_now
    rescue => _mail_error
      helpers.flash_message(:error, t('mailers.shf_application_mailer.acknowledge_received.error_sending', email: @shf_application.user.email))
    end

    # No rescue for the following because if there is a problem sending email to the admin,
    # do not display an error to the user
    send_new_shf_application_notice_to_admins(new_shf_app) if AdminOnly::AppConfiguration.config_to_use.email_admin_new_app_received_enabled

  end


  def send_new_shf_application_notice_to_admins(new_shf_app)
    User.admins.each do |admin|
      AdminMailer.new_shf_application_received(new_shf_app, admin).deliver_now
    end
  end

end
