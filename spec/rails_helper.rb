ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'pundit/matchers'
require 'paperclip/matchers'

require 'support/data_creation_helper'

require 'create_membership_seq_if_needed'
require 'shared_context/mock_app_configuration'
require 'shared_context/stub_paperclip_methods_dynamic'

require 'support/geocoder'  # Put Geocoder into test mode (mock responses)


ActiveRecord::Migration.maintain_test_schema!


RSpec.configure do |config|

  #
  # includes
  #

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view

  config.include Shoulda::Matchers::ActiveRecord, type: :model
  config.include FactoryBot::Syntax::Methods
  config.include Paperclip::Shoulda::Matchers

  config.include_context 'stub Paperclip methods'

  #
  # Rspec.configuration settings
  #

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.file_fixture_path = 'spec/fixtures/uploaded_files'
  config.use_transactional_fixtures = false


  #
  # other related configurations (not RSpec directly)
  #

  Shoulda::Matchers.configure do |shoulda_config|
    shoulda_config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end


  #
  # before / after hooks
  #

  config.before(:suite) do
    if config.use_transactional_fixtures
      raise(<<-MSG)
        Delete line `config.use_transactional_fixtures = true` from rails_helper.rb
        (or set it to false) to prevent uncommitted transactions being used in
        JavaScript-dependent specs.

        During testing, the app-under-test that the browser driver connects to
        uses a different database connection to the database connection used by
        the spec. The app's database connection would not be able to access
        uncommitted transaction data setup over the spec's database connection.
      MSG
    end
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
    create_user_membership_num_seq_if_needed

    # shush the ActivityLogger: Don't have it show every message to STDOUT.
    allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)

    # Don't force a load of the AppConfiguration every time we run a test; mock the application configuration instead.
    # Using the  MockAppConfig saves time because it means we don't ever call Paperclip.
    # Calling and using Paperclip is very slow.
    allow(AdminOnly::AppConfiguration).to receive(:config_to_use).and_return(MockAppConfig)
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, type: :feature) do
    # :rack_test driver's Rack app under test shares database connection
    # with the specs, so continue to use transaction strategy for speed.
    driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test

    if !driver_shares_db_connection_with_specs
      # Driver is probably for an external browser with an app
      # under test that does *not* share a database connection with the
      # specs, so use truncation strategy.
      DatabaseCleaner.strategy = :truncation
    end
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
    I18n.locale = I18n.default_locale
  end
end
