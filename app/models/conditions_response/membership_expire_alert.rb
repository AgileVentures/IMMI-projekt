# This emails a member _before_ their membership expires to alert
# them that it will be expiring.
#
class MembershipExpireAlert < UserEmailAlert


  def send_alert_this_day?(timing, config, user)

    return false unless user.current_member?

    day_to_check = self.class.days_today_is_away_from(user.membership_expire_date, timing)

    send_on_day_number?(day_to_check, config)
  end


  def mailer_method
    :membership_expiration_reminder
  end

end
