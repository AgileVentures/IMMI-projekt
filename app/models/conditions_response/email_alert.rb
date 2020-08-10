# Abstract parent class for all alerts that send out emails
#
# Responsibility: loops through a list of entities, checking each one
#       to see if an email needs to be sent
#   AND (smell!) to send and log the email alert.
#     TODO refactor this into smaller, single responsibility classes
#
#  * knows how to loop through all <items> and check to see if an alert
#     needs to be sent
#  * knows how to send the email (using the mailer, mailer_method, and
#     mailer_args)
#  * knows how to create a string to log a successful email sent
#  * knows how to create a string to log a failed email attempt
#
# This is a Singleton because subclasses may need their own instance of an
#  AlertLogStringMaker. (Cannot accomplish that with a class variable).
#
#  SUBCLASSES MUST IMPLEMENT SPECIFIC METHODS.
#  They must be implemented to satisfy the interface for this abstract class.
#  Any method that a subclass must implement will raise a NoMethod error
#  here in this class unless a subclass implements it.
#
#
#  All dates used are a Date (not a Time or DateTime). This allows us to easily
#  determine the number of days between two dates.
#
#  TODO - started using @timing and @config instance vars; complete by also
#         refactoring/changing all subclasses
#
#  TODO - this class is still too big.  It has too many responsibilities.  Can the
#  mailer-related responsibilities be factored out into a different class? (e.g.
#  mailer_class, mailer_args, mail_message)
#
class EmailAlert < ConditionResponder


  include Singleton


  attr_accessor :config, :timing


  # pass the class method call to the singleton instance
  def self.condition_response(condition, log, use_slack_notification: true)
    self.instance.condition_response(condition, log)
  end


  # Loop through all 'entities' and send them an email if an alert should be sent today
  def condition_response(condition, log)

    @config = self.class.get_config(condition)
    @timing = self.class.get_timing(condition)

    create_alert_logger(log)

    process_entities(entities_to_check, log)
  end


  # By default, process each entity and take action on it.
  #
  def process_entities(entities_to_check, log)
    entities_to_check.each{ | entity | take_action(entity, log) }
  end


  # The default action is to send email to the entity if an alert should be sent this day,
  # given the configuration and timing.
  #
  def take_action(entity, log)
    send_email(entity, log) if send_alert_this_day?(@timing, @config, entity)
  end


  # Send the email to the entity. Put an entry in the log file about it.
  # subclasses can use email_args if needed to put additional info the email.
  def send_email(entity, log, _email_args=[])
    begin
      mail_response = mail_message(entity).deliver_now
      log_mail_response(log, mail_response, entity)

    rescue => mailing_error
      @alert_logger.log_failure(entity, error: mailing_error)
    end
  end


  # create the mail message by sending :mailer_method to the :mailer_class
  def mail_message(entity)
    mailer_class.send(mailer_method, *(mailer_args(entity)) )
  end


  # create an AlertLogger to use to log success, failure, etc. about this alert
  def create_alert_logger(log)
    @alert_logger = AlertLogger.new(log, self)
  end


  # @param _log [ActivityLog] - the log the message will be written to
  # @param mail_response [Mail::Message] - checked to see if it was successful or not
  # @param entities [Array] - a list of entities that received the mail (a User; a Company; etc)
  #
  #  TODO - is the log really needed?  does the @alert_logger already have it?
  #
  def log_mail_response(_log, mail_response, *entities )

    mail_response.errors.empty? ? @alert_logger.log_success(*entities)
        : @alert_logger.log_failure(*entities)
  end


  # Method to improve readability. returns true if day_number is in config[:days]
  #
  # Expects config to include the :days key; returns false if it is not there
  #
  # If config is not a Hash, raises an Error because it really _should_ be a Hash
  #  (it's a programming error to call this otherwise!)
  #
  # @param day_number [Integer] - the number of days away from today (before, after, or on)
  # @param config [Hash] - other configuration info
  def send_on_day_number?(day_number, config)
    config.fetch(:days, false) ? config[:days].include?(day_number) : false
  end


  # ===========================================================================
  #
  # SUBCLASSES MUST DEFINE THESE METHODS
  #

  # The list of entities that will be checked to see if an email needs to be sent
  #
  # SUBCLASSES SHOULD REDEFINE THIS TO SOMETHING USEFUL
  #  Ex:  Users.all
  #
  # @return [Array] - the list of entities that will be looped thru
  def entities_to_check
    raise NoMethodError, "Subclass must define the #{__method__} method and return a list of entities to check", caller
  end


  # The Mailer class to send :mailer_method to. It should be able to create and deliver
  # the email.
  #
  # Ex:  MemberMailer
  #
  def mailer_class
    raise NoMethodError, "Subclass must define the #{__method__} method and return the Mailer class to use", caller
  end


  # The arguments passed to the mailer method.
  #
  # SUBCLASSES MUST REDEFINE THIS TO SOMETHING USEFUL
  #  Ex:  [user, user_company ]
  #
  # @return [Array] - arguments to pass to the mailer method
  def mailer_args(_entity)
    raise NoMethodError, "Subclass must define the #{__method__} method and return an Array of arguments", caller
  end


  # This is the method sent to the MemberMailer when this condition
  # needs to send out an email.
  #
  # Subclasses must redefine this and return a symbol
  # Ex:
  #   def mailer_method
  #     :membership_expiration_reminder
  #   end
  def mailer_method
    raise NoMethodError, "Subclass must define the #{__method__} method and return a Symbol", caller
  end


  # Subclasses should define this by checking information for the user
  # computing whatever date information is necessary to determine if
  # an alert should be sent out today.
  # Ex:
  #   def send_alert_this_day?(timing, config, user)
  #     days_until = (user.membership_expire_date - Date.current).to_i
  #     user.membership_current? &&  config[:days].include?(days_until)
  #   end
  #
  # Does every implementation take the form:
  #
  #    return_false_condition (ex: return false unless user.membership_current?)
  #
  #    day_to_check = <determined somehow>
  #
  #    day_to_check = Date.current - config[:starting_date]
  #    send_on_day_number?(day_to_check, config)
  #
  # If so, we can abstract that to here and have subclasses just provide the
  # method for return_false_condition and for determining the day_to_check
  #
  # @param timing [Timing] - the relative timing of the alerts
  # @param config [Object] - configuration information used to determine if an alert should be sent
  # @param entity [Object] - the entity (e.g. user or company) we are checking and,
  #                          if appropriate, will send the alert to
  #
  def send_alert_this_day?(_timing, _config, _entity)
    raise NoMethodError, "Subclass must define the #{__method__} method and return true or false", caller
  end


  # Given the information, return a string to write to the log upon success
  #
  # SUBCLASSES SHOULD REDEFINE THIS TO SOMETHING USEFUL
  #
  def success_str(_args)
    raise NoMethodError, "Subclass must define the #{__method__} method and return a string", caller
  end


  # Given the information, return a string to write to the log upon failure
  #
  # SUBCLASSES SHOULD REDEFINE THIS TO SOMETHING USEFUL
  #
  def failure_str(_args)
    raise NoMethodError, "Subclass must define the #{__method__} method and return a string", caller
  end

end
