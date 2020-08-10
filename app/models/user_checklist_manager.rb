#--------------------------
#
# @class UserChecklistManager
#
# @desc Responsibility: Handle all behavior and queries for a UserChecklist associated with a User
#
# Current members:  They do not need to agree to the Membership Guidelines checklist until they renew.
# Anyone that is not a member on the 'start requiring membership guidelines date'
# must complete the checklist as a membership requirement.
# Anyone that is already a member on the "start requiring membership guidelines date"
#  does NOT need to complete the checklist -- until they renew.
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   1/23/20
#
#--------------------------


class UserChecklistManager


  # @return
  #   true if
  #     1. the user must complete the membership guidelines AND they have completed it
  #     OR
  #     2. the user does _not_ have to complete the guidelines
  #
  #   false if
  #    1. the user must complete the membership guidelines AND they have _not_ completed it
  #
  def self.completed_membership_guidelines_if_reqd?(user)
    guidelines_required = must_complete_membership_guidelines_checklist?(user)
    return true unless guidelines_required
    return true if guidelines_required && completed_membership_guidelines_checklist?(user)
    false
  end


  def self.completed_membership_guidelines_checklist?(user)
    membership_guidelines_list_for(user)&.all_completed?
  end


  # @return [ nil | UserChecklist] - return nil if there aren't any, else return the most recent one
  def self.membership_guidelines_list_for(user)
    UserChecklist.membership_guidelines_for_user(user)&.last
  end


  def self.membership_guidelines_agreement_required_now?
    Time.zone.now >= membership_guidelines_reqd_start_date
  end


  def self.first_incomplete_membership_guideline_section_for(user)
    if must_complete_membership_guidelines_checklist?(user)
      guideline_list = membership_guidelines_list_for(user) ? membership_guidelines_list_for(user) : AdminOnly::UserChecklistFactory.create_member_guidelines_checklist_for(user)

      guideline_list.children.select { |kid| !kid.completed? }&.sort_by { |kid| kid.list_position }&.first
    else
      nil
    end
  end


  # Is this user required to complete a Membership Guideline checklist?
  # As of 2020-01-23,
  # If someone is a current member as of < when the requirement starts >,
  #   then they do _not_ have to complete the membership guidelines checklist until they renew.
  #   else they DO have to complete the membership guidelines checklist.
  #
  # We only have payment dates and membership expiration dates to work with.
  #
  # Note that it is possible someone has paid ahead so that their membership term doesn't expire until
  #   AFTER   1 membership term (= 1 year) after the requirement starts
  #
  #
  def self.must_complete_membership_guidelines_checklist?(user)
    raise ArgumentError, "User should not be nil. #{__method__}" if user.nil?

    return false unless membership_guidelines_agreement_required_now?
    return true unless user.membership_current?

    # They are are current member AND the guidelines are required today

    one_term_after_req_start_date = User.expire_date_for_start_date(membership_guidelines_reqd_start_date)

    if user.membership_expire_date < one_term_after_req_start_date
      false # today is before the membership expire date else they would no longer be a member.
    else
      # false if last payment made was _before_ the requirements start date
      if user.most_recent_payment.created_at < membership_guidelines_reqd_start_date
        false
      else
        true
      end
    end

  end


  def self.membership_guidelines_reqd_start_date
    # Could use a class variable here to store/cache ('memoize') this, but reading ENV and parsing the Time.zone is pretty fast.  Plus, this won't happen often.
    if ENV.has_key?('SHF_MEMBERSHIP_GUIDELINES_CHECKLIST_REQD_START')
      Time.zone.parse(ENV['SHF_MEMBERSHIP_GUIDELINES_CHECKLIST_REQD_START']).to_time
    else
      missing_membership_guidelines_reqd_start_date
    end
  end


  def self.missing_membership_guidelines_reqd_start_date
    Time.zone.now.localtime.yesterday
  end

end
