# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.mailgun_settings = {
  api_key: ENV['MAILGUN_API_KEY'],
  domain: ENV['MAILGUN_DOMAIN']
}
