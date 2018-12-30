# This emails a member _after_ their membership_fee payment is due.
# It warns them that their membership_fee payment is overdue.
#
class MembershipFeeOverdueAlert < UserEmailAlert


  def self.send_alert_this_day?(timing, config, user)

    # the order of these 2 is on purpose: the first has fewer SQL queries
    return false if !user.has_approved_shf_application? || user.membership_current?

    day_to_check = days_today_is_away_from(User.next_membership_payment_date(user.id), timing)

    send_on_day_number?(day_to_check, config)
  end


  def self.mailer_method
    :membership_payment_due
  end

end
