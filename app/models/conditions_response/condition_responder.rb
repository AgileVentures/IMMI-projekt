#!/usr/bin/ruby


#--------------------------
#
# @class ConditionResponder
#
# @desc Responsibility: Take a condition and some configuration information
# and _responds_ (handles) the condition.
#
# This might mean looking thru members and sending them emails if
# some particular condition is met, for example.
#
# Although this class is nearly empty right now, it is here to clarify
# the overall design.
#
# TODO: ? rename to ConditionHandler - because it _handles_ conditions, it
# doesn't respond _to_ them or _with_ them (it doesn't send a Condtion to anything.
#  It queries them and does it's own thing)
#
# @date   2018-12-13
#
# @file condition_responder.rb
#
#--------------------------


class ConditionResponder

  Timing = Symbol

  TIMING_BEFORE    = :before
  TIMING_AFTER     = :after
  TIMING_ON        = :on
  TIMING_EVERY_DAY = :every_day

  DEFAULT_TIMING = TIMING_ON
  DEFAULT_CONFIG = {}


  # All subclasses must implement this class. This is how they respond to/
  #  handle a condition.
  #
  # @param condtion [Condition] - the Condition that must be responded do
  # @param log [ActivityLog] - the log file to write to
  def self.condition_response(_condition, _log)
    raise NoMethodError, "Subclass must define the #{__method__} method", caller
  end


  # Get the configuration from the condition
  # @param [Condition]
  # @return [Config] the condition.config,
  #                 or the DEFAULT_CONFIG if there is no condition
  def self.get_config(condition)
    condition.nil? ? DEFAULT_CONFIG : condition.config
  end


  # Get the timing from the condition
  # @param condition [Condition]
  # @return timing [Timing] - condition.timing if condition is nil,
  #                           return the DEFAULT_TIMING
  def self.get_timing(condition)
    condition.nil? ? DEFAULT_TIMING : condition.timing
  end


  # Determine the number of days toay is _away_from_ this date.
  # The :timing is whether we are calculating the number of days
  # _before_, _after_, or _on_ this day, starting from today.
  #
  # @param this_date [Date] - the date to compare to today
  # @param timing [Timing] - which 'direction' (before, after, on) to compare to today
  # @return [Integer] - the number of days away from today, based on our :timing
  def self.days_today_is_away_from(this_date, timing)

    day_num_to_check = 0 # equivalent to checking on today

    if timing_is_before?(timing)
      day_num_to_check = this_date - Date.current
    elsif timing_is_after?(timing)
      day_num_to_check = Date.current - this_date
    end

    day_num_to_check.to_i
  end


  def self.timing_is_before?(timing)
    timing == TIMING_BEFORE
  end


  def self.timing_is_after?(timing)
    timing == TIMING_AFTER
  end


  def self.timing_is_on?(timing)
    timing == TIMING_ON
  end


  def self.timing_is_every_day?(timing)
    timing == TIMING_EVERY_DAY
  end


end # ConditionResponder
