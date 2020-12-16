require 'ordered_ancestry_entry'

module AdminOnly

  class MasterChecklistError < StandardError
  end

  class CannotChangeAttributeError < MasterChecklistError
  end

  class HasCompletedUserChecklistsCannotChange < CannotChangeAttributeError
  end

  class CannotChangeUserVisibleInfo < CannotChangeAttributeError
  end


  #--------------------------
  #
  # @class MasterChecklist
  #
  # @desc Responsibility: This is the master list that is a template for
  #  UserChecklists that are created.  It is the source (blueprint) for the
  #  UserChecklists.
  #  By including OrderedAncestryEntry, it becomes an ordered and nested list.
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date 2019-12-01
  #
  #--------------------------
  #
  #
  class MasterChecklist < ApplicationRecord

    belongs_to :master_checklist_type

    validates_presence_of :master_checklist_type
    validates_presence_of :name
    validates_presence_of :displayed_text
    validates_presence_of :list_position

    before_update :can_be_changed?


    # Don't delete if there are any associated user_checklists.
    #
    # The before_destroy check is a failsafe in case
    # destroy is called outside a method that checks information and business logic
    # to see if the object can really be destroyed.
    before_destroy :can_be_destroyed?, prepend: true

    USER_CHECKLIST_CLASS = UserChecklist

    has_many :user_checklists, class_name: "#{USER_CHECKLIST_CLASS}", dependent: :destroy
    has_many :users, through: :user_checklists

    has_ancestry

    include OrderedAncestryEntry

    scope :completed_userchecklists, -> { where(id: USER_CHECKLIST_CLASS.completed.pluck(:id)) }
    scope :uncompleted_userchecklists, -> { where(id: USER_CHECKLIST_CLASS.uncompleted.pluck(:id)) }

    scope :in_use, -> { where(is_in_use: true) }
    scope :not_in_use, -> { where(is_in_use: false) }

    scope :top_level_checklists, -> { where(ancestry: nil) }
    scope :top_level_in_use, -> { top_level_checklists.in_use }


    # Delegate class methods
    class << self

      # will get an error if I try to use the class directly, hence the constant
      CHANGE_POLICY = AdminOnly::MasterChecklistChangePolicy

      delegate :attributes_can_change_with_completed,
               :attributes_displayed_to_users,
               :change_with_completed_user_checklists?,
               :change_with_uncompleted_user_checklists?,
               to: :CHANGE_POLICY

    end

    CHANGE_POLICY = AdminOnly::MasterChecklistChangePolicy

    delegate :change_with_completed_user_checklists?,
             :change_policy, to: :class

    # delegate :no_more_major_changes?,
    #          :can_be_destroyed?,
    #          :can_delete?,
    #          :can_add_child?,
    #          :has_completed_user_checklists?,
    #          to: :CHANGE_POLICY

    # --------------------------------------------------------------------------

    def self.user_checklist_class
      USER_CHECKLIST_CLASS
    end


    def self.change_policy
      AdminOnly::MasterChecklistChangePolicy
    end


    # TODO hardcoded for now.  get from AppConfiguration later
    # get the most recently updated Master that is a 'membership_guidelines_type'
    #
    def self.latest_membership_guideline_master
      AdminOnly::MasterChecklist.in_use.where(master_checklist_type: AdminOnly::MasterChecklistType.membership_guidelines_type).top_level_checklists.order(:updated_at).last
    end


    # FIXME - this is not correct. If a list was deleted/marked as not in use, this number is just an _order_ but not the human understandable list #
    def self.top_level_next_list_position
      default_next_position = 1
      top_checklists = top_level_in_use
      top_checklists.empty? ? default_next_position : top_checklists.pluck(:list_position).max + 1
    end


    # Return the entry and all children as an Array, sorted by list position and then name.
    # This just passes the name to the OrderedAncestryEntry method so the result is ordered with the name
    # @return [Array<MasterChecklist>] - an Array with the given node first,
    #   then its children sorted by the ancestry, list position, and then name.
    #
    def self.all_as_array_nested_by_name
      all_as_array(order: %w(name))
    end


    # ------------------------------------------------------------------------------------


    def user_checklist_class
      self.class.user_checklist_class
    end


    def no_more_major_changes?
      delegate_to_change_policy(__method__)
    end


    def can_add_child?
      delegate_to_change_policy(__method__)
    end


    def can_be_changed?(attributes_to_change = [])
      delegate_to_change_policy(__method__, attributes_to_change)
    end


    # The before_destroy check with can_be_destroyed? is a failsafe in case
    # destroy is called outside this method (with no business logic checks, etc.)
    def can_be_destroyed?
      delegate_to_change_policy(__method__)
    end


    def can_delete?
      delegate_to_change_policy(__method__)
    end


    def has_completed_user_checklists?
      self.user_checklist_class.completed_for_master_checklist(self).count > 0
    end


    # @return [ActiveRecord::Relation] - all descendants that have is_in_use set to true
    def descendants_in_use
      descendants.where(is_in_use: true)
    end


    # @return [ActiveRecord::Relation] - all descendants that have is_in_use set to false
    def descendants_not_in_use
      descendants.where(is_in_use: false)
    end


    def completed_user_checklists
      user_checklist_class.completed_for_master_checklist(self)
      # user_checklists.reject(&:all_completed?) #{ |user_checklist| user_checklist.all_completed? }
    end


    def uncompleted_user_checklists
      user_checklist_class.not_completed_for_master_checklist(self)
      # user_checklists.reject(&:all_completed?) #{ |user_checklist| user_checklist.all_completed? }
    end


    alias_method :not_completed_user_checklists, :uncompleted_user_checklists


    # @return [Array<AdminOnly::MasterChecklist>] - list of MasterChecklists that can be a parent to this one.
    #  Only those that are currently in use are returned.
    def allowable_parents(potential_parents = [])
      allowable_as_parents(potential_parents).select(&:is_in_use)
    end


    def toggle_is_in_use
      set_is_in_use(!is_in_use)
    end


    def set_is_in_use(in_use = true)

      # Use a Transaction so that any children or USER_CHECKLIST_CLASSs that are changed
      # are _rolled back_ if there is a failure at any point in the process.

      self.class.transaction do
        children.each { |child| child.set_is_in_use(in_use) }
        in_use ? change_to_being_in_use : ( can_delete? ? destroy : mark_as_no_longer_used)
      end

    end


    def change_to_being_in_use
      change_is_in_use(true)
      add_to_parent_list_positions if ancestors?
    end


    # :insert is used by the OrderedListEntry.
    # Wrapping it in this method makes the intention clear
    # and helps to keep "insert" from being ambiguous
    def add_to_parent_list_positions
      parent.insert(self)
    end


    def mark_as_no_longer_used
      change_is_in_use(false)
      parent.remove_child_from_list_positions(self) if ancestors? # don't delete from the db, just remove from the parent list
    end


    # REMOVE the entry from the list positions by (1) setting the child list position to 0
    # and (2) updating the list positions of all other children as if this
    # child was not in the list.
    #
    # Do NOT delete the child from the db (persistent store).
    #
    # This might be used if the removed entry needs to be flagged as "no longer in use" or "archived"
    # and remain in the database.
    #
    # This may lead to a situation where more than one child has the same list_position (e.g. position 0)
    # Only 1 child should be 'in use'; others can have the same list_position but not be in use ( = 'removed')
    #   -- This adds a variation to how a OrderedAncestryEntry is defined.
    #
    # @param entry [MasterChecklist] - the entry to 'removed' from the list positions
    # @return [Array] - children
    def remove_child_from_list_positions(entry)
      if children.include?(entry)
        decrement_child_positions(entry.list_position)
      end
      children
    end


    def change_is_in_use(new_value = false, changed_time = Time.zone.now)
      update(is_in_use: new_value, is_in_use_changed_at: changed_time)
    end


    # @param [String] prefix - the string that represents one level of depth; is
    #   prepended :depth times in front of the name
    # @return [String] - a string showing the depth of this entry and the name
    def display_name_with_depth(prefix: '-')
      "#{prefix * depth} #{name}"
    end


    # =============================================================================

    private


    def delegate_to_change_policy(method, *original_args)
      delegate_with_self_to(change_policy, method.to_sym, *original_args)
    end


    # Sends :method to delegatee with self as the first argument
    def delegate_with_self_to(delegatee, method, *original_args)
      original_args.blank? ? delegatee.send(method.to_sym, self) :
          delegatee.send(method.to_sym, self, *original_args)
    end

  end

end
