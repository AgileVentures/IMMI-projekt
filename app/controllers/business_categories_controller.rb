class BusinessCategoriesController < ApplicationController
  before_action :set_business_category, only: [:show, :edit, :update, :destroy]
  before_action :authorize_business_category, only: [:update, :show, :edit, :destroy]


  def index
    authorize BusinessCategory
    @business_categories = BusinessCategory.all
  end


  def show

    @companies = @business_category.companies.includes(:addresses).complete.order(:name)

  end


  def new
    authorize BusinessCategory
    @business_category = BusinessCategory.new
  end


  def edit
  end


  def create
    authorize BusinessCategory
    @business_category = BusinessCategory.new(business_category_params)

    if @business_category.save
      redirect_to @business_category, notice: t('.success')
    else
      render :new
    end
  end


  def update
    if @business_category.update(business_category_params)
      redirect_to @business_category, notice: t('.success')
    else
      render :edit
    end

  end


  def destroy
    @business_category.destroy

    redirect_to business_categories_url, notice: t('.success')

  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_business_category
    @business_category = BusinessCategory.find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def business_category_params
    params.require(:business_category).permit(:name, :description)
  end


  def authorize_business_category
    authorize @business_category
  end
end
