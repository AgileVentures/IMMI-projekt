class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :authorize_company, only: [:update, :show, :edit, :destroy]


  def index
    authorize Company

    @search_params = Company.ransack(params[:q])
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

    @companies = @all_companies.page(params[:page]).per_page(10)

    render partial: 'companies_list' if request.xhr?
  end


  def show
    @categories = @company.business_categories
    @company.addresses << Address.new  if @company.addresses.count == 0
  end


  def new
    authorize Company
    @company = Company.new
    @addresses = @company.addresses.build

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
    @company.main_address.addressable = @company  # not sure why Rails doesn't assign this automatically

    if @company.save
      redirect_to @company, notice: t('.success')
    else
      flash.now[:alert] = t('.error')
      render :new
    end
  end


  def update
    # Get company params and address params separately. This is because we need
    #   to update the company first (in case address_visibility changed).
    # (Normally the address would be updated *before* the company.
    #   If that happened, then the gecoding for the address could be
    #   using the "old" address_visibility.)

    cmpy_params = company_params
    addr_params = cmpy_params.delete(:addresses_attributes)['0']

    address = @company.main_address
    address.assign_attributes(addr_params)

    if address.valid? && @company.update( sanitize_website(cmpy_params) )

      address.save if address.changed?

      # We need to geocode the address if 1) address_visibility has changed, and
      # 2) address did not change (geocoding happens automatically upon save)

      if @company.previous_changes.include?('address_visibility') && !address.changed?
        address.reload # get latest version of company object
        address.geocode_best_possible
        address.save
      end

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
                                    :address_visibility,
                                    {business_category_ids: []},
        addresses_attributes: [:id,
                                :street_address,
                                :post_code,
                                :kommun_id,
                                :city,
                                :region_id,
                                :country])
  end


  def authorize_company
    authorize @company
  end


  def sanitize_website(params)
    params['website'] = URLSanitizer.sanitize( params.fetch('website','') )
    params
  end

end
