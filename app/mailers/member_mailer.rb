# Sends out emails to Members when membership is granted or renewed
class MemberMailer < ApplicationMailer


  def membership_granted(member)

    set_mail_info __method__, member
    @member = member
    mail to: recipient_email, subject: t('mailers.member_mailer.membership_granted.subject')

  end

end

