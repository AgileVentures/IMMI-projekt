# Sends out emails to administrators
#
class AdminMailer < ApplicationMailer

  I18N_SCOPE = 'mailers.admin_mailer'


  def new_shf_application_received(new_shf_app, admin)

    # shf_app is used in the mail view
    @shf_app = new_shf_app
    set_greeting_name(admin)

    set_mail_info __method__, admin

    mail to: recipient_email, subject: t('new_application_received.subject', scope: I18N_SCOPE)
  end


  def member_unpaid_over_x_months(admin, members_unpaid = [], num_months = 6)

    # need to set these manually because we do not have a User object for the recipient, just an email address
    @action_name = __method__.to_s
    @recipient_email =  ENV['SHF_MEMBERSHIP_EMAIL']
    set_greeting_name(admin)

    @members_unpaid = members_unpaid
    @fee_due_date = Date.current
    @num_months = num_months

    mail to: recipient_email, subject: t('member_unpaid_over_x_months.subject', num_months: @num_months, scope: I18N_SCOPE)
  end


  def new_membership_granted_co_hbrand_paid(new_member)
    @action_name = __method__.to_s
    recipient_is_membership_chair

    @new_member = new_member
    @complete_branded_cos =  new_member.companies.select(&:in_good_standing?)
    @category_names = new_member.shf_application.business_categories.map(&:name).join(', ')

    mail to: recipient_email, subject: t('new_membership_granted_co_hbrand_paid.subject', scope: I18N_SCOPE)
  end


  # Need this so the mail view can access :html_postal_format_entire_address
  helper CompaniesHelper

  def members_need_packets(members_needing_packets)
    @action_name = __method__.to_s
    recipient_is_membership_chair
    @members_needing_packets = members_needing_packets

    mail to: recipient_email, subject: t('members_need_packets.subject', scope: I18N_SCOPE)
  end

  # -------------------------------------------------------------------------

  private

  # Set the instance vars so that the email goes to the SHF Membership Chair
  # Need to set these manually because we might not have a User object
  # for the recipient, just an email address.
  def recipient_is_membership_chair
    @recipient_email =  ENV['SHF_MEMBERSHIP_EMAIL']
    @greeting_name = @recipient_email
  end
end
