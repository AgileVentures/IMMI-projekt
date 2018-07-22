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



    ###
    #
    # Mail
    #

    config.action_mailer.delivery_method = :mailgun

    #  need to set the mailgun_settings here because of  https://github.com/mailgun/mailgun-ruby/issues/86
    config.action_mailer.mailgun_settings = {
        api_key: ENV['MAILGUN_API_KEY'],
        domain: ENV['MAILGUN_DOMAIN']
    }

    # Mail templates will need to use "_url" helpers rather than "_path" helpers
    # since the template will not have the context of a request
    # (as a controller does) and thus the full URL will be required to create
    # links in the email.  This setting defines the host (domain) for the URL.

    # Default for development and testing.  production.rb overrides this
    config.action_mailer.default_url_options = { host: 'localhost', port: '3000' }

    # Ensure this is false by default (to be secure).
    # Only change in development or test environments where really needed
    config.action_mailer.show_previews = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end

end
