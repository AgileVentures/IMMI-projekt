class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :authorize_company, only: [:update, :show, :edit, :destroy]


  def index
    authorize Company

    # This action is invoked by 1) loading the index page, or,
    # 2) moving to another pagination page in the companies listing table, or,
    # 3) sorting on one of the table columns, or,
    # 4) executing a companies search from the index page, or
    # 5) changing the number of items to show in the pagination table on that page.

    # In case #1, params[:q] will be nil as no query has been executed.
    # In case #2, params[:q] will specify the search criteria in a hash (the
    #             pagination links include the search criteria as URL query params).
    # In case #3, params[:q] will specify the search criteria, the column
    #             to be sorted, and the sort order (asc or desc). (the
    #             sort links include the search and sort criteria)
    # In case #4, params[:q] will contain the search criteria from the search form.
    # In case #5, params[:q] will be nil.  In this case, we will load the
    #             cached search criteria from session.

    if params[:items_count]  # << this is case 5
      items_count = params[:items_count]
      @items_count = items_count == 'All' ? 'All' : items_count.to_i

      session[:company_items_count] = @items_count

      search_criteria = JSON.parse(session[:company_search_criteria])

      action_params = search_criteria ?
        ActionController::Parameters.new(search_criteria) : nil

      # Reset params "hash" so that sort_link works correctly in the view
      # (the sort links are built using, as one input, the controller params)
      params[:q] = action_params
      params.delete(:items_count)

    else
      @items_count = session[:company_items_count] ?
        session[:company_items_count] : 10

      session[:company_search_criteria] = params[:q].to_json

      action_params = params[:q]
    end

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

    if @items_count == 'All'
      @companies = @all_companies.page(params[:page])
        .per_page(ApplicationHelper::ALL_ITEMS)
    else
      @companies = @all_companies.page(params[:page]).per_page(@items_count)
    end

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
