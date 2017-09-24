class AdminMailer < AbstractMembershipInfoMailer


  def member_application_received(new_member_app)

    send_mail_for __method__, new_member_app, t('shf_mailer.admin.new_application_received.subject')

  end



  private


  def set_greeting_name(_record)
    @greeting_name = ''
  end

  def set_recipient_email(_record)
    @recipient_email = ENV['SHF_MEMBERSHIP_EMAIL']
  end

end
