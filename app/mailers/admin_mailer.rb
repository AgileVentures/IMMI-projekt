# Sends out emails to administrators
class AdminMailer < ApplicationMailer

  def new_shf_application_received(new_shf_app, admin)

    # shf_app is used in the mail view
    @shf_app = new_shf_app

    set_mail_info __method__, admin

    mail to: recipient_email, subject: t('mailers.admin_mailer.new_application_received.subject')

  end

  
end
