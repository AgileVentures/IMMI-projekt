#--------------------------
#
# @class Memberships::MembershipActions
#
# @desc Responsibility: super class that defines the strategy for all Membership Actions
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   3/7/21
#
#--------------------------------------------------------------------------------------------------
module Memberships
  class MembershipActions

    SEND_EMAIL_DEFAULT = true
    LOGMSG_INVALID_KEYWORD_ARGS = 'Invalid keyword args sent to Membership Action'


    # This is the main strategy (algorithm) for writing to the log(s) and doing the actions
    # needed.
    # Subclasses should define their own other_keyword_args_valid? and accomplish_actions methods.
    #
    # other_keyword_args is all keyword arguments passed after the first one (user) and
    #   the (send_email: keyword argument) or the end
    def self.for_user(user, send_email: do_send_email, **other_keyword_args)

      if other_keyword_args_valid?(other_keyword_args)
        ActivityLogger.open(log_filename, self.name, log_message_success, false) do |log|
          successful = accomplish_actions(user, send_email: send_email, **other_keyword_args)
          log.info("#{log_message_success}: #{user.inspect}") if successful
        end
      else
        ActivityLogger.open(log_filename, self.class.to_s, log_message_success, false) do |log|
          log.warn("#{log_message_invalid_keyword_args}: user: #{user.inspect}, send_email: #{send_email}, #{other_keyword_args.inspect}")
        end
      end
    end


    # Subclasses should override this to validate the expected other keyword arguments
    # @return [true | false]
    def self.other_keyword_args_valid?(_other_keyword_args)
      raise NoMethodError, "#{__method__}: Subclasses must implement this method to validate the other keyword arguments given (return true or false)."
    end


    # Subclasses must define this.  Do all of the actions needed.
    # @return [True | False] - did this accomplish everything successfully?
    #   Would be better to return a Successful obj. This violates the ruby ... of ending a method with a ? if it returns a boolean
    def self.accomplish_actions(_user, _send_email: do_send_email, **_other_keyword_args)
      raise NoMethodError, "#{__method__}: Subclasses must implement this method to do whatever is needed (for their action)."
      false  # This is here to make syntax checking happy regarding the @return comment
    end


    def self.do_send_email
      SEND_EMAIL_DEFAULT
    end


    # Subclasses must override this to use the specific success message for their class.
    def self.log_message_success
      raise NoMethodError, "#{__method__}: Subclasses must implement this method with a meaningful success message for the log(s)."
    end


    # Note that the log filename is the MembershipStatusUpdater log!
    def self.log_filename
      LogfileNamer.name_for(MembershipStatusUpdater.name)
    end


    def self.log_message_invalid_keyword_args
      LOGMSG_INVALID_KEYWORD_ARGS
    end
  end

end
