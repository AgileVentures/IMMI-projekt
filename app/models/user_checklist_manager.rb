#--------------------------
#
# @class UserChecklistManager
#
# @desc Responsibility: Handle all behavior and queries for a UserChecklist associated with a User
#
# 2020-12-07  Business Rule: Everyone must always agree to the membership guidelines,
#   no matter when their term starts/ends, etc.
#   The only limiting factor is when the Membership Guidelines requirement started.
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   1/23/20
#
#--------------------------

class UserChecklistManager

  # former members MUST complete the guidelines again. (They have not completed the current version)
  def self.completed_membership_guidelines_checklist?(user)
    if user.in_grace_period?
      find_on_or_after_latest_membership_start(user)&.all_completed?
    elsif user.former_member?
      false
    else
      membership_guidelines_list_for(user)&.all_completed?
    end
  end


  def self.find_or_create_on_or_after_latest_membership_start(user)
    latest_membership_start = MembershipsManager.most_recent_membership(user)&.first_day
    return create_for_user_if_needed(user) unless latest_membership_start

    found_guideline = UserChecklist.most_recently_created_top_level_guidelines(user, latest_membership_start).uncompleted.last
    create_for_user_if_needed(user, guideline: found_guideline)
  end


  def self.find_on_or_after_latest_membership_start(user)
    latest_membership_start = MembershipsManager.most_recent_membership(user)&.first_day
    return nil unless latest_membership_start

    UserChecklist.most_recently_created_top_level_guidelines(user, latest_membership_start).last
  end


  def self.find_or_create_membership_guidelines_list_for(user)
    create_for_user_if_needed(user, guideline: membership_guidelines_list_for(user))
  end


  def self.create_for_user_if_needed(user, guideline: nil)
    guideline.nil? ? create_for_user(user) : guideline
  end


  def self.create_for_user(user)
    AdminOnly::UserChecklistFactory.create_member_guidelines_checklist_for(user)
  end


  # @return [ nil | UserChecklist] - return nil if there aren't any,
  #   else return the most recently created top level checklist
  #   _membership_guidelines_for_user_ returns only top level checklist (the roots of any nested checklists)
  def self.membership_guidelines_list_for(user)
    UserChecklist.membership_guidelines_for_user(user)&.last
  end


  # Gets the first incomplete guideline (checklist) for the user.
  # If the user does not have to complete the membership guidelines, return nil.
  # If there are no guidelines, return nil.
  # If there are no incomplete guidelines, return nil.
  #
  # Else return the first uncompleted checklist (since they are given to us here as sorted)
  # @return [Nil | UserChecklist]
  def self.first_incomplete_membership_guideline_section_for(user)
    not_completed_guidelines_for(user)&.first
  end


  def self.completed_guidelines_for(user)
    guidelines_for(user, :completed)
  end


  def self.not_completed_guidelines_for(user)
    # guideline_list.descendants.uncompleted.to_a
    guidelines_for(user, :uncompleted)
  end


  # Make one if it doesn't exist?  NO.  Just return empty list.
  # The selection_block is being used explictly so it's very clear.  (Could have also use yield.)
  def self.guidelines_for(user, completed_method = :completed)
    guideline_list = membership_guidelines_list_for(user) ? membership_guidelines_list_for(user) : {}
    return [] unless guideline_list.present?

    guideline_list.descendants&.send(completed_method).to_a&.sort_by { |kid| "#{kid.ancestry}-#{kid.list_position}" }
  end


  def self.checklist_done_on_or_after_latest_membership_start?(user)
    latest_membership_start = MembershipsManager.most_recent_membership(user)&.first_day
    return false unless latest_membership_start

    most_recent_completed = UserChecklist.most_recent_completed_top_level_guideline(user)
    (!!most_recent_completed && most_recent_completed.date_completed >= latest_membership_start)
  end
end
