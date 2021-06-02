class UploadedFilesController < ApplicationController

  include PaginationUtility

  before_action :set_uploaded_file, except: [:index, :new, :create]
  before_action :authorize_uploaded_file

  def index
    uploaded_files_for_current_user = policy_scope(UploadedFile)
    @search_params = uploaded_files_for_current_user.ransack(params[:q])
    @uploaded_files = @search_params.result.includes(:user).includes(:shf_application).order(:user_id)

    respond_to :js, :html
  end

  def show
  end

  def new
    @allowed_file_types_list = allowed_file_types.values.join(',')

    # Memoize (save info) if this request came from the User account page so that we can return to it
    # after saving the new UploadedFfile
    if params.include?(:from_acct_pg)
      @request_from_acct_pg = true
    end
    @uploaded_file = UploadedFile.new
    @uploaded_file.user = current_user
  end

  def edit
  end

  def create
    @uploaded_file = UploadedFile.new(description: uploaded_file_params['description'])
    @uploaded_file.user = current_user
    @uploaded_file.actual_file = uploaded_file_params['actual_file']

    if params.fetch('_from_user_acct_page', '').blank?
      success_redirect_to_path = user_uploaded_files_path(current_user)
    else
      success_redirect_to_path = user_path(current_user)
    end

    respond_to do |format|
      if @uploaded_file.save
        format.html { redirect_to success_redirect_to_path,
                                  notice: t('.success', file_name: @uploaded_file.actual_file_file_name) }
        format.json { render :show, status: :created, location: success_redirect_to_path }
      else
        format.html { render :new }
        format.json { render json: @uploaded_file.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @uploaded_file.update(uploaded_file_params)
        format.html { redirect_to user_uploaded_file_path(current_user, @uploaded_file),
                                  notice: t('.success', file_name: @uploaded_file.actual_file_file_name) }
        format.json { render :show, status: :ok, location: user_uploaded_file_path(current_user, @uploaded_file) }
      else
        format.html { render :edit }
        format.json { render json: @uploaded_file.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    file_name = @uploaded_file.actual_file_file_name.dup

    if @uploaded_file.destroy
      respond_to do |format|
        format.html { redirect_to user_uploaded_files_url(current_user), notice: t('.success', file_name: file_name) }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html do
          translated_errors = helpers.translate_and_join(@uploaded_file.errors.full_messages)
          helpers.flash_message(:alert, "#{t('.error')}: #{translated_errors}")
          redirect_to user_uploaded_file_url(current_user, @uploaded_file)
        end
        format.json { render json: @uploaded_file.errors, status: :unprocessable_entity }
      end

    end
  end

  # ===============================================================================================
  private

  def set_uploaded_file
    @uploaded_file = policy_scope(UploadedFile).find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def uploaded_file_params
    params.require(:uploaded_file).permit(:id,
                                          :actual_file,
                                          :actual_file_file_name,
                                          :actual_file_file_size,
                                          :actual_file_content_type,
                                          :actual_file_updated_at,
                                          :description,
                                          :_destroy)
  end

  def authorize_uploaded_file
    if @uploaded_file
      authorize(@uploaded_file)
    else
      # TODO can Pundit policy scoping take care of this?
      for_user = current_user
      if params.include?(:user_id)
        for_user = User.find_by(id: params[:user_id]) if User.exists?(id: params[:user_id])
        for_user = Visitor.new if for_user.nil?
      end

      authorize(for_user, policy_class: UploadedFilePolicy) # can the current user view the user/files page of the user in params?
    end
  end

  def allowed_file_types
    UploadedFile.allowed_file_types
  end
end
