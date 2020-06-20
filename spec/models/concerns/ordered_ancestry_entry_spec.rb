require 'rails_helper'

# OrderedAncestryEntry is a module and so cannot be instantiated.
# AdminOnly::MasterChecklist includes it and so is used to test the class.
#
# Need to manually make sure data is cleared for tests since this does not
# use the typical Rails RSpec.describe <class> pattern.
#
RSpec.describe "module OrderedAncestryEntry" do

  let(:class_that_includes) { AdminOnly::MasterChecklist }

  let(:child_one) { create(:master_checklist, name: 'child 1') }
  let(:child_two) { create(:master_checklist, name: 'child 2') }
  let(:child_three) { create(:master_checklist, name: 'child 3') }

  let(:two_children) do
    list = create(:master_checklist, name: 'two children')
    list.insert(child_one)
    list.insert(child_two)
    list
  end

  let(:three_children) do
    list = create(:master_checklist, name: 'three children')
    list.insert(child_one)
    list.insert(child_two)
    list.insert(child_three)
    list
  end

  describe 'all_as_array' do
    it "calls arrange_as_array with the order [ancestry, list_position]" do
      expect(class_that_includes).to receive(:arrange_as_array).with(order: %w(ancestry list_position))
      class_that_includes.all_as_array
    end

    it 'concats any additional order attributes to the defaults' do
      expect(class_that_includes).to receive(:arrange_as_array).with(order: %w(ancestry list_position one two three))
      class_that_includes.all_as_array(order: ['one', 'two', 'three'])
    end
  end


  describe 'arrange_as_array(options = {}, nodes_to_arrange_hash = nil)' do
    def fail_message(expected_array, actual_array)
      "\nExpected:\n   #{expected_array.pretty_inspect}\nActual:\n   #{actual_array.pretty_inspect}"
    end

    it 'if no nodes_to_arrange_hash is given, calls arrange to create the hash of nodes' do
      expect(class_that_includes).to receive(:arrange).and_call_original
      class_that_includes.arrange_as_array
    end

    it 'uses the hash of nodes given' do
      entry1 = create(:master_checklist, name: 'entry1')
      two_children = create(:master_checklist, name: '1 child')
      two_children.insert(entry1)

      given_hash = { two_children => { entry1 => nil } }

      expected = [two_children, entry1]
      actual = class_that_includes.arrange_as_array({}, given_hash)
      expect(actual).to match_array(expected), fail_message(expected, actual)
    end

    it 'returns an Array just with the entry if entry has no chidren' do
      no_children = create(:master_checklist)
      actual = class_that_includes.arrange_as_array
      expect(actual).to match_array([no_children]), fail_message([no_children], actual)
    end

    it 'calls arrange_as_array for all children of each node' do
      create(:master_checklist, num_children: 2)
      expect(class_that_includes).to receive(:arrange_as_array).exactly(4).times.and_call_original
      class_that_includes.arrange_as_array
    end

    it 'adds the entry and its children (arranged as an array) to the array returned' do
      one_child_list = create(:master_checklist, name: 'two_children_list')

      first_child = create(:master_checklist, name: 'first_child')
      one_child_list.insert(first_child)

      first_child_child = create(:master_checklist, name: 'first_child_child')
      first_child.insert(first_child_child)

      expected = [one_child_list,
                  first_child,
                  first_child_child]
      actual = class_that_includes.arrange_as_array
      expect(actual).to eq(expected), fail_message(expected, actual)
    end
  end


  describe 'list position is updated' do

    context 'is a top level list' do

      it 'other top level list positions are updated' do
        top_list_0 = create(:master_checklist, displayed_text: 'list 0', list_position: 0)
        top_list_2 = create(:master_checklist, displayed_text: 'list 2', list_position: 2)
        top_list_1 = create(:master_checklist, displayed_text: 'list 1', list_position: 1)

        expect(top_list_1).to receive(:entries_to_decrement).and_call_original
        expect(top_list_1).to receive(:entries_to_increment).and_call_original

        top_list_1.update(list_position: 2)

        expect(top_list_0.reload.list_position).to eq 0
        expect(top_list_1.reload.list_position).to eq 2
        expect(top_list_2.reload.list_position).to eq 1
      end
    end
  end

  describe 'insert' do
    it 'appends to the end if no position given' do
      newlist = create(:master_checklist, num_children: 2)
      expect(newlist).to receive(:increment_child_positions).and_call_original

      new_entry = create(:master_checklist)
      newlist.insert(new_entry)

      expect(newlist.children.size).to eq 3
      expect(new_entry.list_position).to eq 2
    end

    it 'calls increment_child_positions for entries that come after this list position' do
      newlist = create(:master_checklist, num_children: 2)
      expect(newlist).to receive(:increment_child_positions).with(1).and_call_original

      newlist.insert(create(:master_checklist), 1)
    end

    it 'updates the list_position and the parent for the entry' do
      newlist = create(:master_checklist, num_children: 2)
      expect(newlist).to receive(:increment_child_positions).and_call_original

      new_entry = create(:master_checklist)
      newlist.insert(new_entry, 1)

      expect(new_entry.list_position).to eq 1
      expect(new_entry.parent).to eq newlist
    end

    it 'new entry is inserted' do
      newlist = create(:master_checklist, num_children: 2)
      expect(newlist).to receive(:increment_child_positions).with(1).and_call_original

      new_entry = create(:master_checklist)
      newlist.insert(new_entry, 1)

      expect(newlist.child_at_position(1)).to eq new_entry
      expect(newlist.children.map(&:list_position)).to match_array([0, 1, 2])
    end
  end

  describe 'delete_from_children' do
    it 'does nothing if the entry is not in the list' do
      newlist = create(:master_checklist, num_children: 2)
      not_in_list = create(:master_checklist, name: 'not in the list')

      newlist.delete_from_children(not_in_list)
      expect(newlist.children.size).to eq 2
    end

    it 'deletes the entry from list' do
      newlist = create(:master_checklist, num_children: 1)
      newlist.delete_from_children(newlist.children.first)
      expect(newlist.children).to be_empty
    end

    it 'calls decrement_child_positions starting with the position where the entry was' do
      newlist = create(:master_checklist, num_children: 3)
      expect(newlist).to receive(:decrement_child_positions).with(2)
                             .and_call_original

      last_entry = newlist.children.last
      newlist.delete_from_children(last_entry)

      expect(newlist.children.size).to eq 2
      expect(newlist.children.map(&:list_position)).to match_array([0, 1])
    end
  end

  describe 'delete_child_at (deletes child at the zero-based position)' do
    it 'does nothing if no children' do
      no_children = create(:master_checklist)

      expect(no_children).not_to receive(:delete)
      no_children.delete_child_at(0)
    end

    it 'does nothing if the position >= the number of children' do
      newlist = create(:master_checklist, num_children: 2)
      expect(newlist.delete_child_at(2).size).to eq 2
    end

    it 'removes the entry at that position' do
      newlist = create(:master_checklist, num_children: 3)

      expect(newlist).to receive(:decrement_child_positions).with(2).and_call_original

      newlist.delete_child_at(2)

      expect(newlist.children.size).to eq 2
      expect(newlist.children.map(&:list_position)).to match_array([0, 1])
    end

    it 'calls decrement_child_positions after entry deleted if entry was in the list_entry' do
      newlist = create(:master_checklist, num_children: 3)

      expect(newlist).to receive(:decrement_child_positions).with(2).and_call_original

      newlist.delete_child_at(2)

      expect(newlist.children.size).to eq 2
      expect(newlist.children.map(&:list_position)).to match_array([0, 1])
    end
  end

  describe 'increment_child_positions' do
    it 'empty list' do
      empty_list = create(:master_checklist)
      expect(empty_list.children.map(&:list_position)).to match_array([])

      empty_list.send(:increment_child_positions, 0)
      expect(empty_list.children.map(&:list_position)).to match_array([])
    end

    context 'not an empty list' do
      it 'at the start' do
        list_5_kids = create(:master_checklist, num_children: 5)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 2, 3, 4])

        list_5_kids.send(:increment_child_positions, 0)
        expect(list_5_kids.children.map(&:list_position)).to match_array([1, 2, 3, 4, 5])
      end

      it 'in the middle' do
        list_5_kids = create(:master_checklist, num_children: 5)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 2, 3, 4])

        list_5_kids.send(:increment_child_positions, 2)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 3, 4, 5])
      end

      it 'at the end' do
        list_5_kids = create(:master_checklist, num_children: 5)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 2, 3, 4])

        list_5_kids.send(:increment_child_positions, 5)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 2, 3, 4])
      end
    end
  end

  describe 'decrement_child_positions' do
    it 'empty list' do
      empty_list = create(:master_checklist)
      expect(empty_list.children.map(&:list_position)).to match_array([])

      empty_list.send(:decrement_child_positions, 0)
      expect(empty_list.children.map(&:list_position)).to match_array([])
    end

    context 'not an empty list' do

      it 'at the start - will not decrement 0' do
        list_5_kids = create(:master_checklist, num_children: 5)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 2, 3, 4])

        list_5_kids.send(:decrement_child_positions, 0)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 0, 1, 2, 3])
      end

      it 'in the middle' do
        list_5_kids = create(:master_checklist, num_children: 5)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 2, 3, 4])

        list_5_kids.send(:decrement_child_positions, 2)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 1, 2, 3])
      end

      it 'at the end' do
        list_5_kids = create(:master_checklist, num_children: 5)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 2, 3, 4])

        list_5_kids.send(:decrement_child_positions, 5)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 2, 3, 4])
      end
    end

    it 'default decrement starting position is the last position' do
      newlist = create(:master_checklist, num_children: 3)

      expect(newlist).to receive(:decrement_child_positions).with(no_args)
                             .and_call_original

      original_positions = newlist.children.map(&:list_position)
      newlist.send(:decrement_child_positions)
      expect(newlist.children.map(&:list_position)).to match_array(original_positions)
    end
  end

  describe 'last_used_list_position' do
    it '-1 if the list is empty' do
      expect(create(:master_checklist).last_used_list_position).to eq class_that_includes::NO_CHILDREN_LAST_USED_POSITION
    end

    it 'maximum value of children.list_position if there are any children' do
      root_mc = create(:master_checklist, num_children: 2)
      expect(root_mc.last_used_list_position).to eq 1

      create(:master_checklist, parent: root_mc, name: 'list pos is not contiguous', list_position: 99)
      expect(root_mc.last_used_list_position).to eq 99
    end

    context 'not saved' do
      it 'is NO_CHILDREN_LAST_USED_POSITION (-1)' do
        expect(build(:master_checklist).last_used_list_position).to eq class_that_includes::NO_CHILDREN_LAST_USED_POSITION
      end

    end
  end

  describe 'next_list_position' do
    it 'is (maximum list_position of all children) + 1 [list positions may not be contiguous]' do
      root_mc = create(:master_checklist, num_children: 2)
      expect(root_mc.next_list_position).to eq 2

      create(:master_checklist, parent: root_mc, name: 'list pos is not contiguous', list_position: 99)
      expect(root_mc.next_list_position).to eq 100
    end

    it 'is zero if there are no children' do
      expect(create(:master_checklist).next_list_position).to eq 0
    end
  end

  it 'list_entry can hold other list_entries (be nested)' do
    toplist = create(:master_checklist, name: 'toplist', num_children: 3)
    level2_1_list = create(:master_checklist, name: 'level2_1_list', num_children: 2)
    level2_2_list = create(:master_checklist, name: 'level2_2_list', num_children: 1)
    level3_1_list = create(:master_checklist, name: 'level3_1_list', num_children: 1)

    level2_1_list.insert(level3_1_list)
    toplist.insert(level2_1_list)
    toplist.insert(level2_2_list, 1)

    expect(level2_1_list.children.size).to eq 3
    expect(level2_2_list.list_position).to eq 1
    expect(level2_1_list.children.map(&:name)).to match_array(['child entry 0', 'child entry 1', 'level3_1_list'])

    expect(toplist.children.size).to eq 5
    expect(toplist.children.map(&:name)).to match_array(['child entry 0', 'child entry 1', 'child entry 2', 'level2_1_list', 'level2_2_list'])
  end

  describe 'child_at_position' do
    it 'no children returns nil' do
      no_children = create(:master_checklist)
      expect(no_children.child_at_position(0)).to be_nil
    end

    describe 'has children' do

      it 'no child at that position' do
        #two_children = create(:master_checklist, num_children: 2)
        expect(two_children.child_at_position(5)).to be_nil
      end

      it 'returns the child at that position' do
        three_kids = create(:master_checklist, num_children: 3)
        kid_two = create(:master_checklist, name: 'kid 2')
        three_kids.insert(kid_two, 1)

        expect(three_kids.child_at_position(1)).to eq kid_two
      end
    end
  end


  describe 'allowable_as_parents' do
    it 'an emtpy list will just return that same empty list as allowed parents' do
      expect(create(:master_checklist).allowable_as_parents).to be_empty
    end

    it 'self cannot be a parent' do
      new_entry = create(:master_checklist)
      expect(new_entry.allowable_as_parents([new_entry])).to be_empty
    end

    it 'children cannot be a parent' do
      toplist = create(:master_checklist, name: 'toplist', num_children: 3)
      not_a_child = create(:master_checklist, name: 'not a child')

      expect(toplist.allowable_as_parents([toplist, not_a_child])).to match_array([not_a_child])
    end

    it 'if the entry has not been saved, is the list of potential parents given' do
      not_saved = build(:master_checklist)
      toplist = create(:master_checklist, name: 'toplist', num_children: 3)

      expect(not_saved.allowable_as_parents([])).to be_empty
      expect(not_saved.allowable_as_parents([toplist])).to eq [toplist]
    end

    describe 'is sorted' do
      it 'default is to sort by list position' do
        pos0_n1 = create(:master_checklist, name: '1', list_position: 0)
        create(:master_checklist, name: '1.1', list_position: 0, parent: pos0_n1)
        create(:master_checklist, name: '1.2', list_position: 1, parent: pos0_n1)

        create(:master_checklist, name: '0', list_position: 1)

        pos2_n3 = create(:master_checklist, name: '3', list_position: 2)
        create(:master_checklist, name: '3.1', list_position: 0, parent: pos2_n3)
        create(:master_checklist, name: '3.2', list_position: 1, parent: pos2_n3)

        create(:master_checklist, name: '2', list_position: 3)

        some_mc = create(:master_checklist)
        expect(some_mc.allowable_as_parents(class_that_includes.all).map(&:name)).to eq(['1', '1.1', '1.2', '0', '3', '3.1', '3.2', '2'])
      end

      it 'can provide a block to use for sorting' do
        pos0_n1 = create(:master_checklist, name: '1', list_position: 0)
        create(:master_checklist, name: '1.1', list_position: 0, parent: pos0_n1)
        create(:master_checklist, name: '1.2', list_position: 1, parent: pos0_n1)

        create(:master_checklist, name: '0', list_position: 1)

        pos2_n3 = create(:master_checklist, name: '3', list_position: 2)
        create(:master_checklist, name: '3.1', list_position: 0, parent: pos2_n3)
        create(:master_checklist, name: '3.2', list_position: 1, parent: pos2_n3)

        create(:master_checklist, name: '2', list_position: 3)

        some_mc = create(:master_checklist)
        expect(some_mc.allowable_as_parents(class_that_includes.all) { |p| p.name }.map(&:name)).to eq(['0', '1', '1.1', '1.2', '2', '3', '3.1', '3.2'])
      end
    end
  end
end
