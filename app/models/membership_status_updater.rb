
# Log messages:
#
LOGMSG_APP_UPDATED              = 'SHF_application updated'
LOGMSG_APP_UPDATED_CHECKREASON  = 'Membership checked because this shf_application was updated: '
LOGMSG_PAYMENT_MADE             = 'Payment made'
LOGMSG_PAYMENT_MADE_CHECKREASON = 'Finished checking membership status because this payment was  made: '
LOGMSG_USER_UPDATED             = 'User updated'
LOGMSG_USER_UPDATED_CHECKREASON = 'User updated: '

LOGMSG_MEMBERSHIP_GRANTED = 'Membership granted'
LOGMSG_MEMBERSHIP_RENEWED = 'Membership renewed'
LOGMSG_MEMBERSHIP_REVOKED = 'Membership revoked'


#--------------------------
#
# @class MembershipStatusUpdater
#
# @desc Responsibility:  Keep membership status up-to-date based the current business rules and requirements.
#  - gets notifications from events in the system and does what is needed with them to
#    update the status of memberships for people in the system
#
#    This is a Singleton.  Only 1 is needed for the system.
#
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   12/21/17
# @file membership_status_updater.rb
#
# Goals with this PR:
#   - show how the Observer pattern can and should be used to keep Membership status up to date
#   - Single Responsibilty:  each class should have a *single* responsibility
#     - Currently, the User class is waaay too big!  it has too many responsibilities.
#       This moves the "update membership status based on the business rules"
#       responsibility out of it into the MembershipStatusUpdater class
#
# The Observer pattern can and should also be used to update the company visibility:
#   CompanyVisibilityUpdater has the responsibility of checking to see if the company should currently be visible
#     based on the current business rules.  Thus all of the business rules are just in _one place_.
#     Only 1 class has the responsibility for enforcing them.  No other classes have to care about them.
#
# Satisfies the "Open/Closed" principle in SOLID:  putting the business logic
#   into 1 Observer class keeps it open to extension changes (just this class)
#   but closed to having to modify lots of code when the requirements change
#
#   Business logic for when a Membership is granted or revoked is encapsulated into 1 class that others are _not_ coupled to
#   Ditto with logic about Membership terms - whether they have expired or not, how the ending (expire) date is changed, etc.
#
#    - adding things that need to notify observers is easy:
#      1. include Observable
#      2. after_initialization :add_observers
#      3. def add_observers (and add the observers in that method)
#      4. where appropriate, let the observerse know a change has been made so they can do their thing
#
#
# Payments should split into a Factory and subclasses (MembershipFeePayment, BrandingFeePayment)
#
#--------------------------

class MembershipStatusUpdater < AbstractUpdater

  SEND_EMAIL_DEFAULT = true



  def self.update_requirements_checker
    RequirementsForMembership
  end


  def self.revoke_requirements_checker
    RequirementsForRevokingMembership
  end


  #--------------------------
  # Notifications received from observed classes:
  # - - -
  # Could set up some more generalized meta-code to get information from notifications sent,
  # but for now this is simple to maintain because it is explicit.
  #

  def shf_application_updated(shf_app)
    check_user_and_log(shf_app.user, shf_app, LOGMSG_USER_UPDATED, LOGMSG_USER_UPDATED_CHECKREASON)
  end


  def payment_made(payment)
    check_user_and_log(payment.user, payment, LOGMSG_PAYMENT_MADE, LOGMSG_PAYMENT_MADE_CHECKREASON)
  end


  def user_updated(user)
    check_user_and_log(user, user, LOGMSG_USER_UPDATED, LOGMSG_USER_UPDATED)
  end


  private


  # check the requirements for the user and log information
  def check_user_and_log(user, notification_sender, action_message, reason_check_happened)

    ActivityLogger.open(log_filename, self.class.to_s, action_message, false) do |log|

      check_requirements_and_act({ user: user })

      log.record(:info, "#{reason_check_happened}: #{notification_sender.inspect}")
    end
  end


  # if already a member, then they RENEW, else membership is granted
  def update_action(args)
    user       = args[:user]
    send_email = args.fetch(:send_email, SEND_EMAIL_DEFAULT)

    user.member ? renew_membership(user, send_email) : grant_membership(user, send_email)
  end


  def revoke_update_action(args = {})
    user = args[:user]
    ActivityLogger.open(log_filename, self.class.to_s, LOGMSG_MEMBERSHIP_REVOKED, false) do |log|

      user.update(member: false) # TODO send any email?

      log.record(:info, "#{LOGMSG_MEMBERSHIP_REVOKED}: #{user.inspect}")
      # future: this makes it easy to record an audit trail here
    end
  end


  def grant_membership(user, send_email)

    ActivityLogger.open(log_filename, self.class.to_s, LOGMSG_MEMBERSHIP_GRANTED, false) do |log|

      user.update(member: true, membership_number: user.issue_membership_number) # I don't think a User should be responsible for figuring out the next membership number
      MemberMailer.membership_granted(user).deliver if send_email

      log.record(:info, "#{LOGMSG_MEMBERSHIP_GRANTED}: #{user.inspect}")
    end

  end


  def renew_membership(user, send_email)

    ActivityLogger.open(log_filename, self.class.to_s, LOGMSG_MEMBERSHIP_RENEWED, false) do |log|

     # MemberMailer.membership_renewed(user).deliver if send_email

      log.record(:info, "#{LOGMSG_MEMBERSHIP_RENEWED}: #{user.inspect}")
    end

  end

end # MembershipStatusUpdater

