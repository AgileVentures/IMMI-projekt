class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception
  before_action :set_locale

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized


  def index

  end

  private

  def set_locale
    locale = I18n.default_locale
    locale = params[:locale] if params[:locale].present?
    I18n.locale = locale.to_s
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
end
