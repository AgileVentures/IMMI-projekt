require 'activity_logger'


# Common info and behavior for emails sent from the Application.
# Note that emails sent via Devise have a different parent class (e.g. UserMailer)
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
  # Note: Railgun  does not handle 'reply_to:' properly.  Railgun does not recognize it as
  # a standard field; 'reply_to' is not in Railgun::Mailer::IGNORED_HEADERS
  # Railgun will create an upper case version of it ('Reply-to') *and* the (original)
  # lower-case version 'reply-to', which will ultimately and incorrectly create
  # two 'Reply-To' entries in the delivered mail. (Railgun does this in
  # Railgun::Mailer#transform_for_mailgun)
  #
  # Thus we have to add 'reply-to' to Railgun::Mailer::IGNORED_HEADERS
  #


  LOG_FACILITY = 'ApplicationMailer'


  attr_accessor :recipient_email, :greeting_name, :action_name

  include MailgunConfig

  include CommonMailUtils

  Railgun::Mailer::IGNORED_HEADERS << 'reply-to' # have to add this so that Railgun
  # treats the reply-to as a 'standard' header field and does not duplicate it

  from_address = Mail::Address.new
  from_address.address =  ENV['SHF_FROM_EMAIL']
  from_address.display_name = ENV['SHF_EMAIL_DISPLAY_NAME']

  reply_to_address = Mail::Address.new
  reply_to_address.address = ENV['SHF_REPLY_TO_EMAIL']
  reply_to_address.display_name = ENV['SHF_EMAIL_DISPLAY_NAME']

  default from: from_address.format,
    reply_to: reply_to_address.format

  layout 'mailer'

  helper :application # gives access to all helpers defined within `application_helper`.


  # If there is a problem communicating with the MailGun REST server, log the problem
  # TODO notify the SHF admin(s) using the ExceptionNotfication gem (must be able to send a notification that does not use MailGun)
  #
  # Raise any errors caught after writing to the log so that other systems
  #    (e.g. rake nightly tasks) know if this fails.
  def self.deliver_mail(mail)

    super

  rescue  => mailgun_error

    ActivityLogger.open(logfile_name, LOG_FACILITY, 'Mailgun::CommunicationError', false) do |log|

      log.error( "Could not send email via mailgun at #{Time.zone.now}  Error received from Mailgun: #{mailgun_error}")

    end

    raise mailgun_error

  end

  def self.logfile_name
    LogfileNamer.name_for(self.class.name)
  end

  def test_email(user)
    @action_name = __method__.to_s
    @greeting_name = set_greeting_name(user)

    mail to: set_recipient_email(user), subject: t('mailers.application_mailer.greeting', greeting_name: @greeting_name)

  end


end
