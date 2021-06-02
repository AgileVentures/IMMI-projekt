#--------------------------
#
# @class AbstractReqsForMembership
#
# @desc Responsibility: Knows what the membership requirements are for a User
#       - Given a user, it can respond true or false if membership requirements are met.
#
#       This is a very simple class because the requirements are currently very simple.
#       The importance is that
#       IT IS THE ONLY PLACE THAT CODE NEEDS TO BE TOUCHED IF MEMBERSHIP REQUIREMENTS ARE CHANGED.
#
#  Only 1 is needed for the system.
#
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   12/23/17
# @file requirements_for_membership.rb
#
#--------------------------


class AbstractReqsForMembership < AbstractRequirements

  # Check for expected arguments.
  # required argument  user: <value>
  # optional argument  date: <some date>
  def self.has_expected_arguments?(args)
    args_have_keys?(args, [:user])
  end


  def self.requirements_met?(args)
    user = args[:user]
    date = args.fetch(:date, nil).nil? ? Date.current : args[:date]  # corrects if nil is explicitly passed in
    requirements_excluding_payments_met?(user, date) &&
      payment_requirements_met?(user, date)
  end


  def self.requirements_excluding_payments_met?(_user, _date = Date.current)
    raise NoMethodError, "Subclass must define the #{__method__} method and return true or false", caller
  end


  def self.payment_requirements_met?(user, date = Date.current)
    user.payments_current_as_of?(date)
  end


  # @return [Boolean] - if a user must have a completed Membership Guidelines checklist,
  #   return true if has been completed  (false if not completed)
  # else if the user does not have to have a completed Membership Guidelines checklist,
  #   return true (we assume it's fine)
  def self.membership_guidelines_checklist_done?(user)
    UserChecklistManager.completed_membership_guidelines_checklist?(user)
  end
end
