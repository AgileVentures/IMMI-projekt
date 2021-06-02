# This emails all current members in a company if the information for
# the company is 'incomplete.'
#
class CompanyInfoIncompleteAlert < CompanyEmailAlert


  # If the required information for a company is missing,
  # AND there are current members for a company,
  #
  # then send the alert if today is in the configuration list of days
  #
  # Start sending alerts based on the earliest date that a current member
  # in the company started the Company membership
  #
  def send_alert_this_day?(timing, config, company)

    if RequirementsForCoInfoNotComplete.requirements_met?({company: company}) &&
      !company.current_members.empty?

      earliest_date = company.earliest_current_member_fee_paid

      day_to_check = self.class.days_today_is_away_from(earliest_date, timing)
      send_on_day_number?(day_to_check, config)

    else
      false
    end

  end


  def mailer_method
    :company_info_incomplete
  end


  def mailer_args(company)
    [company, company.current_members]
  end

end
