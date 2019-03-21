#--------------------------
#
# @class RequirementsForHBrandingFeeWillNotExpire
#
# @desc Responsibility: Knows when an H-Branding Fee will NOT be due for a company
# (= the requirements are met)
#
#       This is a very simple class because the requirements are currently very simple.
#       The importance is that
#        it is the only place that code needs to be touched if the rules for
#        when an H-Branding fee will _not_ be due are changed.
#
#  Only 1 is needed for the system.
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   2019-03-05
# @file requirements_for_h_branding_fee_will_not_expire.rb
#
#--------------------------


class RequirementsForHBrandingFeeWillNotExpire < AbstractOppositeRequirements

  def self.opposite_class
    RequirementsForHBrandingFeeWillExpire
  end

end
