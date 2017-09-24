class ShfMailer < Devise::Mailer

  # @see https://github.com/mailgun/mailgun-ruby/tree/master/docs for examples
  # @see https://github.com/plataformatec/devise/wiki/How-To:-Use-custom-mailer
  #   for instructions on using this custom mailer with Devise

  default from: ENV['SHF_NOREPLY_EMAIL']
  layout 'mailer'


  # the following 2 lines are required to use this with Devise:
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # access to  e.g. `confirmation_url`


  def mailgun_client
    Mailgun::Client.new(ENV['MAILGUN_API_KEY'])
  end


  def message_builder
    mb = Mailgun::MessageBuilder.new
    mb.from ENV['SHF_SENDER_EMAIL'] # default 'from: ' email (can overwrite as needed)
    mb
  end


  # the specific SHF domain for the Mailgun account (it's not the sandbox domain)
  def domain
    ENV['MAILGUN_DOMAIN']
  end



  private

  def set_greeting_name(record)

    if record.respond_to?(:full_name)
      @greeting_name = "#{record.full_name}"
    elsif record.respond_to? :email
      @greeting_name = record.email
    end

  end


  def set_recipient_email(record)
    @recipient_email = record.email if record.respond_to? :email
  end


end
