class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def index

  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      membership_applications_path
    elsif resource.user?
      information_path
    else
      super
    end
  end

  private

  def user_not_authorized
    flash[:alert] = 'Du har inte behörighet att göra detta..'
    redirect_back(fallback_location: root_path)
  end
end
