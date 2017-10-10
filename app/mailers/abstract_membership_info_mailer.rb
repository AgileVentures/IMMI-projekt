# This class abstracts methods common to mailer classes that send out mails
# based on MembershipApplications.
#
class AbstractMembershipInfoMailer < ApplicationMailer


  private

  def send_mail_for(method_name, member_app, subject )

    set_mail_info method_name, member_app
    mail to: @recipient_email, subject: subject

  end


  def set_mail_info(method_sym, member_app)

    @member_app = member_app
    @action_name = method_sym.to_s
    @greeting_name = set_greeting_name(member_app.user)
    @recipient_email = set_recipient_email(member_app.user)

  end

  def send_admin_email_for(method_name, admin, subject)
    set_admin_mail_info method_name, admin
    mail to: @recipient_email, subject: subject
  end

  def set_admin_mail_info(method_sym, admin)
    @action_name = method_sym.to_s
    @greeting_name = set_greeting_name(admin)
    @recipient_email = set_recipient_email(admin)
  end


end
