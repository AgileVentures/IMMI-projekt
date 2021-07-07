require 'ordered_ancestry_entry'

#--------------------------
#
# @class UserChecklist
#
# @desc Responsibility: track the status of a checklist item (an AdminOnly::MasterChecklist)
# for a particular User
#
# Note: If a list has sublists (children), it cannot be manually set to un-/completed.
#   The completion status is set automatically based on the children (e.g. if they are are complete or not).
#
#
# What happens when you change the master list?  does it reflect that?
#   - No:  SHF board decided that when a person renews again (or has reason to see the checklist again),
#     the users will see the new/updated/changed information from a master list.  (Otherwise we have to notify each user of the change(s) each time.)
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date  2019-12-04
#
#--------------------------
class UserChecklist < ApplicationRecord

  belongs_to :user
  belongs_to :master_checklist, class_name: "AdminOnly::MasterChecklist", foreign_key: "master_checklist_id"


  has_ancestry

  include OrderedAncestryEntry

  # --------------------------------------------------------------------------

  scope :by_ancestry, -> { order(ancestry: :desc) }

  scope :top_level, -> { where(ancestry: nil) }



  # Membership Guidelines checklist (top level) for the given user
  def self.membership_guidelines_for_user(user)
    UserChecklist.top_level
        .where(master_checklist: AdminOnly::MasterChecklist.latest_membership_guideline_master)
        .where( user: user)
        .order(:created_at)
  end


  def self.completed
    where.not(date_completed: nil)
  end


  def self.uncompleted
    where(date_completed: nil)
  end


  def self.for_user(user)
    where(user: user)
  end


  def self.completed_by_user(user)
    for_user(user).completed
  end


  def self.not_completed_by_user(user)
    for_user(user).uncompleted
  end


  def self.completed_for_master_checklist(master_checklist)
    where(master_checklist: master_checklist).completed
  end


  def self.not_completed_for_master_checklist(master_checklist)
    where(master_checklist: master_checklist).uncompleted
  end

  def self.top_level_for_current_membership_guidelines
    where(master_checklist: AdminOnly::MasterChecklist.latest_membership_guideline_master)
  end

  # Get the most recently completed top level guidelines for the user
  def self.most_recent_completed_top_level_guideline(user)
    UserChecklist.top_level_for_current_membership_guidelines
                 .completed_by_user(user)
                 .order(:date_completed).last
  end

  # Get the top level guidelines created on or after the date for the user, ordered by created_at
  def self.most_recently_created_top_level_guidelines(user, date = Date.current)
    UserChecklist.top_level_for_current_membership_guidelines
                 .for_user(user)
                 .where('created_at >= ?', date)
                 .order(:created_at)
  end
  # --------------------------------------------------------------------------------------

  # Add .includes to the query used to get all descendants to help avoid N+1 queries
  def descendants depth_options = {}
    super #.includes(:user)
  end


  # Add .includes to the query used to get all descendants to help reduce N+1 queries
  def children
    # super.includes(:master_checklist).includes(:user)
    save! unless persisted? # Ancestry gem requires that the object be saved before performing any ancestry queries
    super #.includes(:user)
  end


  # --------------------------------------------------------------------------

  # This checks self _and_ descendants. 'completed?' does not check descendants
  def all_completed?
    !date_completed.blank? && descendants_completed?
  end


  # This checks self _and_ descendants
  #
  # @return [Array<UserChecklist>] - the list of all items that are completed, including self and children
  def all_that_are_completed
    all_complete = descendants.completed.to_a
    all_complete.prepend self unless date_completed.blank?
    all_complete
  end


  # This checks self _and_ descendants
  #
  # @return [Array<UserChecklist>] - the list of all items that are not completed, including self and children
  def all_that_are_uncompleted
    all_uncomplete = descendants.uncompleted.to_a
    all_uncomplete.prepend self if date_completed.blank?
    all_uncomplete
  end


  def descendants_completed?
    descendants.inject(:true) { |is_completed, descendant| descendant.all_completed? && is_completed }
  end


  # This only checks self.  It does not check any descendants. 'all_completed?' also checks descendants.
  def completed?
    !date_completed.nil?
  end


  # @return [Integer] - 100 = 100% complete. The percent complete, based on self or all children.
  def percent_complete
    all_leaves = leaves
    num_leaves = all_leaves.count
    leaves_sum_complete = all_leaves.inject(0) { |sum, leaf| sum + (leaf.completed? ? 100 : 0) }

    leaves_sum_complete.fdiv(num_leaves).round
  end


  # Toggle whether or not this is completed and return a list of all UserChecklists changed because of it.
  # Use the current completed state to determine what the new state should be.
  #
  # @param [Time] new_date_complete- when the entry was completed. default = Time.zone.now
  # @return [Array<UserChecklist>] - a list of all user checklists that were changed
  #
  def all_changed_by_completion_toggle(new_date_complete = Time.zone.now)
    all_completed? ? set_uncomplete_update_parent : set_complete_update_parent(new_date_complete)
  end


  # Set this and all children to completed with the given date
  def set_complete_including_children(new_date_completed = Time.zone.now)
    update(date_completed: new_date_completed)
    set_date_completed(descendants.uncompleted, new_date_completed)
    set_complete_update_parent(new_date_completed)
  end


  # Set this and all children to not completed
  def set_uncomplete_including_children
    update(date_completed: nil)
    set_date_completed(descendants.completed, nil)
    set_uncomplete_update_parent
  end


  # ===================================================================================

  protected


  # Set this to uncompleted (not completed) and also update ancestors if needed.
  #
  # If already uncomplete, do nothing
  #   (this might happen if we are an ancestor of what kicked off the set_uncomplete_update_parent)
  #    if we are uncomplete, our ancestor must also be uncomplete so there is no need to update them.
  # Else change to uncomplete and also update ancestors
  #
  # @return [Array<UserChecklist>] - a list of all user checklists that were changed
  #
  def set_uncomplete_update_parent
    items_changed = []

    unless date_completed.nil?
      update(date_completed: nil) # we ignore new_date_complete in case nothing was passed in
      items_changed << self
      items_changed.concat(parent.set_uncomplete_update_parent) if has_parent?
    end

    items_changed
  end


  # Set this to completed and also update ancestors if needed.
  #
  # If already complete
  #   (this might happen if we are an ancestor of what kicked off the set_complete_update_parent)
  #   update the completion date anyway (because one of our children might have a new completion date.  This shouldn't happen, but we keep this here to ensure data consistency)
  #
  # Can only change to complete if all of our descendants are complete.
  #
  # Update our ancestors.
  #
  # @param [Time] new_date_complete- when the entry was completed. default = Time.zone.now
  # @return [Array<UserChecklist>] - a list of all user checklists that were changed
  #
  def set_complete_update_parent(new_date_complete = Time.zone.now)
    items_changed = []

    if descendants_completed?
      update(date_completed: new_date_complete)
      items_changed << self
      items_changed.concat(parent.set_complete_update_parent(new_date_complete)) if has_parent?
    end

    items_changed
  end


  # Use update_all to set (update) date_completed and updated_at
  # update_all will not set :updated_at.
  # We manually set it first in case changing the date_completed would change the group of records
  # for ar_relation.
  #
  # @param [ActiveRecord::Relation] ar_relation -  the relation (= will resolve to some group of records) that will be updated
  # @param [Time | Nil] new_date_completed - the new value for date_completed
  #
  def set_date_completed(ar_relation, new_date_completed)
    set_updated_at_now(ar_relation)
    ar_relation.update_all(date_completed: new_date_completed)
  end


  def set_updated_at_now(ar_relation)
    ar_relation.update_all(updated_at: Time.zone.now)
  end

end
