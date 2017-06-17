source 'https://rubygems.org'
ruby '2.4.1'
gem 'dotenv-rails'
gem 'rails', '5.0.1'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'bcrypt', '~> 3.1.7'
gem 'haml-rails'
gem 'bootstrap-sass', '~> 3.3.6'
gem 'font-awesome-sass'
gem 'high_voltage', '~> 3.0.0'
gem 'orgnummer'

gem 'devise'
gem 'pundit'
gem 'paperclip', '~> 5.0.0'

gem 'routing-filter'   # for handling locale filters around routes

gem 'ransack'
gem 'city-state'
gem 'rubyzip', '>= 1.2.1'  # security vulnerability with earlier versions CVE-2017-5946
gem 'i18n-js', '>= 3.0.0.rc11'

gem 'will_paginate'
gem 'will_paginate-bootstrap'

# Loading `ckeditor` directly from github due to problem in production
# environment where assets cannot be found.
# See: https://github.com/galetahub/ckeditor/issues/719
# According to above link, this issue has been fixed but not yet released
# (writing this on April 14, 2017).
# Once release, remove reference to github for loading.
gem 'ckeditor', github: 'galetahub/ckeditor'

gem 'aasm', '~> 4.11.1'  # state machine ()acts as state machine)

gem 'ffaker'  # Fake data for DB seeding

gem 'dotenv'


gem 'smarter_csv'

gem 'geocoder'

gem 'sanitize'

gem 'mailgun_rails'

group :development, :test do
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'pundit-matchers'
  gem 'factory_girl_rails'
  gem 'pry'
  gem 'pry-byebug'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rake'
  gem 'coveralls', require: false
  gem 'launchy'
  gem 'cucumber-timecop', require: false

  gem 'better_errors'
  gem 'binding_of_caller'  # needed to make better_errors work well

  gem 'i18n-tasks'

end

group :development do
  gem 'web-console'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'erb2haml'
  gem 'capistrano', '~> 3.6.0'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano-rails', '~> 1.1.1'
  gem 'capistrano-rbenv', '~> 2.0'
  gem 'capistrano-ssh-doctor', '~> 1.0'
  gem 'capistrano-env-config'
  gem 'railroady'
  gem 'bullet'
  gem 'rb-readline'

  # to generate state machine diagrams
  # ex: for membership_application state machine:
  #   bundle exec aasm_statecharts -i ./app/models membership_application -t -d ./doc
  gem 'aasm_statecharts',  github: 'weedySeaDragon/aasm_statecharts'


end

group :test do
  gem 'poltergeist'
end
