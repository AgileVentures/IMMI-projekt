#--------------------------
#
# @class RequirementsForMembership
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
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   12/23/17
# @file requirements_for_membership.rb
#
#--------------------------


class RequirementsForMembership < AbstractReqsForMembership

  def self.requirements_excluding_payments_met?(user, _date = Date.current)
    user.may_start_membership? &&
      user.has_approved_shf_application? &&
      membership_guidelines_checklist_done?(user)
  end
end
