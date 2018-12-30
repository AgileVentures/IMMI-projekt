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


class RequirementsForMembership < AbstractRequirements

  def self.has_expected_arguments?(args)
    args && args.key?(:user)
  end


  def self.requirements_met?(args)
    user = args[:user]
    user.membership_current? && user.has_approved_shf_application?
  end

end # RequirementsForMembership
