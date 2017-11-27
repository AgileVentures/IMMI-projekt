class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :prepare_exception_notifier

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized


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
    additional_permissions = [:first_name, :last_name]
    devise_parameter_sanitizer.permit(:sign_up, keys: additional_permissions)
    devise_parameter_sanitizer.permit(:account_update, keys: additional_permissions)
  end

  private

  def set_locale
    @locale = I18n.default_locale
    @locale = params[:locale].to_s if params[:locale].present?
    I18n.locale = @locale
    @language_change_allowed = request.get? || (self.is_a? Devise::SessionsController)
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_root_path
    else
      information_path
    end
  end

  def user_not_authorized
    flash[:alert] = t('errors.not_permitted')
    redirect_back(fallback_location: root_path)
  end

  def current_user  # Override Devise helper method (controller instance method)
    super || Visitor.new
  end

  def user_signed_in?  # Override Devise helper method
    return false if current_user.is_a? Visitor
    true
  end


  # Set data that will be included when an exception notification is sent
  #  current_user: so we know who was using the application when the error occured
  #  remote_addr: IP address to help identify bots and webcrawlers
  def prepare_exception_notifier
    request.env["exception_notifier.exception_data"] = {
        current_user: current_user.inspect,
        remote_addr: request.env['REMOTE_ADDR']
    }
  end


end
