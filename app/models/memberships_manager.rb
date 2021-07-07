#--------------------------
#
# @class MembershipsManager
#
# @desc Responsibility: manage memberships for a User; respond to queries about Memberships
#
# TODO should the methods checking about a date be in the Membership class?
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2/16/21
#
#--------------------------

# TODO should this be renamed to MembershipsTermManager?  This is mostly about dates for the term
class MembershipsManager

  EXPIRES_SOON_STATUS = :expires_soon

  # Informational statuses are those that are _not_ used when determining the next status
  # (membership statuses that are transitioned from/to). They are just helpful information
  # presented to admins, users, members.
  #   TODO is there a better name for these?
  INFORMATIONAL_MEMBERSHIP_STATUSES = [EXPIRES_SOON_STATUS]

  MOST_RECENT_MEMBERSHIP_METHOD = :last_day

  # =============================================================================================

  def self.expires_soon_status
    EXPIRES_SOON_STATUS
  end


  def self.informational_statuses
    INFORMATIONAL_MEMBERSHIP_STATUSES
  end


  def self.most_recent_membership_method
    MOST_RECENT_MEMBERSHIP_METHOD
  end


  # @return [Duration] - the number of days that a Member can renew early
  def self.days_can_renew_early
    AdminOnly::AppConfiguration.config_to_use.payment_too_soon_days.to_i.days
  end


  # @return [Duration] - the number of days after the end of a membership that a user can renew
  def self.grace_period
    AdminOnly::AppConfiguration.config_to_use.membership_expired_grace_period_duration
  end


  # @return [Integer] - the number of days before the end of a membership that means 'soon'
  #   as in 'your membership is expiring soon'
  def self.is_expiring_soon_amount
    AdminOnly::AppConfiguration.config_to_use.membership_expiring_soon_days.to_i.days
  end


  # Create an ArchivedMembership for every Membership for the user
  #
  # @return [True|False] - return false if any failed, else true if all succeeded
  def self.create_archived_memberships_for(user)
    user.memberships.each do | membership |
      ArchivedMembership.create_from(membership)
    end
    true # no errors were raised
  end


  def self.get_next_membership_number
    # FIXME - implement here?  or call User method for now?
  end


  # @return [nil | Membership] - nil if no Memberships,
  # else the one with the latest last day
  def self.most_recent_membership(user)
    memberships = user.memberships
    return nil if memberships.empty?

    memberships.order(most_recent_membership_method)&.last
  end

  # ---------------------------------------------------------------------------------

  def most_recent_membership(user)
    self.class.most_recent_membership(user)
  end


  def most_recent_membership_method
    self.class.most_recent_membership_method
  end


  # Does a user have a membership that has not expired as of the given date
  # Note this does not determine if payments were made, requirements were met, etc.
  def has_membership_on?(user, this_date)
    return false if this_date.nil?

    Membership.for_user_covering_date(user, this_date).exists?
  end


  # @return [nil | Membership] - oldest Membership for the user where
  #   first_day <= this_date <= last_day
  #   return nil if no membership for the user exists with that condition
  def membership_on(user, this_date = Date.current)
    return nil if this_date.nil? || user.nil?

    Membership.for_user_covering_date(user, this_date)&.first
  end


  # The membership term has expired, but are they still within a 'grace period'?
  def membership_in_grace_period?(user,
                                  this_date = Date.current,
                                  membership: most_recent_membership(user))
    return false if membership.nil?

    date_in_grace_period?(this_date, last_day: membership.last_day)
  end


  def date_in_grace_period?(this_date = Date.current,
                            last_day: Date.current,
                            grace_days: grace_period)
      this_date > last_day &&
      this_date <= (last_day + grace_days)
  end


  def date_after_grace_period_end?(user,
                                   this_date = Date.current,
                                   membership: most_recent_membership(user))
    return false if membership.nil?

    this_date > (membership.last_day + grace_period)
  end


  # @return [Integer]
  def grace_period
    self.class.grace_period
  end


  def today_is_valid_renewal_date?(user)
    valid_renewal_date?(user, Date.current)
  end


  # Is this a valid date for renewing?
  # This just checks the membership status and dates about renewal,
  #   not any requirements for renewing a membership.
  #
  def valid_renewal_date?(user, this_date = Date.current)
    return false unless user.in_grace_period? || has_membership_on?(user, this_date)

    last_day = most_recent_membership_last_day(user)
    if this_date <= last_day
      this_date >= (last_day - days_can_renew_early)
    else
      membership_in_grace_period?(user, this_date)
    end
  end


  def most_recent_membership_first_day(user)
    most_recent_membership(user)&.first_day
  end


  def most_recent_membership_last_day(user)
    most_recent_membership(user)&.last_day
  end


  # @return [Integer]
  def days_can_renew_early
    self.class.days_can_renew_early
  end

  # Is the Membership expiring soon?
  #  true if the user is a member
  #     AND today is on or after the (last day - the expiring soon amount)
  def expires_soon?(user, membership = most_recent_membership(user))
    user.current_member? && !!membership && ((membership.last_day - self.class.is_expiring_soon_amount) <= Date.current)
  end

end
