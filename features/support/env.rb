require 'coveralls'
Coveralls.wear_merged!('rails')
require 'cucumber/rails'
require 'cucumber/timecop'
require 'cucumber/rspec/doubles'
require 'capybara/poltergeist'

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

# For tests requiring javascript, headless
Capybara.javascript_driver = :poltergeist



# Geocoding: use the stubbed values instead of actually hitting the API
#
geocoding_orig_lookup = Geocoder.config[:lookup]

Before do
  Geocoder.configure(lookup: :test)
  require Rails.root.join("spec/support/geocoder_stubs") # load the stubbed results
end

After do
  Geocoder.configure(lookup: geocoding_orig_lookup)
end
