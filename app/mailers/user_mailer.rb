# Emails sent out regarding user passwords, etc., as managed with Devise
class UserMailer < Devise::Mailer

# @see https://github.com/plataformatec/devise/wiki/How-To:-Use-custom-mailer
#   for instructions on using this custom mailer with Devise

  include MailgunConfig

  include CommonMailUtils

  # the following 2 lines are required to use this with Devise:
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # access to  e.g. `confirmation_url`


  # Set the instance vars before calling each Devise method via super
  %w(
      confirmation_instructions
      reset_password_instructions
      unlock_instructions
      email_changed
      password_change
      ).each do |method|

    define_method(method) do |resource, *args|
      set_greeting_name(resource)
      set_recipient_email(resource)
       super(resource, *args)
    end


  end


end
