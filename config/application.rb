require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
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

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end

  # Load from sub-folders of "models"
  Rails.application.config.autoload_paths += Dir[Rails.root.join("app", "models", "{*/}")]

  ############### New defaults from Rails version 5.0 ###############

  # Enable per-form CSRF tokens. Previous versions had false.
  Rails.application.config.action_controller.per_form_csrf_tokens = true

  # Enable origin-checking CSRF mitigation. Previous versions had false.
  Rails.application.config.action_controller.forgery_protection_origin_check = true

  # Make Ruby 2.4 preserve the timezone of the receiver when calling `to_time`.
  # Previous versions had false.
  ActiveSupport.to_time_preserves_timezone = true

  # Require `belongs_to` associations by default. Previous versions had false.
  Rails.application.config.active_record.belongs_to_required_by_default = true

  # Configure SSL options to enable HSTS with subdomains. Previous versions had false.
  Rails.application.config.ssl_options = { hsts: { subdomains: true } }

  #^^^^^^^^^^^^^^^^ New defaults from Rails version 5.0 ^^^^^^^^^^^^^^^^

end
