module MembershipApplicationMailerHelper

  def membership_email_addr
    ENV['SHF_MEMBERSHIP_EMAIL']
  end

end

