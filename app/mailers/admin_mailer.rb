class AdminMailer < ApplicationMailer


  def member_application_received(new_member_app, admin)

    @member_app = new_member_app

    send_admin_email_for(
      __method__,
      admin,
      t('application_mailer.admin.new_application_received.subject')
    )

  end

  private

  def send_admin_email_for(method_name, admin, subject)
    @action_name = method_name.to_s
    @greeting_name = admin.full_name if admin.respond_to? :full_name
    @recipient_email = admin.email if admin.respond_to? :email
    mail to: @recipient_email, subject: subject
  end

  def set_greeting_name(_record)
    @greeting_name = ''
  end

  def set_recipient_email(_record)
    @recipient_email = ENV['SHF_MEMBERSHIP_EMAIL']
  end

end
