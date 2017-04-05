require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SHFProject

  class Application < Rails::Application

    # Disable generation of helpers, javascripts, css, and view, helper, routing and controller specs
    config.generators do |generate|
      generate.helper false
      generate.assets false
      generate.view_specs false
      generate.helper_specs false
      generate.routing_specs false
      generate.controller_specs false
    end

    config.i18n.default_locale = :sv
    config.i18n.fallbacks = true

    # i18n-js
    # Provides support for localization/translations on the client
    # utilizing Rails localization.  Uses same translation files.
    config.middleware.use I18n::JS::Middleware

    I18n.available_locales = ['en', 'sv']


    # load settings from the shf.yml file:
    config.x.shf = config_for(:shf)

    config.after_initialize do
      config.x.google_key = "#{Geocoder.config[:api_key]}"
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
