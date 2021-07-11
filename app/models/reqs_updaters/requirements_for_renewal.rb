#--------------------------
#
# @class RequirementsForRenewal
#
# @desc Responsibility: Knows what the requirements are for a Member to renew membership.
#       - Given a member, it can respond true or false if the membership renewal requirements are met.
#   Note that it is _not_ the responsibility of this class to know if the given member has been
#   unpaid so long that they cannot simply 'renew' but must re-apply.
#
#       This is a very simple class because the requirements are currently very simple.
#       The importance is that
#       IT IS THE ONLY PLACE THAT CODE NEEDS TO BE TOUCHED IF MEMBERSHIP REQUIREMENTS ARE CHANGED.
#
#  Only 1 is needed for the system.
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   12/08/20
#
#--------------------------

class RequirementsForRenewal < AbstractReqsForMembership

  def self.requirements_excluding_payments_met?(user, date = Date.current)
    user.may_renew? &&
      user.valid_date_for_renewal?(date) &&
      user.has_approved_shf_application? &&
      checklist_done_on_or_after_latest_membership_start?(user) &&
      doc_uploaded_during_this_membership_term?(user)
  end


  # @return [Boolean] - Has the user uploaded at least 1 document since the start of this membership term?
  # FIXME - in the last year of the membership term or during the payment term?
  #   - what if the member paid for 2 terms in advance?
  def self.doc_uploaded_during_this_membership_term?(user)
    user.file_uploaded_during_this_membership_term?
  end


  def self.checklist_done_on_or_after_latest_membership_start?(user)
    UserChecklistManager.checklist_done_on_or_after_latest_membership_start?(user)
  end
end
