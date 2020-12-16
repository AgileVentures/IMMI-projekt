require 'company_locator'

class CompaniesController < ApplicationController
  include SetAppConfiguration
  include PaginationUtility
  include ImagesUtility

  before_action :set_company, only: [:show, :edit, :update, :destroy,
                                     :edit_payment, :fetch_from_dinkurs,
                                     :company_h_brand]
  before_action :authorize_company, only: [:update, :show, :edit, :destroy]
  before_action :set_app_config, only: [:company_h_brand]
  before_action :allow_iframe_request, only: [:company_h_brand]


  def index
    authorize Company

    self.params = fix_FB_changed_q_params(self.params)
    self.params = remove_sort_by_business_categories(self.params)
    self.params = adjust_city_match_names(self.params)

    action_params, @items_count, items_per_page = process_pagination_params('company')

    @search_params = Company.ransack(action_params)

    # only select companies that are 'complete'; see the Company.complete scope
    @all_companies = @search_params.result(distinct: true)
                         .includes(:business_categories)
                         .includes(addresses: [:region, :kommun])
                         .joins(addresses: [:region, :kommun])
                         .order(company_order)

    # The last qualifier ("joins") on above statement ("addresses: :region") is
    # to get around a problem with DISTINCT queries used with ransack when also
    # allowing sorting on an associated table column ("region" in this case)
    # https://github.com/activerecord-hackery/ransack#problem-with-distinct-selects


    if current_user.admin?
      @all_visible_companies = @all_companies
      @addresses_select_list = Address.select(:city).distinct
                                 .sort { |a,b| a.city.downcase.strip <=> b.city.downcase.strip }
    else
      @all_companies = @all_companies.searchable
      @all_visible_companies = @all_companies.address_visible

      addresses = []
      @all_visible_companies.each do |company|
        company.addresses.where.not(visibility: 'none').select(:city).each do |address|
          addresses << address
        end
      end

      @addresses_select_list = addresses.uniq { |a| a.city.downcase.strip }
                                .sort { |a,b| a.city.downcase.strip <=> b.city.downcase.strip }
    end

    @all_visible_companies.each { |co| geocode_if_needed co }

    if params.include? :near
      addresses = get_addresses_near(params[:near])
      @all_companies = @all_companies.at_addresses( addresses)
    end

    @companies = @all_companies.page(params[:page]).per_page(items_per_page)

    respond_to do |format|
      format.html

      format.js do
        list_html = render_to_string(partial: 'companies_list',
                                     locals: { companies: @companies,
                                               search_params: @search_params })

        if params[:page]  # handling a pagination request - update companies list
          render json: { list_html: list_html }
        else              # handling a search request

          markers = helpers.location_and_markers_for(@all_visible_companies)

          map_html = render_to_string(partial: 'map_companies',
                                      locals: { markers: markers })

          render json: { list_html: list_html, map_html: map_html }
        end
      end
    end
  end


  def show
    setup_events_and_events_pagination
    set_meta_tags_for_company(@company)

    @applications = @company.shf_applications
                            .includes(:user, :business_categories, :shfapplications_business_categories)

    show_events_list if request.xhr?
  end

  def company_h_brand
    # params[:render_to] is present for a request that will respond with
    #   a JPG image for download.  The request expects an HTML response.
    # params[:format] is present with a request that will respond with
    #   a JPG image to be rendered inline in the client. (request URL has
    #   suffix ".jpg", and expects a JPG image in response)
    # Otherwise, the request expects HTML.

    if params[:render_to] == 'jpg' || params[:format] == 'jpg'
      image = @company.h_brand_jpg

      unless image
        image = create_image('company_h_brand', 300, @app_configuration, @company)
        @company.h_brand_jpg = image
      end

      download_image('company_h_brand', image)

    else
      image_html = image_html('company_h_brand', @app_configuration, @company,
                              context: params[:context]&.to_sym)
      show_image(image_html)
    end
  end

  def fetch_from_dinkurs
    raise 'Unsupported request' unless request.xhr?

    @company.fetch_dinkurs_events
    @company.reload

    setup_events_and_events_pagination

    show_events_list
  end

  def setup_events_and_events_pagination

    entity = "company_#{@company.id}_events"
    __, @items_count, items_per_page = process_pagination_params(entity)

    @events = @company.events.order(:start_date)
                .page(params[:page])
                .per_page(items_per_page)
  end

  def show_events_list
    render partial: 'events/teaser_list',
           locals: { events: @events, company: @company, items_count: @items_count }
  end

  def new
    authorize Company
    @company = Company.new

    @all_business_categories = BusinessCategory.all
  end


  def edit
    @all_business_categories = BusinessCategory.all

    Ckeditor::Picture.images_category = 'company_' + @company.id.to_s
    Ckeditor::Picture.for_company_id = @company.id

  end


  def create
    authorize Company

    @company = Company.new(sanitize_params(company_params))

    saved = @company.save

    unless request.xhr?
      if saved
        if @company.valid_key_and_fetch_dinkurs_events?(on_update: false)
          redirect_to @company, notice: t('.success')
        else
          helpers.flash_message(:notice, t('.success_with_dinkurs_problem'))
          render :edit
        end
      else
        flash.now[:alert] = t('.error')
        render :new
      end
      return
    end

    # XHR request from modal in ShfApplication create view (to create company)
    if saved
      status = 'ok'
      id = 'shf_application_company_number'
      value = @company.company_number
    else
      status = 'errors'
      id = 'company-create-errors'
      value = helpers.model_errors_helper(@company)
    end

    render json: { status: status, id: id, value: value }
  end


  def update
    cmpy_params = sanitize_params(company_params)

    @company.assign_attributes(cmpy_params)

    if (company_valid = @company.valid?)
      # Will add model error if key is not blank and not valid:
      dinkurs_key_ok = @company.valid_key_and_fetch_dinkurs_events?
    else
      dinkurs_key_ok = true
    end

    if company_valid && dinkurs_key_ok
      @company.update(cmpy_params)
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


  def edit_payment
    raise 'Unsupported request' unless request.xhr?
    authorize Company

    payment = @company.most_recent_branding_payment
    payment.update!(payment_params) if payment

    render partial: 'branding_term_status', locals: { company: @company }

  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
    render partial: 'branding_term_status',
           locals: { company: @company, error: t('companies.update.error') }
  end

  def show_companies_list

    render partial: 'companies_list', locals: { companies: @companies,
                                                search_params: @search_params } if request.xhr?
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
    company.save! if needs_geocoding.count > 0
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def company_params
    params.require(:company).permit(:name, :company_number, :phone_number,
                                    :email,
                                    :website,
                                    :facebook_url,
                                    :instagram_url,
                                    :youtube_url,
                                    :description,
                                    :dinkurs_company_id,
                                    :show_dinkurs_events,
                                    addresses_attributes: [:id,
                                                           :street_address,
                                                           :post_code,
                                                           :kommun_id,
                                                           :city,
                                                           :region_id,
                                                           :country,
                                                           :visibility])
  end


  def payment_params
    params.require(:payment).permit(:expire_date, :notes)
  end


  def authorize_company
    authorize @company
  end


  def sanitize_params(params)
    params['website'] = InputSanitizer.sanitize_url(params.fetch('website', ''))
    params['facebook_url'] = InputSanitizer.sanitize_url(params.fetch('facebook_url', ''))
    params['instagram_url'] = InputSanitizer.sanitize_url(params.fetch('instagram_url', ''))
    params['youtube_url'] = InputSanitizer.sanitize_url(params.fetch('youtube_url', ''))
    params['description'] = InputSanitizer.sanitize_html(params.fetch('description', ''))
    params
  end


  def get_addresses_near(near_params)

    # It might be necessary to Sanitize the distance argument, depending on how the interface is handled
    if near_params.fetch(:distance,false)
      distance_f = near_params[:distance].to_f
    else
      distance_f = nil # CompanyLocator can handle this
    end

    # have to be searching either near a :name OR near coordinates (:latitude and :longitude)
    if near_params.include? :name
      addresses_near_name(near_params, distance_f)
    else
      addresses_near_coordinates(near_params, distance_f)
    end

  end

  def addresses_near_name(near_params, distance)
    santized_name =  InputSanitizer.sanitize_string(near_params.fetch(:name, ''))
    CompanyLocator.find_near_name( santized_name, distance)
  end

  def addresses_near_coordinates(near_params, distance)
    lat = near_params.fetch(:latitude, nil)
    long = near_params.fetch(:longitude, nil)
    CompanyLocator.find_near_coordinates(lat, long, distance)
  end


  BAD_BUSINESSCAT_SORT_KEY = 'business_categories_name'
  # We no longer can sort by BusinessCategories.  But bots still have that info cached
  # and we still get requests coming in with it.
  #
  # If the parameters has a sort by business categories name part,
  # remove the sort part from the params so we (via Ransack) don't throw an error.
  #
  # @return [ActionController::Parameter] - the params with the offending sort info removed.
  def remove_sort_by_business_categories(params)

    if !(sort_param = params.dig('q', 's')).nil? && sort_param.split(' ').first == BAD_BUSINESSCAT_SORT_KEY
      # remove the sort part of the params
      params['q'] = params['q'].except('s')
    end

    params
  end

  def adjust_city_match_names(params)
    # Remove leading and trailing whitespace for city names and set up "LIKE" match

    return params unless (city_matches = params[:q]&.[]('addresses_city_matches_any'))

    params[:q]['addresses_city_matches_any'] = city_matches.map do |v|
      if v.empty?
        v
      else
        '%' + v.strip + '%'
      end
    end
    params
  end


  # set the meta tags for the this specific company
  def set_meta_tags_for_company(company)
    co_meta_info = CompanyMetaInfoAdapter.new(company)

    set_meta_tags title: co_meta_info.title,
                  description: co_meta_info.description,
                  keywords: co_meta_info.keywords,
                  og: { title: helpers.full_page_title( page_title: co_meta_info.title),
                        description: co_meta_info.og[:description] }

  end

  # Set the scope for putting a list of companies in order.
  # Right now this just returns the updated_at, sorted by desc (most recently updated = first)
  #
  # @return [Hash | String] - the arguments to use in the .order  method
  def company_order
    {updated_at: :desc}
  end
end
