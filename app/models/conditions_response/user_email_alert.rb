# Abstract parent class for all alerts that send out emails to users
#
#  * knows if an alert needs to be sent today (or on _this_date_)
#  * knows the name of the method to send to MemberMailer to send out the
#     alert to a user
#
#  All dates used are a Date (not a Time or DateTime). This allows us to easily
#  determine the number of days between two dates.
#
class UserEmailAlert < ConditionResponder


  def self.condition_response(condition, log)

    config = get_config(condition)
    timing = get_timing(condition)

    User.all.each do |user|

      if send_alert_this_day?(timing, config, user)
        begin
          mail_response = MemberMailer.send(mailer_method, user).deliver_now
          log_mail_response(log, mail_response, user.id, user.email)

        rescue => mailing_error
          log_failure(log, log_msg_start,
                      user_info(user.id, user.email),
                      mailing_error)
        end
      end

    end

  end


  # method to improve readability. returns true if day_number is in config[:days]
  #
  # Expects config to include the :days key; returns false if it is not there
  #
  # If config is not a Hash, raises an Error because it really _should_ be a Hash
  #  (it's a programming error to call this otherwise!)
  #
  # @param day_number [Integer] - the number of days away from today (before, after, or on)
  # @param config [Hash] - other configuration info
  def self.send_on_day_number?(day_number, config)
    config.fetch(:days, false) ? config[:days].include?(day_number) : false
  end


  # Subclasses should define this by checking information for the user
  # computing whatever date information is necessary to determine if
  # an alert should be sent out today.
  # Ex:
  #   def self.send_alert_this_day?(config, user)
  #     days_until = (user.membership_expire_date - Date.current).to_i
  #     user.membership_current? &&  config[:days].include?(days_until)
  #   end
  #
  # @param timing [Timing] - the relative timing of the alerts
  # @param config [Object] - configuration information used to determine if an alert should be sent
  # @param user [User] - the user we are checking and, if appropriate, will send the alert to
  #
  def self.send_alert_this_day?(_timing, _config, _user)
    raise NoMethodError, "Subclass must define the #{__method__} method and return true or false", caller
  end


  # This is the method sent to the MemberMailer when this condition
  # needs to send out an email.
  #
  # Subclasses must redefine this and return a symbol
  # Ex:
  #   def self.mailer_method
  #     :membership_expiration_reminder
  #   end
  def self.mailer_method
    raise NoMethodError, "Subclass must define the #{__method__} method and return a Symbol", caller
  end


  # This string is the start of the line logged to the Alert log when
  # this condition sends out an email = the name of the class
  def self.log_msg_start
    self.name
  end


  def self.log_mail_response(log, mail_response, user_id, user_email)
    user_info_str = user_info(user_id, user_email)
    mail_response.errors.empty? ? log_success(log, log_msg_start, user_info_str)
        : log_failure(log, log_msg_start, user_info_str)
  end

  def self.log_success(log, msg_start, user_info_str)
    log.record('info', "#{msg_start} email sent #{user_info_str}.")
  end

  def self.log_failure(log, msg_start, user_info_str, error = '')
    log.record('error', "#{msg_start} email ATTEMPT FAILED #{user_info_str}. #{error} Also see for possible info #{ApplicationMailer::LOG_FILE} ")
  end

  def self.user_info(id, email)
    "to id: #{id} email: #{email}"
  end
end
