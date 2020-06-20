require 'rails_helper'


RSpec.describe AdminOnly::MasterChecklistChangePolicy do
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

  describe '.change_with_completed_user_checklists?' do
    attribs_can_be_changed = ['is_in_use', 'is_in_use_changed_at', 'notes', 'updated_at']

    describe 'these attributes can be changed' do
      attribs_can_be_changed.sort.each do |attrib_can_change|
        it "#{attrib_can_change}" do
          expect(described_class.change_with_completed_user_checklists?(attrib_can_change)).to be_truthy
        end
      end
    end

    describe 'all other attributes cannot be changed' do
      attribs_cannot_be_changed = ['id', 'name', 'blorf']
      attribs_cannot_be_changed.sort.each do |attrib_cant_be_changed|
        it "#{attrib_cant_be_changed}" do
          expect(described_class.change_with_completed_user_checklists?(attrib_cant_be_changed)).to be_falsey
        end
      end
    end
  end

  describe '.change_with_uncompleted_user_checklists?' do
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

  describe 'can_be_destroyed?' do
    it 'throws :abort if it cannot be destroyed' do
      master_c = create(:master_checklist)
      allow(described_class).to receive(:can_delete?).and_return(false)

      expect { described_class.can_be_destroyed?(master_c) }.to throw_symbol(:abort)
    end

    it 'true if it can be destroyed' do
      master_c = create(:master_checklist)
      allow(described_class).to receive(:can_delete?).and_return(true)

      expect(described_class.can_be_destroyed?(master_c)).to be_truthy
    end
  end

  describe 'can_delete?' do
    context 'children' do
      it 'true if there are no children' do
        mc_no_children = create(:master_checklist, :not_in_use)
        expect(described_class.can_delete?(mc_no_children)).to be_truthy
      end

      it 'true if all children can be deleted and it can be deleted' do
        mc_with_children = create(:master_checklist, :not_in_use)
        create(:master_checklist, :not_in_use, parent: mc_with_children, name: '1 Not in use')
        create(:master_checklist, :not_in_use, parent: mc_with_children, name: '2 Not in use')
        expect(described_class.can_delete?(mc_with_children)).to be_truthy
      end

      it 'false if any child cannot be deleted' do
        mc_with_children = create(:master_checklist, :not_in_use)
        create(:master_checklist, parent: mc_with_children, name: 'In use')  # is in use by default
        create(:master_checklist, :not_in_use, parent: mc_with_children, name: 'Not in use')
        expect(described_class.can_delete?(mc_with_children)).to be_falsey
      end
    end

    it 'false if has completed user checklists' do
      mc_with_completed_uchecklists = create(:master_checklist)
      create(:user_checklist, :completed, master_checklist: mc_with_completed_uchecklists)
      expect(described_class.can_delete?(mc_with_completed_uchecklists)).to be_falsey
    end

    it 'false if has an uncompleted user checklist' do
      expect(described_class.can_delete?(create(:master_checklist, :not_in_use))).to be_truthy

      mc_with_uncompleted_uchecklists = create(:master_checklist)
      create(:user_checklist, master_checklist: mc_with_uncompleted_uchecklists)
      expect(described_class.can_delete?(mc_with_uncompleted_uchecklists)).to be_falsey
    end

    it 'false if is_in_use is true' do
      expect(described_class.can_delete?(create(:master_checklist, :not_in_use))).to be_truthy
      expect(described_class.can_delete?(create(:master_checklist))).to be_falsey  # is_in_use = true by default
    end
    it 'else true (no user checklist, no children)' do
      expect(described_class.can_delete?(create(:master_checklist, :not_in_use))).to be_truthy
    end
  end

  describe 'no_more_major_changes?' do
    pending
  end

  describe 'can_be_changed?' do
    it 'always true if there are no associated user checklists' do
      new_master = create(:master_checklist)
      expect(described_class.can_be_changed?(new_master)).to be_truthy
      expect(described_class.can_be_changed?(new_master, ['flurb'])).to be_truthy
    end

    context 'there are associated user checklists' do
      context 'there are completed user checklists' do
        it 'true if attribute changed is :is_in_use or :is_in_use_changed_at' do
          new_master = create(:master_checklist)
          create(:user_checklist, :completed, master_checklist: new_master)

          expect(described_class.can_be_changed?(new_master, [:is_in_use])).to be_truthy
          expect(described_class.can_be_changed?(new_master, [:is_in_use_changed_at])).to be_truthy
        end

        it 'raises exception if the attributes are anything else' do
          new_master = create(:master_checklist)
          create(:user_checklist, :completed, master_checklist: new_master)

          expect { described_class.can_be_changed?(new_master, ['flurb']) }.to raise_exception AdminOnly::HasCompletedUserChecklistsCannotChange
          expect { described_class.can_be_changed?(new_master, [:name]) }.to raise_exception AdminOnly::HasCompletedUserChecklistsCannotChange
        end

        it 'true if no attributes are changed (which should not really happen, but ok if it does)' do
          new_master = create(:master_checklist)
          create(:user_checklist, :completed, master_checklist: new_master)

          expect(described_class.can_be_changed?(new_master)).to be_truthy
        end
      end

      context 'there are only uncompleted user checklists' do
        let(:new_master) do
          master_c = create(:master_checklist)
          create(:user_checklist, master_checklist: master_c)
          create(:user_checklist, master_checklist: master_c)
          master_c
        end

        it 'notes' do
          expect(new_master.can_be_changed?(['notes'])).to be_truthy
          new_master.notes = 'notes is now changed'
          expect(described_class.can_be_changed?(new_master)).to be_truthy
        end

        describe 'raises exception for all attributes users see' do
          [:displayed_text, :description].each do |attrib_user_sees|

            it "#{attrib_user_sees}" do
              expect { described_class.can_be_changed?(new_master, [attrib_user_sees]) }.to raise_exception AdminOnly::CannotChangeUserVisibleInfo
            end
          end
        end
      end
    end
  end
end
