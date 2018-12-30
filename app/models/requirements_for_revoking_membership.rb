#--------------------------
#
# @class RequirementsForRevokingMembership
#
# @desc Responsibility: Knows what the requirements are for revoking membership for a User
#       - Given a user, it can respond true or false if all requirements are met to revoke membership.
#        Can only revoke a membership if the user is a member
#
#       This is a very simple class because the requirements are currently very simple.
#       The importance is that
#       IT IS THE ONLY PLACE THAT CODE NEEDS TO BE TOUCHED IF MEMBERSHIP REQUIREMENTS ARE CHANGED.
#
#  Only 1 is needed for the system.
#  This is implemented as a Class instead of a Singleton, but either approach is valid.
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   12/23/17
# @file requirements_for_membership.rb
#
#--------------------------


class RequirementsForRevokingMembership < AbstractRequirements

  def self.has_expected_arguments?(args)
    args && args.key?(:user)
  end


  def self.requirements_met?(args)
    args[:user].member?
  end

end # RequirementsForRevokingMembership
