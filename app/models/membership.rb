# Individual Membership
#    TODO: abstract common out, create CompanyMembership, DonorMembership
#
class Membership < ApplicationRecord

  belongs_to :user
  # TODO: membership has_many :payments

  # BUSINESS RULE: Definition of a first membership
  #   A 'first membership' is a membership for a user only if there are no past memberships within
  #     2 years
  #   If a user had a past membership within the previous _2 years_, then they are considered a
  #    "former member."  This may mean that there are different behaviours/actions/expectations.
  #    (Ex: a different welcome email might be sent out.)
  #
  FIRST_MEMBERSHIP_TIMELIMIT = 2.years

  # =============================================================================================

  # @return [ActiveRecord::Relation] - all Memberships that were active on the given date,
  #   ordered by the last_day.  "active" means the first day was on or before the given date
  #   AND the last_day was on or after the given date.
  def self.covering_date(date = Date.current)
    where('first_day <= ?', date)
      .where('last_day >= ?', date)
      .order(last_day: :asc, id: :asc)
  end


  def self.for_user_covering_date(user, date = Date.current)
    where(user: user).covering_date(date)
  end


  def self.starting_on_or_after(first_day = Date.current)
    where('first_day >= ?', first_day)
  end


  # @return [ActiveRecord::Relation] - a list of any memberships for the user
  #   that started on or after the first_day
  def self.for_user_starting_on_or_after(user, first_day = Date.current)
    where(user: user).starting_on_or_after(first_day)
  end

  # @return [ActiveSupport::Duration] - the membership term length as a Duration
  def self.term_length
    AdminOnly::AppConfiguration.config_to_use.membership_term_duration
  end


  def self.first_day_from_last(last_day = Date.current)
    # last_day - term_length + 1.day
    other_day_from(last_day, -1)
  end


  def self.last_day_from_first(first_day = Date.current)
    # first_day + term_length - 1.day
    other_day_from(first_day, 1)
  end


  def self.other_day_from(date, multiplier = 1)
    date + (multiplier * (term_length - 1.day))
  end


  def self.first_membership_time_period
    FIRST_MEMBERSHIP_TIMELIMIT
  end

  # -----------------------------------------------------------------------------------------------


  def set_first_day_and_last(first_day: Date.current, last_day: (self.class.other_day_from(first_day)))
    update(first_day: first_day, last_day: last_day)
  end


  # @return - true if this is the first membership ever for the user,
  #   where the definition of a first membership is (see above in the class block comment)
  #   Ignore this membership (self)
  def first_membership?(time_period: FIRST_MEMBERSHIP_TIMELIMIT)
    (any_membership_within(time_period).reject { |membership| membership == self }).empty?
  end

  # @return [ActiveRecord::Relation] - a list of any memberships for the user
  #   that started on or after the (starting date - time_period)
  def any_membership_within(time_period = FIRST_MEMBERSHIP_TIMELIMIT, starting_date: Date.current)
    self.class.for_user_starting_on_or_after(user, starting_date - time_period)
  end
end
