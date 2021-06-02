#--------------------------
#
# @class RequirementsForMembershipLapsed
#
# @desc Responsibility: Knows if a membership has lapsed
#
#       This is a very simple class because the requirements are currently very simple.
#       The importance is that
#        it is the only place that code needs to be touched if the rules for
#        if a Membership has lapsed
#
#  Only 1 is needed for the system.
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   2019-01-26
# @file requirements_membership_lapsed.rb
#
#--------------------------
#
class RequirementsForMembershipLapsed < AbstractRequirements

  def self.has_expected_arguments?(args)
    args_have_keys?(args, [:user])
  end


  # A Membership has lapsed if
  #   they are now in the (renewal) grace period
  # OR
  #   they are a former member
  def self.requirements_met?(args)
    user = args[:user]
    user.in_grace_period? || user.former_member?
  end

end
