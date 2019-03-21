source 'https://rubygems.org'
ruby '2.5.1'
gem 'dotenv-rails'
gem 'rails', '5.2.2'
gem 'bootsnap', require: false
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'bcrypt', '~> 3.1.7'
gem 'haml-rails'
gem 'high_voltage', '~> 3.0.0'
gem 'orgnummer'
gem 'popper_js', '~> 1.14.3'
gem 'bootstrap', '~> 4.1.3'
gem 'font-awesome-sass', '~> 5.5.0'


gem 'devise'
gem 'pundit'
gem "paperclip", "~> 6.0.0"

gem 'routing-filter'   # for handling locale filters around routes

gem 'ransack'
gem 'city-state'
gem 'rubyzip', '>= 1.2.1'  # security vulnerability with earlier versions CVE-2017-5946
gem 'i18n-js', '>= 3.0.0.rc11'

gem 'will_paginate'
gem 'bootstrap-will_paginate'

# Loading `ckeditor` directly from github due to problem in production
# environment where assets cannot be found.
# See: https://github.com/galetahub/ckeditor/issues/719
# According to above link, this issue has been fixed but not yet released
# (writing this on April 14, 2017).
# Once release, remove reference to github for loading.

# Update on June 22, 2017 - it appears that the problem described abpve has
# been fixed in the latest gem.  However, there is another problem - related
# to Rails 5.1 - that is not yet fixed in the latest gem but *is* fixed in the
# current "master" branch in Githib.  So, for now, will need to continue
# to pull this code directly from Github.
# https://github.com/galetahub/ckeditor/issues/752
gem 'ckeditor', github: 'galetahub/ckeditor'

gem 'aasm', '~> 4.11.1'  # state machine ()acts as state machine)

gem 'ffaker'  # Fake data for DB seeding

gem 'dotenv'


gem 'smarter_csv'

gem 'geocoder'

gem 'sanitize'

gem 'mailgun-ruby'
gem 'premailer-rails'  # converts css to inline; required for html emails to look ok
gem 'nokogiri'         # must explicity require this gem for premailer-rails

gem 'httparty'
gem 'jwt'

gem 'exception_notification' # send notifications if there are errors
gem 'slack-notifier'  # send notifications to Slack
gem 'exception_notification-rake', '~> 0.3.0'

gem 'imgkit'
gem 'wkhtmltoimage-binary'
gem 'chartkick'
gem 'groupdate'

gem 'mini_racer', platforms: :ruby

gem 'hashie'  # powerful methods for searching nested Hashes (ex: params) and more

gem 'aws-sdk-s3'

gem 'meta-tags'
gem 'mini_magick'


group :development, :test do
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'pundit-matchers'
  gem 'factory_bot_rails'

  # Note: pry fails when a utf-8 character is used in a string.
  # pry calls the rb-readline gem, which is actually where the failure happens.
  # gem 'pry-rails'
  gem 'pry'
  gem 'pry-byebug'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rake'
  gem 'coveralls', '>= 0.8.21', require: false
  gem 'launchy'
  gem 'cucumber-timecop', require: false

  gem 'better_errors'
  gem 'binding_of_caller'  # needed to make better_errors work well

  gem 'i18n-tasks', '~> 0.9.21'

end

group :development do
  gem 'web-console'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'erb2haml'
  gem 'capistrano', '~> 3.11'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano-rails', '~> 1.4'
  gem 'capistrano-rbenv', '~> 2.0'
  gem 'capistrano-ssh-doctor', '~> 1.0'
  gem 'capistrano-env-config'
  gem 'railroady'
  gem 'bullet'
  gem 'rb-readline'

  gem 'rubycritic'   # code quality analysis tools and reports
  gem 'rubocop', require: false
  gem 'rack-mini-profiler', require: false
end

group :test do
  gem 'poltergeist'
  gem 'codeclimate-test-reporter', '~> 1.0.0'
  # ^^ https://docs.codeclimate.com/docs/test-coverage-ruby
  gem 'simplecov', '>= 0.13.0'
  gem 'email_spec'
  gem 'selenium-webdriver'

  # chromedriver-helper is conflicting with the Chrome version on
  # SemaphoreCI.  The ENV variable below excludes the gem on SemaphoreCI
  # and fixes that problem. (2018-12-12 ashley e/weedySeaDragon)
  gem 'chromedriver-helper' unless ENV.key?('SEMAPHORECI')

  gem 'webmock'  # to mock web (HTTP) interactions.  Required by the vcr gem
  gem 'vcr'      # to record and 'playback' (mock) http requests

  gem 'timecop'
  gem 'rubocop-rspec'

end
