# This emails a member _before_ their membership expires to remind
# them that they need to renew AND what the renewal requirements are.
# This is important so that Members have to up update their qualifications
# and get certificates/other proof ready to be uploaded.
#
class MembershipWillExpireRenewalReqsAlert < UserEmailAlert


  def send_alert_this_day?(timing, config, user)

    return false unless user.current_member?

    day_to_check = self.class.days_today_is_away_from(user.membership_expire_date, timing)

    send_on_day_number?(day_to_check, config)
  end


  def mailer_method
    :membership_will_expire_renewal_requirements_reminder
  end

end
