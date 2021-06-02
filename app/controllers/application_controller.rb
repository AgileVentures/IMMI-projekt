class ApplicationController < ActionController::Base

  include Pundit

  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_after_action_path, if: :devise_controller?
  before_action :store_current_location, :unless => :devise_controller?
  before_action :prepare_exception_notifier
  before_action :set_hreflang_tag_urls

  before_action :set_page_meta_robots_none

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Standardize XHR response values
  XHR_SUCCESS = 200
  XHR_SUCCESSTEXT = 'OK'
  XHR_ERROR = 500
  XHR_ERRORTEXT = 'ERROR'


  def index

  end


  # This should be called when the app is deployed to ensure that
  # exception notifications are working in the production environment, and perhaps also called periodically
  # to ensure notifications are working between deployments.
  def test_exception_notifications
    raise 'This is a just a test of the exception notifications to ensure they are working.'
  end


  protected

  def configure_permitted_parameters
    additional_permissions = [:first_name, :last_name, :member_photo,
                              { shf_application_attributes: :contact_email }]
    devise_parameter_sanitizer.permit(:sign_up, keys: additional_permissions)
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: additional_permissions + [:membership_number])
  end


  def store_current_location
    store_location_for(:user, request.url)
  end


  def set_after_action_path
    return unless self.is_a? Devise::RegistrationsController


    def self.after_update_path_for(resource)
      stored_location_for(resource) || request.referer || root_path
    end
  end


  # This sets the meta tags for a page with 'no-follow' and 'no-index' robots tags.
  # (The meta-tags gem doesn't have a 'none' method, which covers both.)
  # This should be used for pages that we do not want indexed or crawled (followed)
  # by search engine robots.
  #
  # After this is called, a child Controller or the view can add to it as needed.
  def set_page_meta_robots_none
    set_meta_tags helpers.meta_robots_none if action_should_have_robots_none_tag?(action_name)
  end


  # Test for checking if an action should have the meta tag. Child classes can
  # always return true, for example, if all of the actions should have the tag,
  # or use pattern matching, etc.
  #
  # A child Controller cannot 'override' a before_action with a list of only: actions.
  # So instead we need to use this construct: Always call the before_action method and then
  # do a further test to see if something that can be done; child classes can override that
  # 'further test' (this method).
  #
  # Do not put the tag on pages that Visitors can see.
  # It is hard to do that cleanly using just the Pundit policy without knowing
  # the Model class as well. Instead, use this default list of actions.
  def action_should_have_robots_none_tag?(action_name = '')
    !actions_do_not_put_robots_tag?.include?(action_name.to_sym)
  end


  def actions_do_not_put_robots_tag?
    [:index, :show]
  end


  # Template method (wrapper) for handling an XHR request.
  # --> Expects the yield to return a Hash of information
  #     that will be merged into the response data rendered as JSON
  #     and sent back to the XHR requester.
  #
  def handle_xhr_request
    status = XHR_ERROR
    status_text = XHR_ERRORTEXT
    error_text = ''
    additional_response_data = {}

    begin
      validate_and_authorize_xhr

      additional_response_data = additional_response_data.merge(yield)
      status = XHR_SUCCESS
      status_text = XHR_SUCCESSTEXT

    rescue => error
      error_text = error.message

    ensure
      response_data = { status: status,
                        statusText: status_text,
                        errorText: error_text }.merge(additional_response_data)

      render json: response_data
    end
  end


  # Subclasses should redefine this to authorize as needed.
  # Ex:  a UserChecklistsController might define it as:
  #
  #   def validate_and_authorize_xhr
  #     super
  #     authorize_user_checklist_class  # this is the additional authorization
  #   end
  #
  def validate_and_authorize_xhr
    validate_xhr_request
  end


  # =======================================================================


  private

  def set_locale
    @locale = I18n.default_locale
    @locale = params[:locale].to_s if params[:locale].present?
    I18n.locale = @locale
    @language_change_allowed = request.get? || (self.is_a? Devise::SessionsController)
  end


  def default_url_options
    { locale: I18n.locale }
  end


  def after_sign_in_path_for(signed_in_user)
    return admin_root_path if signed_in_user.admin?

    user_path(signed_in_user)
  end


  def user_not_authorized
    if user_signed_in?
      flash[:alert] = t('errors.not_permitted')
      fallback_location = root_path
    else
      flash[:alert] = t('errors.not_permitted') + ' ' + t('errors.try_login')
      fallback_location = new_user_session_path
    end
    redirect_back(fallback_location: fallback_location)
  end


  def current_user # Override Devise helper method (controller instance method)
    super || Visitor.new
  end


  def user_signed_in? # Override Devise helper method
    return false if current_user.is_a? Visitor
    true
  end


  # Set data that will be included when an exception notification is sent.
  # We have all of the data from the incoming *request* to work with and all other
  # information and objects involved at this point (the current controller, etc.)
  #
  # Most information sent to the notification is from
  # the *request* ActionDispatch::Request
  #  See that class for more details
  #
  # Information sent:
  #
  #   * request_original_url: the full URL that is the source of the request
  #     ex:  https://hitta.sverigeshundforetagare.se/hundforetag/57
  #
  #   * request_method:  the HTTP method used for the request
  #     ex: GET or POST or PUT, etc.
  #
  #   * request_path: the portion of the URL specific to the SHF system;
  #     the +String+ full path including params of the last URL requested
  #     ex:  get "/articles?page=2"  will return
  #       "/articles?page=2"
  #
  #   * params_to_json: the parameters for the request, converted .to_json
  #
  #   * params_inspect: the String returned from params.inspect
  #     This will include the 'permitted' information, which is not included in the .to_json information
  #
  #   * current_user: so we know who was using the application when the error occured
  #
  #   * remote_addr: IP address to help identify bots and webcrawlers
  #
  #   * request_id: useful for tracking the request in logs
  #     from ActionDispatch::Request  def request_id :
  #       This unique ID is useful for tracing a request from end-to-end as part of
  #       logging or debugging.
  #
  def prepare_exception_notifier
    request.env["exception_notifier.exception_data"] = {
        request_original_url: request.original_url,
        request_method: request.request_method,
        request_path: request.fullpath,
        params_as_json: params.as_json,
        params_inspect: params.inspect,
        current_user: current_user.inspect,
        remote_addr: request.env['REMOTE_ADDR'],
        browser: request.env['HTTP_USER_AGENT'],
        request_id: request.request_id

    }
  end


  # When one of our URLS is cut and pasted in Facebook (FB), FB will actually
  # _change_ the URL.  Then anyone in FB clicking on the URL will be taken
  # to our system with a (possibly) invalid URL.
  # Ex:  I want to share the list of dog groomers in Skåne (a region) with someone.
  #   I do a search for all companies in Skäne with dog groomers.  I copy that resulting URL
  #   and share it with my friends in FB.  One of my friends clicks on it but
  #   because FB has mangled the URL, it no longer works and causes a 500 or 404 error.
  #
  # Specifically, FB may change  a value that should be an Array to a Hash.
  # It's pretty clear that FB is converting our params to JSON,
  # and then just serving that JSON right back to us without backing out the conversion.
  #
  # This method 'undoes' the changes that Facebook makes.
  # This is important for the Ransack gem, which we use for searching and sorting in some views.
  # (Search for the `.ransack` method in controllers.)
  # Ransack expects the parameters with the 'q' key to have values that are Arrays, not Hashes.
  #
  def fix_FB_changed_q_params(params)

    if params.key? 'q'
      params['q'].each_pair do |key, value|
        params['q'][key] = value.values if params['q'].to_unsafe_h[key].is_a?(Hash)
      end
    end

    params
  end


  # Set the <link rel...  hlangref ...> tags that are put into the header.
  # The languages are hard coded for now.  If necesssary (e.g. when more locales
  # are added), they could be generated from I18n.config.available_locales
  #
  # Subclasses can override this to put information specific to a view or data.
  def set_hreflang_tag_urls

    @hreflang_default_url = request.url
    @hreflang_sv_url = request.base_url + '/sv' + request.fullpath
    @hreflang_en_url = request.base_url + '/en' + request.fullpath
  end


  def validate_xhr_request
    raise 'Unsupported request' unless request.xhr?
  end

end
