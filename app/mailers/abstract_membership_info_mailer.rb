# This class abstracts methods common to mailer classes that send out mails
# based on MembershipApplications.
#
class AbstractMembershipInfoMailer < ShfMailer


  private

  def send_mail_for(method_name, member_app, subject)

    set_mail_info method_name, member_app
    mail to: @recipient_email, subject: subject

  end


  def set_mail_info(method_sym, member_app)

    @member_app = member_app
    @action_name = method_sym.to_s
    @greeting_name = set_greeting_name(member_app.user)
    @recipient_email = set_recipient_email(member_app.user)

  end


end
