require 'simplecov'
# ^^ https://github.com/colszowka/simplecov#using-simplecov-for-centralized-config

require 'cucumber/rails'
require 'cucumber/timecop'
require 'cucumber/rspec/doubles'
require 'capybara/poltergeist'
require 'email_spec/cucumber'

# Put the Geocoder into test mode so no actual API calls are made and stub with fake data
require_relative '../../spec/support/geocoder'


ActionController::Base.allow_rescue = false

begin
  DatabaseCleaner.strategy = :truncation
rescue NameError
  raise 'You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it.'
end

Cucumber::Rails::Database.javascript_strategy = :truncation


Before do
 # I18n.locale = 'en'
end


Warden.test_mode!
World Warden::Test::Helpers
After { Warden.test_reset! }

def path_with_locale(visit_path)
  "/#{I18n.locale}#{visit_path}"
end

def i18n_content(content, locale=I18n.locale)
  I18n.t(content, locale)
end

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
