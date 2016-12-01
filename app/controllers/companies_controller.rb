class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :authorize_company, only: [:update, :show, :edit, :destroy]


  def index
    authorize Company
    @companies = Company.all
  end


  def show
  end


  def new
    authorize Company
    @company = Company.new
  end


  def edit
  end


  def create
    authorize Company
    @company = Company.new(company_params)

    if @company.save
      redirect_to @company, notice: 'The company was successfully created.'
    else
      render :new
    end
  end


  def update
    if @company.update(company_params)
      redirect_to @company, notice: 'The company was successfully updated.'
    else
      render :edit
    end

  end


  def destroy
    @company.destroy

    redirect_to companies_url, notice: 'The company was successfully deleted.'

  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def company_params
    params.require(:company).permit(:name, :company_number, :phone_number, :email, :street, :post_code, :city, :region, :website)
  end

  def authorize_company
    authorize @company
  end
end
