# Emails about SHF Applications (has been received, approved, etc.)
class ShfApplicationMailer < ApplicationMailer


  def acknowledge_received(shf_application)

    send_mail_for __method__, shf_application, t('mailers.shf_application_mailer.acknowledge_received.subject')

  end


  def app_approved(shf_application)

    # branding_fee_paid is used in the mail view
    @branding_fee_paid = shf_application.company_branding_fee_paid?

    send_mail_for __method__, shf_application, t('mailers.shf_application_mailer.app_approved.subject')

  end


  private


  def send_mail_for(method_name, shf_application, subject)

    set_mail_info method_name, shf_application.user

    # shf_app is used in the mail view
    @shf_app = shf_application
    mail to: recipient_email, subject: subject

  end


end
