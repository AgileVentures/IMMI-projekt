class MembershipApplicationMailer < AbstractMembershipInfoMailer


  def acknowledge_received(member_application)

    send_mail_for __method__, member_application, t('shf_mailer.membership_application.acknowledge_received.subject')

  end


  def accepted(member_application)

    send_mail_for __method__, member_application, t('shf_mailer.membership_application.accepted.subject')

  end


end
