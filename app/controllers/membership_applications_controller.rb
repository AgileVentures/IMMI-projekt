class MembershipApplicationsController < ApplicationController
  before_action :get_membership_application, only: [:show, :edit, :update]
  before_action :authorize_membership_application, only: [:update, :show, :edit]


  def new
    @membership_application = MembershipApplication.new
    @all_business_categories = BusinessCategory.all
    @uploaded_file = @membership_application.uploaded_files.build
  end


  def index
    authorize MembershipApplication
    @membership_applications = MembershipApplication.all
  end


  def show
    @categories = @membership_application.business_categories
  end


  def edit
    @all_business_categories = BusinessCategory.all
  end


  def create
    @membership_application = current_user.membership_applications.new(membership_application_params)
    if @membership_application.save
      new_upload_file params['uploaded_file'] if params['uploaded_file']

      helpers.flash_message(:notice,
                            'Tack, din ansökan har skickats.')
      redirect_to root_path
    else
      helpers.flash_message(:alert,
                            'Ett eller flera problem hindrade din ansökan från att skickas.')
      render :new
    end
  end


  def update
    if @membership_application.update(membership_application_params)

      new_upload_file params['uploaded_file'] if params['uploaded_file']

      if changed_to_accepted?(params['membership_application'])
        accept_application
        redirect_to edit_membership_application_url(@membership_application)
        return
      end

      helpers.flash_message(:notice,
                            'Ansökan har uppdaterats.')
      render :show
    else
      helpers.flash_message(:alert,
                            'Ett eller flera problem hindrade din ansökan från att sparas.')
      redirect_to edit_membership_application_path(@membership_application)
    end
  end


  private
  def membership_application_params
    params.require(:membership_application).permit(*policy(@membership_application || MembershipApplication).permitted_attributes)
  end


  def get_membership_application
    @membership_application = MembershipApplication.find(params[:id])
  end


  def authorize_membership_application
    authorize @membership_application
  end


  def changed_to_accepted?(params)
    params.include?('status') && params['status'] =='Godkänd'
  end


  def accept_application

    @membership_application.user.is_member = true
    unless (company = Company.find_by_company_number(@membership_application.company_number))
      company = Company.create!(company_number: @membership_application.company_number,
                                email: @membership_application.contact_email)
    end

    @membership_application.company = company
    @membership_application.save!

    helpers.flash_message(:notice,
                          'Var god ange medlemsnummer och spara.')

  end


  def new_upload_file(upload_file_param)
    if upload_file_param['actual_files']
      upload_file_param['actual_files'].each do |upload_file|

        @uploaded_file = @membership_application.uploaded_files.create(actual_file: upload_file)
        if @uploaded_file.valid?
          helpers.flash_message(:notice,
                                "Filen laddades upp: #{@uploaded_file.actual_file_file_name}")
        else
          helpers.flash_message :alert, @uploaded_file.errors.messages
        end
      end

    end
  end
end
