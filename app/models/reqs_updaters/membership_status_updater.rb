# Log messages:
#
LOGMSG_APP_UPDATED = 'SHF_application updated' unless defined? LOGMSG_APP_UPDATED
LOGMSG_PAYMENT_MADE = 'Payment made' unless defined? LOGMSG_PAYMENT_MADE
LOGMSG_CHECKLIST_COMPLETED = 'Checklist completed' unless defined? LOGMSG_CHECKLIST_COMPLETED

LOGMSG_USER_UPDATED = 'User updated' unless defined? LOGMSG_USER_UPDATED

LOGMSG_MEMBERSHIP_GRANTED = 'Membership granted' unless defined? LOGMSG_MEMBERSHIP_GRANTED
LOGMSG_MEMBERSHIP_RENEWED = 'Membership renewed' unless defined? LOGMSG_MEMBERSHIP_RENEWED
LOGMSG_MEMBERSHIP_REVOKED = 'Membership revoked' unless defined? LOGMSG_MEMBERSHIP_REVOKED

#--------------------------
#
# @class MembershipStatusUpdater
#
# @desc Responsibility:  Keep membership status up-to-date based the current business rules
#    and requirements.
#  - gets notifications from events in the system and does what is needed with them to
#    update the status of memberships for people in the system
#
#    This is a Singleton.  Only 1 is needed for the system.
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   12/21/17
# @file membership_status_updater.rb
#
# Only check to see if requirements have been satisfied for Renewal or Membership when:
#   * a payment is made
#   * a checklist is completed
#
# Otherwise each time the requirements for renewal or membership are checked (e.g. at login),
# the payment and non-payment requirements will be satisfied and membership or renewal will be
# incorrectly granted again.
# In other words, the only time that we _should_ check to see if membership or renewal can be granted
# is when a payment is made.
#
#
# The Observer pattern is used to send notifications (methods) when something
# 'interesting' has changed.  When the MembershipStatusUpdater receives one of these
# notifications, it checks the membership to see if it needs to be changed (updated
# or revoked).  It does this via the :check_requirements_and_act({ user: user })
# method.  (This method is the public interface and main method for all
# Updater classes.)
#
# This check is logged with the ActivityLogger so that anything that happens is
# logged.
#
#
#   MembershipStatusUpdater has the responsibility of checking to see if the membership
#   should be updated or revoked based on the current business rules.
#   Thus all of the business rules can be in just _one place_ (DRY).
#   Only 1 class has the responsibility for enforcing them.  No other classes have to care about them.
#
#   Satisfies the "Open/Closed" principle in SOLID:  putting the business logic
#   into 1 Observer class keeps it open to extension changes (just this class)
#   but closed to having to modify lots of code when the requirements change
#
#   Business logic for when a Membership is granted or revoked is encapsulated into 1 class
#   that others are _not_ coupled to.
#   Ditto with logic about Membership terms - whether they have expired or not,
#   how the ending (expire) date is changed, etc.
#
#--------------------------

class MembershipStatusUpdater
  include Singleton

  SEND_EMAIL_DEFAULT = true

  # -----------------------------------------------------------------------------------
  # Notifications received from observed classes:
  # - - -
  # Could set up some more generalized meta-code to get information from notifications sent,
  # but this is simple to maintain because it is explicit.
  #

  def shf_application_updated(shf_app, send_email: send_email_default)
    update_membership_status(shf_app.user, shf_app, logmsg_app_updated, send_email: send_email)
  end


  # Check to see if the user can now be granted membership or renewed.
  def payment_made(payment, send_email: send_email_default)
    check_grant_membership_or_renew(payment.user, payment, logmsg_payment_made, send_email: send_email) if payment.membership_payment?
  end


  # Check to see if the user can now be granted membership or renewed.
  def checklist_completed(checklist_root, send_email: send_email_default)
    check_grant_membership_or_renew(checklist_root.user, checklist_root, logmsg_checklist_completed, send_email: send_email)
  end


  def user_updated(user, send_email: send_email_default)
    update_membership_status(user, user, logmsg_user_updated, send_email: send_email)
  end


  # end of Notifications received from observed classes
  # -----------------------------------------------------------------------------------

  def check_grant_renew_and_status(given_user, notifier = nil, reason_update_happened = nil,
                                   send_email: send_email_default)

    check_grant_membership_or_renew(given_user, notifier, reason_update_happened,
                                    send_email: send_email)

    update_membership_status(given_user, notifier, reason_update_happened,
                             send_email: send_email)
  end


  def check_grant_membership_or_renew(given_user, notifier = nil, reason_update_happened = nil,
                                      send_email: send_email_default)
    today = Date.current

    log_and_check("#{__method__}", given_user, [notifier], notifier, reason_update_happened) do |user, _other_args, log|
      # next_membership_start_date =  user.membership_expire_date.nil? ? today : user.membership_expire_date + 1.day
      if user.membership_expire_date.nil? || user.membership_expire_date < today
        next_membership_start_date = today
      else
        next_membership_start_date = user.membership_expire_date + 1
      end

      if user.not_a_member? || user.former_member?
        if RequirementsForMembership.satisfied?(user: user)
          user.start_membership!(date: next_membership_start_date, send_email: send_email)
          log.info(user.membership_changed_info)
        end

      elsif user.current_member? || user.in_grace_period?
        if RequirementsForRenewal.satisfied?(user: user)
          user.renew!(date: next_membership_start_date, send_email: send_email)
          log.info(user.membership_changed_info)
        end
      end
    end
  end


  #  This is the main method for checking and changing the membership status.
  #     TODO: for a given date
  #
  def update_membership_status(given_user, notifier = nil, reason_update_happened = nil,
                               send_email: send_email_default)
    today = Date.current

    log_and_check("#{__method__}", given_user, [notifier], notifier, reason_update_happened) do |user, _other_args, log|

      if user.current_member?
        if user.membership_expired_in_grace_period?(today)
          user.start_grace_period!(send_email: send_email)
          log.info(user.membership_changed_info)

        elsif user.membership_past_grace_period_end?(today)
          # This should only happen when seeding. But just in case the membership status has not been updated for
          # a while and so hasn't transitioned to in_grace_period, we'll do it manually now and then
          # go on and transition to a former member
          user.start_grace_period!(send_email: send_email)
          log.info(user.membership_changed_info)
          user.make_former_member!(send_email: send_email)
          log.info(user.membership_changed_info)
        end

      elsif user.in_grace_period?
        if user.membership_past_grace_period_end?(today)
          user.make_former_member!(send_email: send_email)
          log.info(user.membership_changed_info)
        end
      end
    end
  end


  def log_and_check(calling_method, user, other_args, notifier, reason_update_happened)
    ActivityLogger.open(log_filename, self.class.to_s, calling_method, false) do |log|
      log.info("#{calling_method} for #{user.inspect}")
      log.info("#{reason_update_happened}: #{notifier.inspect}") unless notifier.blank?
      yield(user, other_args, log) if block_given?
    end
  end


  def send_email_default
    SEND_EMAIL_DEFAULT
  end


  def logmsg_app_updated
    LOGMSG_APP_UPDATED
  end


  def logmsg_user_updated
    LOGMSG_USER_UPDATED
  end


  def logmsg_payment_made
    LOGMSG_PAYMENT_MADE
  end


  def logmsg_checklist_completed
    LOGMSG_CHECKLIST_COMPLETED
  end


  # -----------------------------------------------------------------------------------------------

  private

  def log_filename
    LogfileNamer.name_for(self.class.name)
  end
end
