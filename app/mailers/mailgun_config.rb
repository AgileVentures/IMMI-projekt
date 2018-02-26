# Settings and methods for using Mailgun with mailers
module MailgunConfig


  def mailgun_client
    Mailgun::Client.new(ENV['SHF_MAILGUN_API_KEY'])
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

end
