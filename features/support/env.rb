require 'simplecov'
# ^^ https://github.com/colszowka/simplecov#using-simplecov-for-centralized-config

require 'cucumber/rails'
require 'cucumber/timecop'
require 'cucumber/rspec/doubles'
require 'capybara/poltergeist'
require 'email_spec/cucumber'
require 'webdrivers/chromedriver'

# Put the Geocoder into test mode so no actual API calls are made and stub with fake data
require_relative '../../spec/support/geocoder'

# Mock the AppConfiguration so that Paperclip commands are not called multiple times for every scenario
require_relative '../../spec/shared_context/mock_app_configuration.rb'


require 'show_me_the_cookies'
World(ShowMeTheCookies)

# add the FindHelpers module
require_relative './find_helpers'
World(FindHelpers)

#
# Configurations
#

Webdrivers.install_dir = Rails.root.join('features', 'support', 'webdrivers')

ActionController::Base.allow_rescue = false

Capybara.server = :puma # Ensure puma is used
# Capybara.server = :puma, { Silent: true } # To clean up your test output


begin
  DatabaseCleaner.strategy = :truncation
rescue NameError
  raise 'You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it.'
end

Cucumber::Rails::Database.javascript_strategy = :truncation


# These sites are where to download webdrivers.
# WebMock and VCR need to 'allow' them.
webdriver_download_sites = [
    'chromedriver.storage.googleapis.com',
    'github.com/mozilla/geckodriver/releases',
    'selenium-release.storage.googleapis.com',
    'developer.microsoft.com/en-us/microsoft-edge/tools/webdriver'
]
WebMock.disable_net_connect!(allow_localhost: true, allow: webdriver_download_sites)


VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir     = 'features/vcr_cassettes'
  c.allow_http_connections_when_no_cassette = true
  c.ignore_localhost = true
  c.default_cassette_options = { allow_playback_repeats: true }
  webdriver_download_sites.each do | webdriver_download_site |
    c.ignore_hosts(webdriver_download_site)
  end
end

Warden.test_mode!
World Warden::Test::Helpers

Capybara.register_driver :selenium do |app|
  options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
  Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      options: options
  )
end

# Displayed chrome browser - @selenium_browser
Capybara.register_driver :selenium_browser do |app|
  Capybara::Selenium::Driver.new(
      app,
      browser: :chrome
  )
end
# register this driver so that ShowMeTheCookies knows which adapater to use for it
#   have to use the same driver name (symbol)
ShowMeTheCookies.register_adapter(:selenium_browser, ShowMeTheCookies::SeleniumChrome)

#
# Global Before/After
#

Before do
  DatabaseCleaner.clean

  # I18n.locale = 'en'
  ENV['SHF_BETA'] = 'no'

  # shush the ActivityLogger: Don't have it show every message to STDOUT.
  allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)

  # Mock the ActivityLogger
  mock_log = instance_double("ActivityLogger")
  allow(ActivityLogger).to receive(:new).and_return(mock_log)
  allow(mock_log).to receive(:info)
  allow(mock_log).to receive(:record)
  allow(mock_log).to receive(:close)

  mock_the_app_configuration
end


After { Warden.test_reset! }

#
# 'Global' methods available to all steps
#

def path_with_locale(visit_path)
  "/#{I18n.locale}#{visit_path}"
end

def i18n_content(content, locale=I18n.locale)
  I18n.t(content, locale)
end


# ----------------------------------------------------
# Uncomment this to show the 20 slowest scenarios
=begin
scenario_times = {}

Around() do |scenario, block|
  start = Time.now
  block.call
  scenario_times["#{scenario.feature.file}::#{scenario.name}"] = Time.now - start
end

at_exit do
  max_scenarios = scenario_times.size > 20 ? 20 : scenario_times.size
  puts "------------- Top #{max_scenarios} slowest scenarios -------------"
  sorted_times = scenario_times.sort { |a, b| b[1] <=> a[1] }
  sorted_times[0..max_scenarios - 1].each do |key, value|
    puts "#{value.round(2)}  #{key}"
  end
end
=end
# ----------------------------------------------------


#
# private methods
#

private

# Don't force a load of the AppConfiguration every time we run a test:
# mock the application configuration instead.
# Using the  MockAppConfig saves time because it means we don't ever call Paperclip
# for it. Calling and using Paperclip is very slow.
#  If you have a feature or scenario that requires a 'real' ApplicationConfiguration,
#  use the step defined in step_definitions/app_configuration_steps/rb
#
def mock_the_app_configuration
  allow(AdminOnly::AppConfiguration).to receive(:config_to_use).and_return(MockAppConfig)
end
