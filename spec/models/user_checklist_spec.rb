require 'rails_helper'


RSpec.describe UserChecklist, type: :model do
  let(:all_complete_list) { create(:user_checklist, :completed, num_completed_children: 3) }

  let(:three_complete_two_uncomplete_list) {
    checklist_3done_2unfinished = create(:user_checklist, :completed, num_completed_children: 2)
    list_user = checklist_3done_2unfinished.user

    last_item = checklist_3done_2unfinished.children.last
    not_complete1 = create(:user_checklist, user: list_user, list_position: 200, parent: not_complete1)
    last_item.insert(not_complete1)

    not_complete1_child1 = create(:user_checklist, user: list_user, list_position: 201, parent: not_complete1)
    not_complete1.insert(not_complete1_child1)
    checklist_3done_2unfinished
  }

  describe 'Factory' do
    it 'default factory is valid' do
      expect(build(:user_checklist)).to be_valid
    end

    it 'traits are valid' do
      expect(create(:user_checklist, :completed)).to be_valid
    end

    it 'arguments passed in are valid' do
      expect(build(:user_checklist, name: 'some name')).to be_valid

      parent_item = create(:user_checklist)
      expect(build(:user_checklist, parent: parent_item)).to be_valid

      expect(create(:user_checklist, num_children: 3)).to be_valid
      expect(create(:user_checklist, num_completed_children: 2)).to be_valid

      expect(create(:user_checklist, parent: parent_item, num_children: 2, num_completed_children: 3)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:master_checklist) }
  end

  describe 'Scopes (including those as class methods)' do
    describe '.completed' do
      it 'empty if no UserChecklist is completed' do
        create(:user_checklist)
        expect(described_class.completed).to be_empty
      end

      it 'all where date_completed is NOT NULL (not nil)' do
        3.times { create(:user_checklist, :completed) }
        create(:user_checklist)
        expect(described_class.completed.count).to eq 3
      end
    end

    describe '.uncompleted' do
      it 'empty if all UserChecklists are completed' do
        create(:user_checklist, :completed)
        expect(described_class.uncompleted).to be_empty
      end

      it 'all where date_completed is NULL (nil)' do
        3.times { create(:user_checklist) }
        create(:user_checklist, :completed)
        expect(described_class.uncompleted.count).to eq 3
      end
    end

    it '.completed_by_user' do
      checklist_1 = create(:user_checklist, :completed)
      user_1 = checklist_1.user
      2.times { create(:user_checklist, :completed, user: user_1) }

      create(:user_checklist, :completed)

      expect(described_class.completed_by_user(user_1).count).to eq 3
    end

    it '.not_completed_by_user' do
      checklist_1 = create(:user_checklist)
      user_1 = checklist_1.user
      2.times { create(:user_checklist, user: user_1) }

      create(:user_checklist, :completed, user: user_1)

      2.times { create(:user_checklist, :completed) }

      expect(described_class.not_completed_by_user(user_1).count).to eq 3
    end

    describe '.membership_guidelines_for_user' do
      let(:membership_guidelines_type_name) { AdminOnly::MasterChecklistType::MEMBER_GUIDELINES_LIST_TYPE }

      let(:user1) { create(:user, first_name: 'User1') }

      # TODO get this from AppConfiguration later / stub (the membership guidelines list type, etc.)
      let(:guideline_list_type) { create(:master_checklist_type, name: membership_guidelines_type_name) }
      let(:guideline_master) { create(:master_checklist, master_checklist_type: guideline_list_type) }

      before(:each) do
        # create a Master for Membership Guidelines
        # TODO get this from AppConfiguration later / stub (the membership guidelines list type, etc.)

        create(:user_checklist, :completed, user: user1,
               master_checklist: guideline_master,
               num_completed_children: 3)
      end

      it 'returns only top level lists' do
        expect(described_class.membership_guidelines_for_user(user1).count).to eq 1
      end

      it 'returns only Membership Guideline (type) lists' do
        another_list_type = create(:master_checklist_type, name: 'another')
        another_master = create(:master_checklist, master_checklist_type: another_list_type)

        create(:user_checklist, :completed, user: user1,
               master_checklist: another_master,
               num_completed_children: 2)

        expect(described_class.membership_guidelines_for_user(user1).count).to eq 1
      end

      it 'returns the lists only for the given user' do
        user2 = create(:user, first_name: 'User2')
        create(:user_checklist, :completed, user: user2,
               master_checklist: guideline_master,
               num_completed_children: 2)

        expect(described_class.membership_guidelines_for_user(user1).count).to eq 1
      end

      it 'is ordered so the most recently created one is last' do
        second_list = create(:user_checklist, :completed, user: user1,
               master_checklist: guideline_master,
               num_completed_children: 2)
        second_list.update(created_at: Time.zone.now + 1.day)

        expect(described_class.membership_guidelines_for_user(user1).count).to eq 2
        expect(described_class.membership_guidelines_for_user(user1).last).to eq second_list
      end
    end
  end

  describe 'all_completed?' do
    it 'false if self is not completed' do
      expect(build(:user_checklist).all_completed?).to be_falsey
    end

    it 'true if self and all children are complete' do
      all_complete_list = create(:user_checklist, :completed, num_completed_children: 3)
      expect(all_complete_list.all_completed?).to be_truthy
    end

    it 'false if 1 or more children are not complete' do
      expect(three_complete_two_uncomplete_list.all_completed?).to be_falsey
    end
  end

  describe 'all_that_are_completed' do
    it 'empty list if no items are complete' do
      expect(create(:user_checklist).all_that_are_completed).to be_empty
    end

    it 'returns a list of all items that are completed, including descendents, in order by list_position' do
      result = three_complete_two_uncomplete_list.all_that_are_completed

      expect(result).to include(three_complete_two_uncomplete_list) # includes the root of the tree
      expect(result).to include(three_complete_two_uncomplete_list.children.first)
      expect(result).to include(three_complete_two_uncomplete_list.children.last)
      expect(result).not_to include(three_complete_two_uncomplete_list.children.last.children.first)
      expect(result).not_to include(three_complete_two_uncomplete_list.children.last.children.last)

      result_list_positions = result.map(&:list_position)
      expect(result_list_positions).to match_array([0, 0, 1])
    end
  end

  describe 'all_that_are_uncompleted' do
    it 'empty list if all items are completed' do
      all_complete = create(:user_checklist, :completed, num_completed_children: 1)
      expect(all_complete.all_that_are_uncompleted).to be_empty
    end

    it 'returns a list of all items NOT completed, including descendents, in order by list_position' do
      undone_root = create(:user_checklist)
      list_user = undone_root.user
      done_item = create(:user_checklist, :completed, user: list_user, list_position: 9, parent: undone_root)
      done_sub1_not_complete = create(:user_checklist, user: list_user, list_position: 5, parent: done_item)

      result = undone_root.all_that_are_uncompleted

      expect(result).to include(undone_root)
      expect(result).to include(done_sub1_not_complete)
      expect(result).not_to include(done_item)

      result_list_positions = result.map(&:list_position)
      expect(result_list_positions).to match_array([0, 5])
    end
  end

  it 'size = completed items + uncompleted items' do
    expect(three_complete_two_uncomplete_list.all_that_are_completed.size + three_complete_two_uncomplete_list.all_that_are_uncompleted.size).to eq(5)
  end

  describe 'percent_complete' do
    context 'no children' do
      it '100 if is completed' do
        expect(create(:user_checklist, :completed).percent_complete).to eq 100
      end

      it '0 if not completed' do
        expect(create(:user_checklist).percent_complete).to eq 0
      end
    end

    context 'has children' do
      it '0 if none are completed' do
        expect(create(:user_checklist, num_children: 3).percent_complete).to eq 0
      end

      it '100 if all are completed' do
        top = create(:user_checklist, num_completed_children: 3)
        top.date_completed = Time.now
        expect(top.percent_complete).to eq 100
      end

      describe 'sum(leafs  percent complete) / (number of children) (DO NOT COUNT SELF)' do
        # 'leaf' is an item with no children.  It is the furthest/deepest most item in the tree of items.
        it 'simple levels' do
          top1 = create(:user_checklist)
          create(:user_checklist, :completed, parent: top1)
          create(:user_checklist, :completed, parent: top1)
          expect(top1.percent_complete).to eq 100

          top2 = create(:user_checklist)
          create(:user_checklist, :completed, parent: top2)
          expect(top2.percent_complete).to eq 100

          top3 = create(:user_checklist)
          create(:user_checklist, parent: top3)
          create(:user_checklist, parent: top3)
          create(:user_checklist, :completed, parent: top3)
          expect(top3.percent_complete).to eq 33


          top4 = create(:user_checklist)
          c4_1 = create(:user_checklist, :completed, parent: top4)
          c4_1_1 = create(:user_checklist, :completed, parent: c4_1)
          create(:user_checklist, :completed, parent: c4_1_1)
          expect(top4.percent_complete).to eq 100

          top5 = create(:user_checklist)

          c5_1 = create(:user_checklist, parent: top5) # 100% complete
          c5_1_1 = create(:user_checklist, :completed, parent: c5_1)
          create(:user_checklist, :completed, parent: c5_1_1)

          c5_2 = create(:user_checklist, parent: top5) # 0% complete
          c5_2_1 = create(:user_checklist, parent: c5_2)
          create(:user_checklist, parent: c5_2_1)

          c5_3 = create(:user_checklist, parent: top5) # 50% complete
          create(:user_checklist, :completed, parent: c5_3)
          create(:user_checklist, parent: c5_3)

          expect(c5_1.percent_complete).to eq 100
          expect(c5_2.percent_complete).to eq 0
          expect(c5_3.percent_complete).to eq 50

          # (100 + 0 + 50) / 3
          # top5 has 4 leaves:

          # name:     c5_1_1_1, c5_2_1_1,     c5_3_1,    c5_3_2
          # status:   complete, not complete, complete   not complete
          #           100       0             100        0
          #   (100 + 0 + 100 + 0) / 4
          #  = 200 / 4
          #  = 50%
          expect(top5.percent_complete).to eq 50
        end

        it ' based on Membership guidelines checklist' do
          # Example using the Membership Guidelines checklist (as of 2020-01-20)

          guidelines_root = create(:user_checklist, name: 'Membership Guidelines checklist')

          sec1 = create(:user_checklist, parent: guidelines_root, name: 'Respect the welfare of the dog.')
          create(:user_checklist, parent: sec1, name: 'sec1_leaf1')
          create(:user_checklist, parent: sec1, name: 'sec1_leaf2')
          create(:user_checklist, parent: sec1, name: 'sec1_leaf3')

          sec2 = create(:user_checklist, parent: guidelines_root, name: 'Respect dog owner.')
          create(:user_checklist, parent: sec2, name: 'sec2_leaf1')
          create(:user_checklist, parent: sec2, name: 'sec2_leaf2')
          create(:user_checklist, parent: sec2, name: 'sec2_leaf3')
          create(:user_checklist, parent: sec2, name: 'sec2_leaf4')

          sec3 = create(:user_checklist, parent: guidelines_root, name: 'Keep updated in my field.')
          create(:user_checklist, parent: sec3, name: 'sec3_leaf1')
          create(:user_checklist, parent: sec3, name: 'sec3_leaf2')
          create(:user_checklist, parent: sec3, name: 'sec3_leaf3')

          sec4 = create(:user_checklist, parent: guidelines_root, name: 'Follow applicable laws...')
          create(:user_checklist, parent: sec4, name: 'sec4_leaf1')
          create(:user_checklist, parent: sec4, name: 'sec4_leaf2')
          create(:user_checklist, parent: sec4, name: 'sec4_leaf3')
          create(:user_checklist, parent: sec4, name: 'sec4_leaf4')
          create(:user_checklist, parent: sec4, name: 'sec4_leaf5')
          create(:user_checklist, parent: sec4, name: 'sec4_leaf6')

          sec5 = create(:user_checklist, parent: guidelines_root, name: 'Respect my own role in relation to other professionals.')
          sec5_leaf1 = create(:user_checklist, parent: sec5, name: 'sec5_leaf1')
          sec5_leaf2 = create(:user_checklist, parent: sec5, name: 'sec5_leaf2')
          sec5_leaf3 = create(:user_checklist, parent: sec5, name: 'sec5_leaf3')

          sec6 = create(:user_checklist, parent: guidelines_root, name: 'Represent Sweden dog owners in a positive way.')
          create(:user_checklist, parent: sec6, name: 'sec6_leaf1')
          create(:user_checklist, parent: sec6, name: 'sec6_leaf2')
          create(:user_checklist, parent: sec6, name: 'sec6_leaf3')
          create(:user_checklist, parent: sec6, name: 'sec6_leaf4')

          # 23 leaves = 4.35 % per leaf
          #  3 leaves = 13.043478260869565
          #  4 leaves = 17.391304347826087  (17%)
          #  6 leaves = 26.08695652173913

          expect(guidelines_root.percent_complete).to eq 0

          [sec5_leaf3, sec5_leaf2, sec5_leaf1].each { |item| item.update(date_completed: Time.zone.now) }

          expect(guidelines_root.percent_complete).to eq 13

          # item sec5 is not counted in the percent complete (it's not a leaf)
          sec5.set_complete_including_children
          expect(sec5.completed?).to be_truthy
          expect(guidelines_root.percent_complete).to eq 13

          sec5.set_uncomplete_including_children
          expect(guidelines_root.percent_complete).to eq 0

          sec4.set_complete_including_children
          expect(guidelines_root.percent_complete).to eq 26

          # set the other sections to complete, testing the total each time
          sec1.set_complete_including_children
          expect(guidelines_root.percent_complete).to eq 39 #  26% + 13$
          sec2.set_complete_including_children
          expect(guidelines_root.percent_complete).to eq 57 #  39% + 17$ + rounding
          sec3.set_complete_including_children
          expect(guidelines_root.percent_complete).to eq 70 #  57% + 13$
          # section 4 is already set to complete
          sec5.set_complete_including_children
          expect(guidelines_root.percent_complete).to eq 83 #  70% + 13$
          sec6.set_complete_including_children
          expect(guidelines_root.percent_complete).to eq 100 # + 17%
        end
      end
    end
  end

  describe 'all_changed_by_completion_toggle' do
    describe 'is set to completed if it is not complete' do
      # ---- use this --------
      context 'has no descendants' do
        it 'is always set to complete' do
          root_no_descendants = create(:user_checklist)
          expect(root_no_descendants.all_completed?).to be_falsey

          root_no_descendants.all_changed_by_completion_toggle
          expect(root_no_descendants.all_completed?).to be_truthy
        end

        context 'has no ancestors' do

          it 'is set to completed' do
            root_no_descendants = create(:user_checklist)
            expect(root_no_descendants.all_completed?).to be_falsey

            root_no_descendants.all_changed_by_completion_toggle
            expect(root_no_descendants.reload.all_completed?).to be_truthy
          end

          it 'is the only item returned in the list of items changed' do
            root_no_descendants = create(:user_checklist)
            expect(root_no_descendants.all_completed?).to be_falsey

            expect(root_no_descendants.all_changed_by_completion_toggle).to match_array([root_no_descendants])
          end
        end

        context 'has ancestors' do
          it 'is set to completed' do
            grandchild_no_descendants = create(:user_checklist)

            child = create(:user_checklist)
            child.insert(grandchild_no_descendants)

            root_parent = create(:user_checklist)
            root_parent.insert(child)

            grandchild_no_descendants.all_changed_by_completion_toggle
            expect(grandchild_no_descendants.reload.all_completed?).to be_truthy
          end

          it 'ancestors are also in the list of items changed' do
            grandchild_no_descendants = create(:user_checklist)

            child = create(:user_checklist)
            child.insert(grandchild_no_descendants)

            root_parent = create(:user_checklist)
            root_parent.insert(child)

            expect(grandchild_no_descendants.all_changed_by_completion_toggle).to match_array([root_parent, child, grandchild_no_descendants])
          end

          it 'ancestor date_completed is updated even if it was already set' do
            grandchild_no_descendants = create(:user_checklist)

            child = create(:user_checklist, :completed)
            child_original_date_completed = child.date_completed
            child.insert(grandchild_no_descendants)

            root_parent = create(:user_checklist, :completed)
            root_parent_original_date_completed = root_parent.date_completed
            root_parent.insert(child)

            grandchild_no_descendants.all_changed_by_completion_toggle
            expect(child.reload.date_completed).not_to eq(child_original_date_completed)
            expect(root_parent.reload.date_completed).not_to eq(root_parent_original_date_completed)
          end
        end
      end

      context 'has descendants' do
        describe 'all descendants are complete' do
          it 'is set to completed' do

            greatgrandchild_completed = create(:user_checklist, :completed)
            grandchild_completed = create(:user_checklist, :completed)
            grandchild_completed.insert(greatgrandchild_completed)

            child_one_completed = create(:user_checklist, :completed)

            child_two_completed = create(:user_checklist, :completed)
            child_two_completed.insert(grandchild_completed)

            root = create(:user_checklist)
            root.insert(child_one_completed)
            root.insert(child_two_completed)

            expect(root.all_completed?).to be_falsey
            root.all_changed_by_completion_toggle
            expect(root.all_completed?).to be_truthy
          end

          context 'has no ancestors' do
            it 'is the only item returned in the list of items changed' do
              root_no_descendants = create(:user_checklist)
              expect(root_no_descendants.all_completed?).to be_falsey

              expect(root_no_descendants.all_changed_by_completion_toggle).to match_array([root_no_descendants])
            end
          end

          context 'has ancestors' do
            it 'ancestors are also in the list of items changed' do
              great_grandchild_complete = create(:user_checklist, :completed)

              grandchild = create(:user_checklist)
              grandchild.insert(great_grandchild_complete)

              child = create(:user_checklist)
              child.insert(grandchild)

              root_parent = create(:user_checklist)
              root_parent.insert(child)

              expect(grandchild.all_changed_by_completion_toggle).to match_array([root_parent, child, grandchild])
            end

            it 'ancestor date_completed is updated even if it was already set' do
              great_grandchild_complete = create(:user_checklist, :completed)

              grandchild = create(:user_checklist)
              grandchild.insert(great_grandchild_complete)

              child = create(:user_checklist, :completed)
              child_original_date_completed = child.date_completed
              child.insert(grandchild)

              root_parent = create(:user_checklist, :completed)
              root_parent_original_date_completed = root_parent.date_completed
              root_parent.insert(child)

              grandchild.all_changed_by_completion_toggle
              expect(child.reload.date_completed).not_to eq(child_original_date_completed)
              expect(root_parent.reload.date_completed).not_to eq(root_parent_original_date_completed)
            end
          end
        end

        context 'not all descendants are compelete' do
          it 'is not set to complete' do

            greatgrandchild_not_completed = create(:user_checklist)
            grandchild_completed = create(:user_checklist, :completed)
            grandchild_completed.insert(greatgrandchild_not_completed)

            child_one_not_completed = create(:user_checklist)

            child_two_completed = create(:user_checklist, :completed)
            child_two_completed.insert(grandchild_completed)

            root = create(:user_checklist)
            root.insert(child_one_not_completed)
            root.insert(child_two_completed)

            root.all_changed_by_completion_toggle

            # Must be sure to RELOAD so we get the updates
            expect(root.reload.all_completed?).to be_falsey
          end

          context 'has no ancestors' do
            it 'is not changed to completed' do

              greatgrandchild_not_completed = create(:user_checklist)
              grandchild_completed = create(:user_checklist, :completed)
              grandchild_completed.insert(greatgrandchild_not_completed)

              child_completed = create(:user_checklist, :completed)
              child_completed.insert(grandchild_completed)

              root = create(:user_checklist)
              root.insert(child_completed)

              root.all_changed_by_completion_toggle
              expect(root.reload.all_completed?).to be_falsey
            end

            it 'the list of items changed is empty' do
              greatgrandchild_not_completed = create(:user_checklist)
              grandchild_completed = create(:user_checklist, :completed)
              grandchild_completed.insert(greatgrandchild_not_completed)

              child_completed = create(:user_checklist, :completed)
              child_completed.insert(grandchild_completed)

              root = create(:user_checklist)
              root.insert(child_completed)

              expect(root.all_changed_by_completion_toggle).to be_empty
            end
          end

          context 'has ancestors' do
            it 'is not changed to completed' do
              greatgrandchild_not_completed = create(:user_checklist)
              grandchild_completed = create(:user_checklist, :completed)
              grandchild_completed.insert(greatgrandchild_not_completed)

              child_one_not_completed = create(:user_checklist)
              child_one_not_completed.insert(grandchild_completed)

              parent = create(:user_checklist)
              parent.insert(child_one_not_completed)

              child_one_not_completed.all_changed_by_completion_toggle
              expect(child_one_not_completed.reload.all_completed?).to be_falsey
            end

            it 'no ancestors are in the list of items changed' do
              greatgrandchild_not_completed = create(:user_checklist)
              grandchild_completed = create(:user_checklist, :completed)
              grandchild_completed.insert(greatgrandchild_not_completed)

              child_one_not_completed = create(:user_checklist)
              child_one_not_completed.insert(grandchild_completed)

              root = create(:user_checklist)
              root.insert(child_one_not_completed)

              expect(child_one_not_completed.all_changed_by_completion_toggle).to be_empty
            end
          end
        end
      end

      it 'default is Time.zone.now' do
        originally_not_complete = create(:user_checklist)
        expect(originally_not_complete.all_completed?).to be_falsey

        completed_time = Time.zone.now
        Timecop.freeze(completed_time) do
          originally_not_complete.all_changed_by_completion_toggle
        end
        expect(originally_not_complete.all_completed?).to be_truthy
        expect(originally_not_complete.date_completed).to eq completed_time
      end

      it 'sets to the given the time completed' do
        originally_not_complete = create(:user_checklist)
        expect(originally_not_complete.all_completed?).to be_falsey

        completed_time = Time.new(2020, 02, 20, 20, 20, 00)
        originally_not_complete.all_changed_by_completion_toggle(completed_time)

        expect(originally_not_complete.all_completed?).to be_truthy
        expect(originally_not_complete.date_completed).to eq completed_time
      end
    end

    describe 'is set to not completed if it was complete' do
      # ---- use this --------
      context 'has no descendants' do
        context 'has no ancestors' do
          it 'is always set to uncomplete' do
            originally_complete = create(:user_checklist, :completed)
            expect(originally_complete.all_completed?).to be_truthy
            originally_complete.all_changed_by_completion_toggle
            expect(originally_complete.reload.all_completed?).to be_falsey
          end

          it 'is the only item returned in the list of items changed' do
            originally_complete = create(:user_checklist, :completed)
            expect(originally_complete.all_completed?).to be_truthy
            expect(originally_complete.all_changed_by_completion_toggle).to match_array([originally_complete])
          end
        end

        context 'has ancestors' do
          it 'is set to completed' do
            grandchild_no_descendants = create(:user_checklist, :completed)

            child = create(:user_checklist, :completed)
            child.insert(grandchild_no_descendants)

            root_parent = create(:user_checklist, :completed)
            root_parent.insert(child)

            grandchild_no_descendants.all_changed_by_completion_toggle
            expect(grandchild_no_descendants.reload.all_completed?).to be_falsey
          end

          it 'only the ancestors changed to "not completed" are in the list of items changed' do
            greatgrandchild_completed = create(:user_checklist, :completed)
            grandchild_completed = create(:user_checklist, :completed)
            grandchild_completed.insert(greatgrandchild_completed)

            child_not_completed = create(:user_checklist)
            child_not_completed.insert(grandchild_completed)

            root_parent_not_completed = create(:user_checklist)
            root_parent_not_completed.insert(child_not_completed)

            expect(greatgrandchild_completed.all_changed_by_completion_toggle).to match_array([grandchild_completed, greatgrandchild_completed])
          end
        end
      end

      context 'has descendants' do
        context 'has no ancestors' do
          it 'is always set to uncomplete' do
            grandchild_no_descendants = create(:user_checklist, :completed)

            child = create(:user_checklist, :completed)
            child.insert(grandchild_no_descendants)

            root_parent = create(:user_checklist, :completed)
            root_parent.insert(child)

            root_parent.all_changed_by_completion_toggle
            expect(root_parent.reload.all_completed?).to be_falsey
          end

          it 'is the only item returned in the list of items changed' do
            grandchild_no_descendants = create(:user_checklist, :completed)

            child = create(:user_checklist, :completed)
            child.insert(grandchild_no_descendants)

            root_parent = create(:user_checklist, :completed)
            root_parent.insert(child)

            expect(root_parent.all_changed_by_completion_toggle).to match_array([root_parent])
          end
        end

        context 'has ancestors' do
          it 'is always set to uncomplete' do
            grandchild_no_descendants = create(:user_checklist, :completed)

            child = create(:user_checklist, :completed)
            child.insert(grandchild_no_descendants)

            root_parent = create(:user_checklist, :completed)
            root_parent.insert(child)

            child.all_changed_by_completion_toggle
            expect(child.reload.all_completed?).to be_falsey
          end

          it 'ancestors are also in the list of items changed' do
            grandchild_no_descendants = create(:user_checklist, :completed)

            child = create(:user_checklist, :completed)
            child.insert(grandchild_no_descendants)

            root_parent = create(:user_checklist, :completed)
            root_parent.insert(child)

            child.all_changed_by_completion_toggle
            expect(child.reload.all_changed_by_completion_toggle).to match_array([root_parent, child])
          end

          it 'only the ancestors changed to "not completed" are in the list of items changed' do
            greatgrandchild_completed = create(:user_checklist, :completed)
            grandchild_completed = create(:user_checklist, :completed)
            grandchild_completed.insert(greatgrandchild_completed)

            child_completed = create(:user_checklist, :completed)
            child_completed.insert(grandchild_completed)

            root_parent_not_completed = create(:user_checklist)
            root_parent_not_completed.insert(child_completed)

            expect(grandchild_completed.all_changed_by_completion_toggle).to match_array([child_completed, grandchild_completed])
          end
        end
      end
    end
  end

  describe 'set_complete_including_children' do
    # Would be good to stub things so these tests don't hit the db so much
    it 'sets self to complete' do
      uc = create(:user_checklist)
      uc.set_complete_including_children
      expect(uc.completed?).to be_truthy
    end

    it 'sets all descendants that were not already complete to complete' do
      root = create(:user_checklist)
      child1 = create(:user_checklist, parent: root, name: 'child1')
      child1_1 = create(:user_checklist, parent: child1, name: 'child1_1')
      child1_1_1_complete = create(:user_checklist, :completed, parent: child1_1, name: 'child1_1_1')
      child2_complete = create(:user_checklist, :completed, parent: root, name: 'child2')

      child1_1_1_completed_time = child1_1_1_complete.reload.date_completed
      child1_1_1_complete_orig_date_completed = child1_1_1_completed_time
      child2_complete_orig_date_completed = child2_complete.reload.date_completed

      expect(root.all_that_are_uncompleted.count).to eq 3
      expect(root.completed?).to be_falsey
      expect(child1.completed?).to be_falsey
      expect(child1_1.completed?).to be_falsey

      root.set_complete_including_children

      expect(root.all_that_are_uncompleted.count).to eq 0

      # descendants that were uncomplete are now complete
      expect(root.completed?).to be_truthy
      expect(child1.reload.completed?).to be_truthy
      expect(child1_1.reload.completed?).to be_truthy

      # descendants that were already complete are not changed
      # use strftime to check the date and time only to thousands of a second. (Semaphore was comparing to a higher accuracy and was sometimes off)
      str_format = '%F%T%L'
      expect(child1_1_1_completed_time.strftime(str_format)).to eq child1_1_1_complete_orig_date_completed.strftime(str_format)
      expect(child2_complete.reload.date_completed.strftime(str_format)).to eq child2_complete_orig_date_completed.strftime(str_format)
    end

    it 'sets ancestors to complete if appropriate' do
      root = create(:user_checklist)
      child1 = create(:user_checklist, parent: root, name: 'child1')
      child1_1 = create(:user_checklist, parent: child1, name: 'child1_1')
      child1_1_1_complete = create(:user_checklist, parent: child1_1, name: 'child1_1_1')
      create(:user_checklist, :completed, parent: root, name: 'child2')

      child1_1_1_complete.set_complete_including_children
      expect(child1_1_1_complete.reload.completed?).to be_truthy
      expect(child1_1.reload.completed?).to be_truthy
      expect(child1.reload.completed?).to be_truthy
      expect(root.reload.all_completed?).to be_truthy
    end

    it 'can specify the date_completed' do
      root = create(:user_checklist)
      child1 = create(:user_checklist, parent: root, name: 'child1')

      given_date_completed = Time.parse("2020-10-31")

      root.set_complete_including_children(given_date_completed)
      expect(root.reload.date_completed).to eq given_date_completed
      expect(child1.reload.date_completed).to eq given_date_completed
    end
  end

  describe 'set_uncomplete_including_children' do
    # Would be good to stub things so these tests don't hit the db so much
    it 'sets self to uncomplete' do
      uc = create(:user_checklist)
      uc.set_uncomplete_including_children
      expect(uc.completed?).to be_falsey
    end

    it 'sets all descendants that were complete to uncomplete' do

      # descendants that were already uncomplete are not changed
      root = create(:user_checklist)
      child1 = create(:user_checklist, parent: root, name: 'child1')
      child1_1_complete = create(:user_checklist, :completed, parent: child1, name: 'child1_1')
      child1_1_1 = create(:user_checklist, parent: child1_1_complete, name: 'child1_1_1')
      child2_complete = create(:user_checklist, :completed, parent: root, name: 'child2')

      child1_orig_date_completed = child1.date_completed
      child1_1_1_orig_date_completed = child1_1_1.date_completed

      expect(root.all_that_are_completed.count).to eq 2
      expect(child1_1_complete.completed?).to be_truthy
      expect(child2_complete.completed?).to be_truthy

      root.set_uncomplete_including_children

      expect(root.all_that_are_completed.count).to eq 0

      # updated_at is changed for all descendants that were complete
      expect(child1_1_complete.completed?).to be_truthy
      expect(child2_complete.completed?).to be_truthy

      # descendants that were already uncomplete are not changed
      expect(child1.reload.date_completed).to eq child1_orig_date_completed
      expect(child1_1_1.reload.date_completed).to eq child1_1_1_orig_date_completed
    end
  end

  describe 'set_complete_update_parent' do
    let(:given_date_completed) { Time.parse("2020-10-31") }

    it 'returns empty list if descendents are not all complete' do
      root = create(:user_checklist)
      create(:user_checklist, parent: root, name: 'child1')

      expect(root.send(:set_complete_update_parent)).to be_empty
    end

    context 'descendents are all complete' do
      it 'updates date_completed to the new date complete' do
        root = create(:user_checklist)
        create(:user_checklist, :completed, parent: root, name: 'child1')
        create(:user_checklist, :completed, parent: root, name: 'child2')

        expect(root).to receive(:update).with(date_completed: given_date_completed)

        expect(root.send(:set_complete_update_parent, given_date_completed)).not_to be_empty
      end

      context 'has a parent' do
        let(:root) { create(:user_checklist) }
        let(:child1) { create(:user_checklist, :completed, parent: root, name: 'child1') }
        let(:child2) { create(:user_checklist, :completed, parent: root, name: 'child2') }

        it 'adds the results of parent.set_complete_update_parent to the list of checklists changed' do
          expect(child1.send(:set_complete_update_parent, given_date_completed)).to match_array([root, child1])
        end
      end
    end
  end

  describe 'set_uncomplete_update_parent' do
    it 'returns empty list if the checklist is already uncomplete' do
      root = create(:user_checklist)

      expect(root.send(:set_uncomplete_update_parent)).to be_empty
    end

    context 'is currently completed' do
      it 'updates date_completed nil (= uncomplete)' do
        root = create(:user_checklist, :completed)

        expect(root).to receive(:update).with(date_completed: nil)

        expect(root.send(:set_uncomplete_update_parent)).to match_array([root])
      end

      context 'has a parent' do
        let(:root) { create(:user_checklist, :completed) }
        let(:child1) { create(:user_checklist, :completed, parent: root, name: 'child1') }
        let(:child2) { create(:user_checklist, :completed, parent: root, name: 'child2') }

        it 'adds the results of parent.set_uncomplete_update_parent to the list of checklists changed' do
          expect(child1.send(:set_uncomplete_update_parent)).to match_array([root, child1])
        end
      end
    end
  end
end
