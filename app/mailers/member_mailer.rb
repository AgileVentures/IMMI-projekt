# Sends out emails to Members regarding changes in membership status, including:
# membership granted, renewed, soon-to-be-expired, etc.
class MemberMailer < ApplicationMailer


  def membership_granted(member)

    set_mail_info __method__, member
    @member = member
    mail to: recipient_email, subject: t('mailers.member_mailer.membership_granted.subject')
  end


  def membership_renewed(member)
    set_mail_info __method__, member
    @member = member
    @company = member.companies.first
    @membership_last_day = member.membership_last_day
    @companies = member.companies

    mail to: recipient_email, subject: t('mailers.member_mailer.membership_renewed.subject')
  end


  def membership_expiration_reminder(member)
    set_mail_info __method__, member
    @member      = member
    @expire_date = member.membership_expire_date
    mail to:      @recipient_email,
         subject: t('mailers.member_mailer.membership_will_expire.subject')

  end

  def membership_will_expire_renewal_reqs_reminder(member)
    set_mail_info __method__, member
    @member      = member
    @expire_date = member.membership_expire_date
    mail to:      @recipient_email,
         subject: t('mailers.member_mailer.membership_will_expire_renewal_reqs_reminder.subject')
  end


  def h_branding_fee_past_due(company, recipient)

      set_mail_info __method__, recipient
      @member  = recipient
      @company = company
      mail to: @recipient_email,  subject: t('mailers.member_mailer.h_branding_fee_past_due.subject')
  end


  def membership_lapsed(prev_member)

    set_mail_info __method__, prev_member
    @member      = prev_member
    @expire_date = prev_member.membership_expire_date

    mail to:      @recipient_email,
         subject: t('mailers.member_mailer.membership_lapsed.subject')
  end


  def company_info_incomplete(company, recipient)

    set_mail_info __method__, recipient
    @member  = recipient
    @company = company
    mail to: @recipient_email,  subject: t('mailers.member_mailer.co_info_incomplete.subject')

  end


  def app_no_uploaded_files(recipient)

    set_mail_info __method__, recipient
    @member  = recipient
    mail to:      @recipient_email,
         subject: t('mailers.member_mailer.app_no_uploaded_files.subject')

  end


  def h_branding_fee_will_expire(company, recipient)

    set_mail_info __method__, recipient
    @member  = recipient
    @company = company
    @expire_date = company.branding_expire_date
    mail to: @recipient_email,  subject: t('mailers.member_mailer.h_branding_fee_will_expire.subject')

  end


  def first_membership_fee_owed(user)

    set_mail_info __method__, user
    @user = user

    mail to: recipient_email, subject: t('mailers.member_mailer.first_membership_fee_owed.subject')
  end

end
