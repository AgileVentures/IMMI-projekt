class CompaniesController < ApplicationController
  include PaginationUtility

  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :authorize_company, only: [:update, :show, :edit, :destroy]

  def index
    authorize Company

    action_params, @items_count, items_per_page = process_pagination_params('company')

    @search_params = Company.ransack(action_params)

    # only select companies that are 'complete'; see the Company.complete scope

    @all_companies =  @search_params.result(distinct: true)
                          .complete
                          .includes(:business_categories)
                          .includes(addresses: [ :region, :kommun ])
                          .joins(addresses: [ :region, :kommun ])

    # The last qualifier ("joins") on above statement ("addresses: :region") is
    # to get around a problem with DISTINCT queries used with ransack when also
    # allowing sorting on an associated table column ("region" in this case)
    # https://github.com/activerecord-hackery/ransack#problem-with-distinct-selects

    @all_visible_companies = @all_companies.address_visible

    @all_visible_companies.each { | co | geocode_if_needed co  }

    @companies = @all_companies.page(params[:page]).per_page(items_per_page)

    render partial: 'companies_list' if request.xhr?
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

    Ckeditor::Picture.images_category = 'company_' + @company.id.to_s
    Ckeditor::Picture.for_company_id  = @company.id

  end


  def create
    authorize Company

    @company = Company.new( sanitize_website(company_params) )

    if @company.save
      redirect_to @company, notice: t('.success')
    else
      flash.now[:alert] = t('.error')
      render :new
    end
  end


  def update
    if @company.update( sanitize_website(company_params) )
      redirect_to @company, notice: t('.success')
    else
      flash.now[:alert] = t('.error')
      render :edit
    end
  end


  def destroy

    if @company.destroy
      redirect_to companies_url, notice: t('companies.destroy.success')
    else
      translated_errors = helpers.translate_and_join(@company.errors.full_messages)
      helpers.flash_message(:alert, "#{t('companies.destroy.error')}: #{translated_errors}")
      redirect_to @company
    end

  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.includes(:addresses).find(params[:id])
    geocode_if_needed @company
  end


  def geocode_if_needed(company)
    needs_geocoding = company.addresses.reject(&:geocoded?)
    needs_geocoding.each(&:geocode_best_possible)
    company.save!  if needs_geocoding.count > 0
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def company_params
    params.require(:company).permit(:name, :company_number, :phone_number,
                                    :email,
                                    :website,
                                    :description,
        addresses_attributes: [:id,
                                :street_address,
                                :post_code,
                                :kommun_id,
                                :city,
                                :region_id,
                                :country,
                                :visibility])
  end


  def authorize_company
    authorize @company
  end


  def sanitize_website(params)
    params['website'] = URLSanitizer.sanitize( params.fetch('website','') )
    params
  end

end
