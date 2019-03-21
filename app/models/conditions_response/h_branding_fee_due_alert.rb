# This emails all current members in a company if the h-branding fee is PAST DUE.
#
# The alert is sent _after_ the HBranding license has expired.
#
class HBrandingFeeDueAlert < CompanyEmailAlert


  # If an H Branding Fee is due for the company, then
  #   send the alert if today is in the configuration list of days
  #
  # Note that the number of days is based on the _expiration_date_ to remain
  # consistent with using the expiration date as the basis for the number
  # of dates.
  def send_alert_this_day?(timing, config, company)

    if RequirementsForHBrandingFeeDue.requirements_met?({company: company})

      due = if (latest_payment_expiry = company.branding_expire_date)
              latest_payment_expiry
            else
              company.earliest_current_member_fee_paid
            end

      day_to_check = self.class.days_today_is_away_from(due, timing)

      send_on_day_number?(day_to_check, config)

    else
      false
    end

  end


  def mailer_method
    :h_branding_fee_past_due
  end


  def mailer_args(company)
    [company, company.current_members]
  end

end
