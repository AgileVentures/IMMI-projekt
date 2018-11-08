module ApplicationMailerHelper

  def membership_email_addr
    ENV['SHF_REPLY_TO_EMAIL']
  end

end

