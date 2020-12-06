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
    @uploaded_file = UploadedFile.new
    @allowed_file_types_list = allowed_file_types.values.join(',')
  end

  def edit
  end

  def create
    @uploaded_file = UploadedFile.create(description: uploaded_file_params['description'])
    @uploaded_file.user = current_user
    @uploaded_file.actual_file = params['actual_file']

    respond_to do |format|
      if @uploaded_file.save
        format.html { redirect_to user_uploaded_file_path(current_user, @uploaded_file),
                                  notice: t('.success', file_name: @uploaded_file.actual_file_file_name)}
        format.json { render :show, status: :created, location: user_uploaded_file_path(current_user, @uploaded_file) }
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
    @uploaded_file.destroy
    respond_to do |format|
      format.html { redirect_to user_uploaded_files_url(current_user), notice: t('.success', file_name: @uploaded_file.actual_file_file_name) }
      format.json { head :no_content }
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
