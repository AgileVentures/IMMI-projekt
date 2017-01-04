class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update]
  before_action :authorize_company, only: [:update, :show, :edit]


  def index
    authorize Company
    @search_params = Company.ransack(params[:q])
    @companies = @search_params.result(district: true).to_a.uniq
  end


  def show
    @categories = @company.business_categories
  end


  def new
    authorize Company
    @company = Company.new
    @all_business_categories = BusinessCategory.all
  end


  def edit
    @all_business_categories = BusinessCategory.all
  end


  def create
    authorize Company
    @company = Company.new(company_params)

    if @company.save
      redirect_to @company, notice: t('.success')
    else
      flash[:alert] = t('.error')
      render :new
    end
  end


  def update
    if @company.update(company_params)
      redirect_to @company, notice: t('.success')
    else
      flash[:alert] = t('.error')
      render :edit
    end

  end



  private
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def company_params
    params.require(:company).permit(:name, :company_number, :phone_number,
                                    :email, :street, :post_code, :city,
                                    :region_id, :website,
                                    {business_category_ids: []})
  end

  def authorize_company
    authorize @company
  end

end
