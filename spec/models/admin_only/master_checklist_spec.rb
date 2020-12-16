require 'rails_helper'

RSpec.describe AdminOnly::MasterChecklist, type: :model do
  let(:child_one) { create(:master_checklist, name: 'child 1') }
  let(:child_two) { create(:master_checklist, name: 'child 2') }
  let(:child_three) { create(:master_checklist, name: 'child 3') }

  let(:two_children) do
    # Can add children to a list either by setting the parent: with a call to the Factory
    # or by using .insert
    list = create(:master_checklist, name: 'two children')
    create(:master_checklist, name: 'child 1', parent: list)
    create(:master_checklist, name: 'child 2', parent: list)
    list
  end

  let(:three_children) do
    # Can add children to a list either by setting the parent: with a call to the Factory
    # or by using .insert
    list = create(:master_checklist, name: 'three children')
    list.insert(child_one)
    list.insert(child_two)
    list.insert(child_three)
    list
  end

  it 'the user checklist class is UserChecklist' do
    expect(described_class.user_checklist_class).to eq UserChecklist
  end

  describe 'Factories' do
    it 'default factory is valid' do
      expect(create(:master_checklist)).to be_valid
    end

    it 'arguments passed in are valid' do
      expect(create(:master_checklist, name: 'new entry 1')).to be_valid
      expect(create(:master_checklist, parent_name: 'new entry 1')).to be_valid
    end

    it 'traits are valid' do
      expect(create(:master_checklist, :not_in_use)).to be_valid
    end

    it 'subtype :membership_guidelines_master_checklist is valid' do
      master_guidelines_list = create(:membership_guidelines_master_checklist)
      expect(master_guidelines_list).to be_valid
      expect(master_guidelines_list.master_checklist_type.name).to eq(AdminOnly::MasterChecklistType.membership_guidelines_type_name)
      expect(AdminOnly::MasterChecklistType.membership_guidelines_type).not_to be_nil
    end
  end


  describe 'Validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :displayed_text }
    it { is_expected.to validate_presence_of :list_position }
  end


  describe '.change_with_completed_user_checklists?' do

    attribs_can_be_changed = ['is_in_use', 'is_in_use_changed_at', 'notes', 'updated_at']

    it 'notes' do
      expect(create(:master_checklist).change_with_completed_user_checklists?('notes')).to be_truthy
    end

    describe 'these attributes can be changed' do
      attribs_can_be_changed.sort.each do |attrib_can_change|
        it "#{attrib_can_change}" do
          expect(described_class.change_with_completed_user_checklists?(attrib_can_change)).to be_truthy
        end
      end
    end

    describe 'all other attributes cannot be changed' do
      attribs_cannot_be_changed = described_class.attribute_names.reject { |attrib| attribs_can_be_changed.include? attrib }
      attribs_cannot_be_changed.sort.each do |attrib_cant_be_changed|
        it "#{attrib_cant_be_changed}" do
          expect(described_class.change_with_completed_user_checklists?(attrib_cant_be_changed)).to be_falsey
        end
      end
    end
  end


  describe '.change_with_uncompleted_user_checklists??' do

    it 'false if attribute is something that is displayed to users in user checklists' do
      expect(described_class.change_with_uncompleted_user_checklists?(:displayed_text)).to be_falsey
      expect(described_class.change_with_uncompleted_user_checklists?(:description)).to be_falsey
    end
    it 'true otherwise' do
      expect(described_class.change_with_uncompleted_user_checklists?('blorf')).to be_truthy
    end
  end


  describe '.attributes_displayed_to_users' do
    it 'displayed_text, description, list_position, ancestry' do
      expect(described_class.attributes_displayed_to_users).to match_array([:displayed_text, :description, :list_position, :ancestry])
    end
  end


  describe '.top_level_next_list_position' do

    it '1 if there are no top level checklists' do
      expect(described_class.top_level_next_list_position).to eq 1
    end

    it 'maximum list position + 1 of all top level checklists' do
      create(:master_checklist, displayed_text: 'list 0', list_position: 0)
      create(:master_checklist, displayed_text: 'list 99', list_position: 99)
      expect(described_class.top_level_next_list_position).to eq 100
    end

  end


  describe '.all_as_array_nested_by_name' do
    it "calls all_as_array with order: ['name']" do
      expect(described_class).to receive(:all_as_array).with(order: %w(name))
      described_class.all_as_array_nested_by_name
    end
  end


  describe 'descendants_not_in_use' do

    it 'all descendants where is_in_use = false' do
      mc_root = create(:master_checklist)
      child1_not_in_use = create(:master_checklist,
                                 name: 'not in use',
                                 parent: mc_root,
                                 is_in_use: false)
      mc_inuse1 = create(:master_checklist, name: 'in use 1', parent: mc_root, is_in_use: true)
      desc_inuse1_not_used = create(:master_checklist,
                                    name: 'desc of in use 1, not in use',
                                    parent: mc_inuse1,
                                    is_in_use: false)
      create(:master_checklist, name: 'in use 2', parent: mc_root, is_in_use: true)

      expect(mc_root.descendants_not_in_use).to match_array([child1_not_in_use, desc_inuse1_not_used])
    end
  end


  describe 'descendants_in_use' do

    it 'all descendants where is_in_use = true' do
      mc_root = create(:master_checklist)
      child1_is_in_use = create(:master_checklist,
                                 name: 'child1 in use',
                                 parent: mc_root,
                                 is_in_use: true)
      child2_is_in_use = create(:master_checklist,
                                name: 'child2 in use',
                                parent: mc_root,
                                is_in_use: true)

      mc_in_use1 = create(:master_checklist, name: 'mc_in_use1', parent: mc_root, is_in_use: true)
      create(:master_checklist,
              name: 'desc of in use 1, not in use',
              parent: mc_in_use1,
              is_in_use: false)
      create(:master_checklist, name: 'not in use', parent: mc_root, is_in_use: false)
      mc_in_use2 = create(:master_checklist, name: 'mc_in_use2', parent: mc_root, is_in_use: true)
      child1_in_use2 = create(:master_checklist, name: 'child1_in_use2',
                              parent: mc_in_use2, is_in_use: true)
      create(:master_checklist, name: 'child2_in_use2_not_in_use',
                                         parent: mc_in_use2,
                                         is_in_use: false)

      expect(mc_root.descendants_in_use).to match_array([child1_is_in_use,
                                                         child2_is_in_use,
                                                         mc_in_use1,
                                                         mc_in_use2,
                                                         child1_in_use2])
    end
  end


  describe 'completed_user_checklists' do
    it 'calls the User Checklist class to get all completed ones for this master checklist' do
      master_c = create(:master_checklist)
      expect(described_class.user_checklist_class).to receive(:completed_for_master_checklist).with(master_c)
      master_c.completed_user_checklists
    end
  end


  describe 'uncompleted_user_checklists' do
    it 'calls the User Checklist class to get all not completed ones for this master checklist' do
      master_c = create(:master_checklist)
      expect(described_class.user_checklist_class).to receive(:not_completed_for_master_checklist).with(master_c)
      master_c.uncompleted_user_checklists
    end
  end


  describe 'allowable_parents' do

    it 'only entries currently in use are returned' do
      mc1 = create(:master_checklist)
      mc_in_use = create(:master_checklist)
      mc_not_in_use = create(:master_checklist, :not_in_use)

      expect(mc1.allowable_parents([mc_in_use, mc_not_in_use])).to match_array([mc_in_use])
    end
  end


  describe 'toggle_is_in_use' do
    it 'sets_in_use to the opposite of whatever is_in_use currently is' do
      mc_in_use = create(:master_checklist)
      expect(mc_in_use).to receive(:set_is_in_use).with(false)
      mc_in_use.toggle_is_in_use

      mc_not_in_use = create(:master_checklist, is_in_use: false)
      expect(mc_not_in_use).to receive(:set_is_in_use).with(true)
      mc_not_in_use.toggle_is_in_use
    end
  end


  describe 'set_is_in_use ' do

    it 'first calls set_is_in_use for all children so any that can be deleted are deleted' do
      master_c = create(:master_checklist, name: 'master_c parent')
      child1 = create(:master_checklist, parent: master_c)
      create(:master_checklist, parent: child1)
      create(:master_checklist, parent: master_c)

      expect(master_c).to receive(:children).and_call_original
      master_c.set_is_in_use
    end

    context 'is now set to in use' do
      it 'calls change_to_being_in_use' do
        master_c = create(:master_checklist, name: 'master_c parent')
        expect(master_c).to receive(:change_to_being_in_use)

        master_c.set_is_in_use(true)
      end
    end

    context 'is now set to is not in use' do
      it 'calls can_delete?' do
        master_c = create(:master_checklist, name: 'master_c parent')
        expect(master_c).to receive(:can_delete?)

        master_c.set_is_in_use(false)
      end
    end

  end


  describe 'change_to_being_in_use' do

    it 'sets is_in_use to true and updates the time it was changed' do
      master_c = create(:master_checklist)
      expect(master_c).to receive(:change_is_in_use).with(true)

      master_c.change_to_being_in_use
    end

    it "inserts itself into the parent's list of children list_positions" do
      parent_mc = create(:master_checklist, name: 'parent')
      master_c = create(:master_checklist, parent: parent_mc, name: 'master c')

      expect_any_instance_of(described_class).to receive(:insert).with(master_c)
      master_c.change_to_being_in_use
    end

  end


  describe 'mark_as_no_longer_used' do

    it 'is_in_use is changed to false and the time it is changed is updated' do
      master_c = create(:master_checklist)
      expect(master_c).to receive(:change_is_in_use).with(false)

      master_c.mark_as_no_longer_used
    end

    context 'has a parent' do

      it "removes itself from the parent's list of children list positions" do
        parent_master_c = create(:master_checklist, name: 'parent')
        master_c = create(:master_checklist, parent: parent_master_c, name: 'child master_c') # specifying the parent creates the ancestry (nesting)
        parent_master_c.insert(master_c) # This sets up the list positions

        # TODO Why is this not working?  Why is this expectation not met? The method _is_ being called by this object (the parent).
        # expect(master_c.parent).to receive(:remove_child_from_list_positions).with(master_c)

        # This expectation works. So Mocks.. is not recognizing 'parent_master_c' (some problem with == comparison somewhere?)
        expect_any_instance_of(described_class).to receive(:remove_child_from_list_positions).with(master_c)

        master_c.mark_as_no_longer_used
      end
    end

  end


  describe 'remove_child_from_list_positions' do

    it 'decrements the list position for other children, starting at the list position for the child' do
      master_c = create(:master_checklist, name: 'master_c')
      child1 = create(:master_checklist, parent: master_c, name: 'child1')
      master_c.insert(child1)
      child2 = create(:master_checklist, parent: master_c, name: 'child1')
      master_c.insert(child2)
      child3 = create(:master_checklist, parent: master_c, name: 'child1')
      master_c.insert(child3)

      expect(master_c).to receive(:decrement_child_positions).with(child2.list_position)

      master_c.remove_child_from_list_positions(child2)
    end
  end


  describe 'destroy' do

    it 'calls can_be_destroyed? to check business rules/logic/data before it is actually destroyed' do
      master_c = create(:master_checklist)
      expect(master_c).to receive(:can_be_destroyed?)
      master_c.destroy
    end
  end


  describe 'instance methods delegated to the change policy' do

    describe 'can_be_destroyed?' do

      it 'calls the change policy with self' do
        master_c = create(:master_checklist)
        # allow(master_c).to receive(:can_delete?).and_return(false)
        expect(described_class.change_policy).to receive(:can_be_destroyed?).with(master_c)
        master_c.can_be_destroyed?
      end
    end


    describe 'can_delete?' do

      it 'calls the change policy with self' do
        master_c = create(:master_checklist)
        expect(described_class.change_policy).to receive(:can_delete?).with(master_c)
        master_c.can_delete?
      end

    end

    describe 'no_more_major_changes?' do

      it 'calls the change policy with self' do
        master_c = create(:master_checklist)
        expect(described_class.change_policy).to receive(:no_more_major_changes?).with(master_c)
        master_c.no_more_major_changes?
      end
    end


    describe 'can_be_changed?' do

      it 'calls the change policy with self and the list of attributes to check' do
        master_c = create(:master_checklist)
        expect(described_class.change_policy).to receive(:can_be_changed?).with(master_c, anything)
        master_c.can_be_changed?(['this', 'that', :another])
      end
    end

  end


  describe 'has_completed_user_checklists?' do

    it 'true if count of completed user checklists > 0' do
      mc_with_completed = create(:master_checklist)
      create(:user_checklist, :completed, master_checklist: mc_with_completed)
      expect(mc_with_completed.has_completed_user_checklists?).to be_truthy
    end

    it 'false if count =< 0' do
      mc_with_completed = create(:master_checklist)
      create(:user_checklist, master_checklist: mc_with_completed)
      expect(mc_with_completed.has_completed_user_checklists?).to be_falsey
    end
  end


  describe 'change_is_in_use' do

    it 'updates is_in_use and is_in_use_changed_at' do
      changed_time = Time.zone.now
      mc_in_use = create(:master_checklist)
      expect(mc_in_use).to receive(:update).with({ is_in_use: true, is_in_use_changed_at: changed_time })

      mc_in_use.change_is_in_use(true, changed_time)
    end

    it 'default values: is_in_use = false, changed_at = Time.zone.now' do
      mc_in_use = create(:master_checklist, is_in_use: true)
      changed_time = Time.zone.now
      Timecop.freeze(changed_time) do
        mc_in_use.change_is_in_use
      end
      expect(mc_in_use.is_in_use).to be_falsey
      expect(mc_in_use.is_in_use_changed_at).to eq changed_time
    end
  end


  describe 'display_name_with_depth' do

    it "default prefix string is '-'" do
      expect(two_children.children.first.display_name_with_depth.first).to eq '-'
    end

    it 'can specify the prefix' do
      expect(two_children.children.first.display_name_with_depth(prefix: '@').first).to eq '@'
    end

    it 'prefix is repeated (depth) times and then a space and then the name' do
      grandchild_one = build(:master_checklist, name: 'grandchild_one')
      child_one = two_children.children.first
      child_one.insert(grandchild_one)

      expect(grandchild_one.display_name_with_depth).to eq "-- grandchild_one"
    end
  end


  # ======================================================

  # describe 'Integration tests ' do
  #
  #
  #
  # describe 'set_is_in_use ' do
  # describe 'integration testing' do
  #   context 'has user checklists ' do
  #
  #     context 'none are completed ' do
  #       it 'is deleted ' do
  #         pending
  #       end
  #     end
  #
  #     context 'some are completed ' do
  #       it 'is marked as not in use ' do
  #         pending
  #       end
  #     end
  #   end
  #
  #   context 'has children ' do
  #     pending
  #   end
  #
  #   context 'no children ' do
  #     pending
  #   end
  # end
  # end
  #
  #
  #
  #   describe 'toggle_is_in_use ' do
  #
  #     it 'is_in_use changed to true if it was false ' do
  #       new_master = create(:master_checklist)
  #       expect(new_master.is_in_use).to be_truthy
  #       new_master.toggle_is_in_use
  #       expect(new_master.is_in_use).to be_falsey
  #     end
  #
  #     it 'is_in_use changed to false if it was true ' do
  #       new_master = create(:master_checklist, is_in_use: false)
  #       expect(new_master.is_in_use).to be_falsey
  #       new_master.toggle_is_in_use
  #       expect(new_master.is_in_use).to be_truthy
  #     end
  #
  #     it 'is_in_use_changed_at is changed to Time now ' do
  #       new_master = create(:master_checklist)
  #       expect(new_master.is_in_use_changed_at).to be_nil
  #       frozen_time = Time.zone.now
  #       Timecop.freeze(frozen_time) do
  #         new_master.toggle_is_in_use
  #       end
  #       expect(new_master.is_in_use_changed_at).to eq frozen_time
  #
  #       next_frozen_time = Time.zone.now
  #       Timecop.freeze(next_frozen_time) do
  #         new_master.toggle_is_in_use
  #       end
  #       expect(new_master.is_in_use_changed_at).to eq next_frozen_time
  #     end
  #
  #     it 'all children is_in_use are changed to this same state ' do
  #       new_master = create(:master_checklist)
  #       child1 = create(:master_checklist, parent: new_master)
  #       new_master.insert(child1) # updates the list position in the parent
  #       child2 = create(:master_checklist, parent: new_master)
  #       new_master.insert(child2) # updates the list position in the parent
  #       child2_1 = create(:master_checklist, parent: child2)
  #       child2.insert(child2_1) # updates the list position in the parent
  #
  #       expect(new_master.is_in_use).to be_truthy
  #       expect(child1.is_in_use).to be_truthy
  #       expect(child2.is_in_use).to be_truthy
  #       expect(child2_1.is_in_use).to be_truthy
  #
  #       new_master.toggle_is_in_use
  #
  #       expect(new_master.is_in_use).to be_falsey
  #       expect(child1.is_in_use).to be_falsey
  #       expect(child2.is_in_use).to be_falsey
  #       expect(child2_1.is_in_use).to be_falsey
  #     end
  #
  #
  #     context 'is in a list (has ancestors) ' do
  #       # TODO - too much duplication?
  #
  #       describe 'list positions are updated ' do
  #
  #         describe 'REMOVED from the parent list (no longer in use) ' do
  #
  #           context 'has no children ' do
  #
  #             context 'no assoc.user checklists ' do
  #
  #               it 'is deleted ' do
  #                 new_master = create(:master_checklist)
  #                 expect(new_master.is_in_use).to be_truthy
  #                 new_master.toggle_is_in_use
  #
  #                 expect { described_class.find(new_master.id) }.to raise_exception ActiveRecord::RecordNotFound
  #               end
  #             end
  #
  #             context 'has assoc.user checklists, but none are completed ' do
  #
  #               it 'is deleted; assoc.user checklists are also deleted ' do
  #                 master_list = create(:master_checklist)
  #                 uc_1_not_completed = create(:user_checklist, master_checklist: master_list)
  #                 uc_2_not_completed = create(:user_checklist, master_checklist: master_list)
  #
  #                 expect(UserChecklist.count).to eq 2
  #
  #                 master_list.toggle_is_in_use
  #
  #                 expect(AdminOnly::MasterChecklist.count).to eq 0
  #                 expect { master_list.reload }.to raise_exception ActiveRecord::RecordNotFound
  #                 expect(UserChecklist.count).to eq 0
  #                 expect { uc_1_not_completed.reload }.to raise_exception ActiveRecord::RecordNotFound
  #                 expect { uc_2_not_completed.reload }.to raise_exception ActiveRecord::RecordNotFound
  #               end
  #             end
  #
  #
  #             context 'has completed assoc.user checklists ' do
  #
  #               it 'not deleted; only user checklists that are not completed are deleted ' do
  #
  #                 new_master = create(:master_checklist)
  #                 list_1 = create(:master_checklist, parent: new_master)
  #
  #                 uc_2_not_completed = create(:user_checklist, master_checklist: new_master)
  #                 uc_3 = create(:user_checklist, :completed, master_checklist: new_master)
  #
  #                 expect(UserChecklist.count).to eq 2
  #
  #                 new_master.toggle_is_in_use
  #
  #                 expect(new_master.reload.is_in_use).to be_falsey # would fail if the obj. didn' t exist (was deleted)
  #                 expect(UserChecklist.count).to eq 1
  #                 expect { uc_2_not_completed.reload }.to raise_exception ActiveRecord::RecordNotFound
  #               end
  #
  #             end
  #           end
  #
  #           context 'has children' do
  #
  #             context 'no assoc. user checklists' do
  #               it 'is deleted. (children will be evaluated independently)' do
  #
  #                 new_master = create(:master_checklist)
  #                 child1 = create(:master_checklist, parent: new_master)
  #                 new_master.insert(child1) # updates the list position in the parent
  #                 child2 = create(:master_checklist, parent: new_master)
  #                 new_master.insert(child2) # updates the list position in the parent
  #                 child2_1 = create(:master_checklist, parent: child2)
  #                 child2.insert(child2_1) # updates the list position in the parent
  #
  #                 expect(new_master.is_in_use).to be_truthy
  #                 expect(child1.is_in_use).to be_truthy
  #                 expect(child2.is_in_use).to be_truthy
  #                 expect(child2_1.is_in_use).to be_truthy
  #
  #                 new_master.toggle_is_in_use
  #
  #                 # all should be deleted
  #                 expect { described_class.find(new_master.id) }.to raise_exception ActiveRecord::RecordNotFound
  #                 expect { described_class.find(child1.id) }.to raise_exception ActiveRecord::RecordNotFound
  #                 expect { described_class.find(child2.id) }.to raise_exception ActiveRecord::RecordNotFound
  #                 expect { described_class.find(child2_1.id) }.to raise_exception ActiveRecord::RecordNotFound
  #               end
  #             end
  #
  #             context 'has assoc. user checklists, but none are completed' do
  #
  #               it 'is deleted; incompleted user checklists are also deleted. (children will be evaluated independently)' do
  #
  #                 new_master = create(:master_checklist)
  #
  #                 child1 = create(:master_checklist, parent: new_master)
  #                 new_master.insert(child1) # updates the list position in the parent
  #                 child2 = create(:master_checklist, parent: new_master)
  #                 new_master.insert(child2) # updates the list position in the parent
  #                 child2_1 = create(:master_checklist, parent: child2)
  #                 child2.insert(child2_1) # updates the list position in the parent
  #
  #                 uc_1_not_completed = create(:user_checklist, master_checklist: new_master)
  #                 uc_2_not_completed = create(:user_checklist, master_checklist: new_master)
  #                 uc_3_not_completed = create(:user_checklist, master_checklist: new_master)
  #
  #                 child2_uc_1_completed = create(:user_checklist, :completed, master_checklist: child2)
  #
  #                 expect(UserChecklist.count).to eq 4
  #
  #                 new_master.toggle_is_in_use
  #
  #                 # These should be deleted:
  #                 # expect { described_class.find(child1.id) }.to raise_exception ActiveRecord::RecordNotFound
  #                 expect { described_class.find(child2_1.id) }.to raise_exception ActiveRecord::RecordNotFound
  #
  #                 expect(UserChecklist.count).to eq 1
  #                 expect { UserChecklist.find(uc_1_not_completed.id) }.to raise_exception ActiveRecord::RecordNotFound
  #                 expect { UserChecklist.find(uc_2_not_completed.id) }.to raise_exception ActiveRecord::RecordNotFound
  #                 expect { UserChecklist.find(uc_3_not_completed.id) }.to raise_exception ActiveRecord::RecordNotFound
  #
  #                 # These should not be deleted:
  #                 expect(new_master.is_in_use).to be_falsey
  #                 expect(child2.reload.is_in_use).to be_falsey
  #                 expect { child2_uc_1_completed.reload }.not_to raise_exception
  #               end
  #             end
  #
  #             context 'has some completed user checklists' do
  #
  #               it 'not deleted; uncompleted user checklists are deleted (children evaluated sep.)' do
  #                 new_master = create(:master_checklist)
  #                 child1 = create(:master_checklist, parent: new_master)
  #                 new_master.insert(child1) # updates the list position in the parent
  #                 child2 = create(:master_checklist, parent: new_master)
  #                 new_master.insert(child2) # updates the list position in the parent
  #                 child2_1 = create(:master_checklist, parent: child2)
  #                 child2.insert(child2_1) # updates the list position in the parent
  #
  #                 expect(new_master.is_in_use).to be_truthy
  #                 expect(child1.is_in_use).to be_truthy
  #                 expect(child2.is_in_use).to be_truthy
  #                 expect(child2_1.is_in_use).to be_truthy
  #
  #                 uc_1_not_completed = create(:user_checklist, master_checklist: new_master)
  #                 uc_2_not_completed = create(:user_checklist, master_checklist: new_master)
  #                 uc_3_completed = create(:user_checklist, :completed, master_checklist: new_master)
  #
  #                 child2_uc_1_not_completed = create(:user_checklist, master_checklist: child2)
  #
  #                 new_master.toggle_is_in_use
  #
  #                 expect(new_master.is_in_use).to be_falsey
  #                 expect(described_class.count).to eq 1
  #
  #                 # These should be deleted:
  #                 expect { described_class.find(child1.id) }.to raise_exception ActiveRecord::RecordNotFound
  #                 expect { described_class.find(child2.id) }.to raise_exception ActiveRecord::RecordNotFound
  #                 expect { described_class.find(child2_1.id) }.to raise_exception ActiveRecord::RecordNotFound
  #
  #                 expect(UserChecklist.count).to eq 1
  #                 expect(UserChecklist.first).to eq uc_3_completed
  #               end
  #
  #             end
  #
  #             context 'children have NO COMPLETED assoc. user checklists' do
  #
  #               it 'is deleted, children deleted, all uncompleted user checklists are deleted' do
  #
  #                 new_master = create(:master_checklist)
  #                 child1 = create(:master_checklist, parent: new_master)
  #                 new_master.insert(child1) # updates the list position in the parent
  #                 child2 = create(:master_checklist, parent: new_master)
  #                 new_master.insert(child2) # updates the list position in the parent
  #                 child2_1 = create(:master_checklist, parent: child2)
  #                 child2.insert(child2_1) # updates the list position in the parent
  #
  #                 expect(new_master.is_in_use).to be_truthy
  #                 expect(child1.is_in_use).to be_truthy
  #                 expect(child2.is_in_use).to be_truthy
  #                 expect(child2_1.is_in_use).to be_truthy
  #
  #                 child1_uc_1_not_completed = create(:user_checklist, master_checklist: child1)
  #                 child2_uc_1_not_completed = create(:user_checklist, master_checklist: child2)
  #
  #                 new_master.toggle_is_in_use
  #
  #                 # all should be deleted
  #                 expect(described_class.count).to eq 0
  #                 expect { described_class.find(new_master.id) }.to raise_exception ActiveRecord::RecordNotFound
  #                 expect { described_class.find(child1.id) }.to raise_exception ActiveRecord::RecordNotFound
  #                 expect { described_class.find(child2.id) }.to raise_exception ActiveRecord::RecordNotFound
  #                 expect { described_class.find(child2_1.id) }.to raise_exception ActiveRecord::RecordNotFound
  #
  #                 expect(UserChecklist.count).to eq 0
  #               end
  #             end
  #
  #             context 'some children DO have completed assoc. user checklists' do
  #
  #               it 'is not deleted (since there are children that are completed)' do
  #
  #                 # this does not have a User checklist assoc.
  #                 new_master = create(:master_checklist)
  #
  #                 child1 = create(:master_checklist, parent: new_master)
  #                 new_master.insert(child1) # updates the list position in the parent
  #                 child2 = create(:master_checklist, parent: new_master)
  #                 new_master.insert(child2) # updates the list position in the parent
  #                 child2_1 = create(:master_checklist, parent: child2)
  #                 child2.insert(child2_1) # updates the list position in the parent
  #
  #                 # this does not have a User checklist assoc.
  #                 child3 = create(:master_checklist, parent: new_master)
  #                 new_master.insert(child3) # updates the list position in the parent
  #
  #                 uc_child1 = create(:user_checklist, master_checklist: child1)
  #                 uc_child2 = create(:user_checklist, master_checklist: child2)
  #                 uc_child2_1 = create(:user_checklist, :completed, master_checklist: child2_1)
  #
  #                 new_master.toggle_is_in_use
  #
  #                 # These were deleted
  #                 expect { described_class.find(child1.id) }.to raise_exception ActiveRecord::RecordNotFound
  #                 # The assoc. user checklist was deleted
  #                 expect { UserChecklist.find(uc_child1.id) }.to raise_exception ActiveRecord::RecordNotFound
  #
  #                 expect { described_class.find(child3.id) }.to raise_exception ActiveRecord::RecordNotFound
  #
  #                 # uncompleted user checklists were deleted:
  #                 expect { UserChecklist.find(uc_child2.id) }.to raise_exception ActiveRecord::RecordNotFound
  #
  #                 # These were not deleted and now have :is_in_use set to false
  #                 expect(new_master.reload.is_in_use).to be_falsey
  #                 expect(child2.reload.is_in_use).to be_falsey
  #                 expect(child2_1.reload.is_in_use).to be_falsey
  #
  #                 # These user checklists are still here
  #                 # expect(uc_top.reload.master_checklist).to eq new_master
  #                 expect(uc_child2_1.reload.master_checklist).to eq child2_1
  #               end
  #             end
  #
  #           end
  #
  #         end
  #
  #
  #         describe 'ADDED to the parent list (is now in use)' do
  #           pending
  #         end
  #
  #       end
  #     end
  #   end
  #
  # end

end
