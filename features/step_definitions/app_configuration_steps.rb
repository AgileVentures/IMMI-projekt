# Steps dealing with AdminOnly::AppConfiguration


# This step can be used to make sure that an actual valid
# Application Configuration (AdminOnly::AppConfiguration)
# is used.  A valid AppConfiguration is created (all required data is there)
# and all of the methods are called. None of the methods are stubbed.
# This means that Paperclip is likely to be called because the attachments
# are referenced (e.g. the "proof of membership" or some other attached image).
# Because this is a new AppConfiguration, Paperclip will need to create the
# file information for each attachment: the content type, any other image sizes, etc.
# This involves both file I/O, which is slow, and system calls to external
# programs that Paperclip needs to use.
# Thus most of the time tests can and should work with a _mocked_
# AppConfiguration which stubs methods and so none of the Paperclip stuff is
# ever called.  (This is set up in the *Before* block in features/support/env.rb )
# But when the feature needs to work with any of the actual AppConfiguration,
# this step should be used.
#
# @example
# Feature: A member pays their membership fee and is approved
#
#   Background:
#     Given the App Configuration is not mocked and is seeded
#
#     Given the following users exist:
#     ...
#
#   Scenario: .....
#
And(/^the App Configuration is not mocked and is seeded$/) do

  require_relative File.join(Rails.root, 'db/seed_helpers/app_configuration_seeder')

  # Do not stub the AppConfiguration
  allow(AdminOnly::AppConfiguration).to receive(:config_to_use).and_call_original

  # ensure we will seed a new configuration (One is not created if one already exists.)
  AdminOnly::AppConfiguration.delete_all

  SeedHelper::AppConfigurationSeeder.seed
end


And("the {capture_string} attachment is available via a public url") do | attachment |
  image_url = AdminOnly::AppConfiguration.config_to_use.send(attachment.to_sym).url
  expect {
    visit "#{root_url}#{image_url}"
  }.not_to raise_error
end


# set the named attachment to nil in the ApplicationConfiguration
And("the {capture_string} file is missing from the application configuration") do |missing_attachment|
  app_config = AdminOnly::AppConfiguration.config_to_use
  # update_attribute skips validations, which we must do because an ApplicationConfiguration validates_attachment_presence
  app_config.update_attribute(missing_attachment.to_sym, nil) #  send("#{missing_attachment}=".to_sym, nil)
end
