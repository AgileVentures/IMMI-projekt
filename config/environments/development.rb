Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    # config.cache_store = :memory_store
    config.cache_store = :file_store, Rails.root.join('tmp', 'cache')

    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Use sql schema to allow the use of functions, triggers and sequences
  config.active_record.schema_format = :sql


  ###
  #
  # Mail
  #

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.perform_caching = false


  config.action_mailer.show_previews = true

  # used by Premailer to create the absolute URL for assets in emails (like images)
  config.action_mailer.asset_host     = 'http://localhost:3000'

  # Mail templates will need to use "_url" helpers rather than "_path" helpers
  # since the template will not have the context of a request
  # (as a controller does) and thus the full URL will be required to create
  # links in the email.  This setting defines the host (domain) for the URL.
  config.action_mailer.default_url_options = { host: 'http://localhost:3000' }


  #
  ###

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true


  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  ########################################################################
  # LOGGING
  #

  # Use the HIGHEST log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log


  # To have the Rails log sent to the stdout and *not* a file,
  # define RAILS_LOG_TO_STDOUT as anything.
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end


  # end LOGGING
  ########################################################################



  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # location for where Paperclip will store files, and the url for them:
  attachment_folder = "/storage/#{ Rails.env}_paperclip_files/:class/:id_partition/:style/:filename"
  config.paperclip_defaults = { url: attachment_folder,
                                path: ":rails_root/public/:url"
  }

# end

# =begin
       # Uncomment this block to test exception notifications in a development environment.
       # WARNING:  it will *really* send notifications!

  # Notify of any exceptions using the exception_notification gem
  # Rails.application.config.middleware.use ExceptionNotification::Rack,
  #
  #                                         :slack => {
  #                                             webhook_url:    ENV['SHF_SLACK_WEBHOOKURL'],
  #                                             channel:        ENV['SHF_SLACK_CHANNEL'],
  #                                             username:       ENV['SHF_SLACK_USERNAME'],
  #                                             additional_parameters: {
  #                                                 mrkdwn: true
  #                                             },
  #                                             additional_fields: [ icon_emoji: ':bangbang:' ]
  #                                         }
  # # Enable exception_notification for rake tasks
  # ExceptionNotifier::Rake.configure
# =end
end
