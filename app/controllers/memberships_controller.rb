class MembershipsController < ApplicationController
  def new
    @membership = MembershipApplication.new
  end

  def create
    @membership = current_user.membership_applications.new(membership_params)
    if @membership.save
      flash[:notice] = 'Thank you, Your application has been submitted'
      redirect_to root_path
    else
      render :new
    end
  end

  def index
    @membership_applications = MembershipApplication.all
  end

  def show
    @membership = MembershipApplication.find(params[:id])
  end

  def edit
    @membership = current_user.membership_applications.last
  end

  def update

  end


  private
  def membership_params
    params.require(:membership_application).permit(:company_name,
                                                   :company_number,
                                                   :contact_person,
                                                   :company_email,
                                                   :phone_number)
  end
end
