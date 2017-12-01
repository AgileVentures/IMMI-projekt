require 'activity_logger'


class ApplicationMailer < ActionMailer::Base

  # Formatting email is tricky because you cannot use the same CSS as you can in web pages,
  # and some email servers (like Google) will strip out a lot of stuff you would
  # typically put into the <head></head> section -- like references to stylesheets.
  # So you have to make sure that most things (styles, images, etc.) are *inline*
  # in the email html source.
  # This blog post is particularly helpful describing the issues and how to handle things:
  #
  #  @url http://www.simonnordberg.com/creating-robust-email-templates-in-action-mailer/
  #

  include MailgunConfig

  include CommonMailUtils


  default from: ENV['SHF_NOREPLY_EMAIL']

  layout 'mailer'

  helper :application # gives access to all helpers defined within `application_helper`.


  LOG_FILE = File.join(Rails.configuration.paths['log'].absolute_current, 'mailgun.log')
  LOG_FACILITY = 'Mailgun REST'


  # If there is a problem communicating with the MailGun REST server, log the problem
  # TODO notify the SHF admin(s) using the ExceptionNotfication gem (must be able to send a notification that does not use MailGun)
  # Do not raise the error.  Do not want to show anything to the user
  def self.deliver_mail(mail)

    super

  rescue  Mailgun::CommunicationError => mailgun_error

    ActivityLogger.open(LOG_FILE, LOG_FACILITY, 'Mailgun::CommunicationError', false) do |log|

      log.record('error', "Could not send email via mailgun at #{Time.zone.now}  Error received from Mailgun: #{mailgun_error}")

    end

  end


  def test_email(user)
    @action_name = __method__.to_s
    @greeting_name = set_greeting_name(user)

    mail to: set_recipient_email(user), subject: t('application_mailer.greeting', greeting_name: @greeting_name)

  end


end
