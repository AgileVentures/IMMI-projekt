Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=3600'
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.perform_caching = false


  ###
  #
  # Mail
  #

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Mail templates will need to use "_url" helpers rather than "_path" helpers
  # since the template will not have the context of a request
  # (as a controller does) and thus the full URL will be required to create
  # links in the email.  This setting defines the host (domain) for the URL.
  config.action_mailer.default_url_options = { host: 'http://localhost:3000' }

  # used by Premailer to create the absolute URL for assets in emails (like images)
  config.action_mailer.asset_host     = 'http://localhost:3000'

  # DO raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  config.action_mailer.raise_delivery_errors = true

  #
  ###


  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true


  # location for where Paperclip will store files, and the url for them:
  attachment_folder = "/storage/#{ Rails.env}_paperclip_files/:class/:id_partition/:style/:filename"
  config.paperclip_defaults = { url: attachment_folder,
                                path: ":rails_root/public/:url"
  }

end
