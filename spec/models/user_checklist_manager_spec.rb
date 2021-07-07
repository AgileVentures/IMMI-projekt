require 'rails_helper'

require 'shared_context/users'

RSpec.describe UserChecklistManager do

  include ActiveSupport::Testing::TimeHelpers

  include_context 'create users'

  let(:june_6) { Time.zone.local(2020, 6, 6) }
  let(:june_5) { Time.zone.local(2020, 6, 5) }

  # TODO get this from AppConfiguration later / stub (the membership guidelines list type, etc.)
  let(:membership_guidelines_type_name) { AdminOnly::MasterChecklistType::MEMBER_GUIDELINES_LIST_TYPE }
  let(:guideline_list_type) { create(:master_checklist_type, name: membership_guidelines_type_name) }
  let(:guideline_master) { create(:master_checklist, master_checklist_type: guideline_list_type) }

  let(:u) { build(:user) }
  let(:yesterday) { Date.current - 1 }
  let(:completion_date_20200102) { Date.new(2020, 1, 2) }


  describe '.completed_membership_guidelines_checklist?' do

    context 'user is in the grace period'  do
      it 'checklist must be completed after the last membership started (so can renew)' do
        grace_user = build(:user)
        allow(grace_user).to receive(:in_grace_period?).and_return(true)
        expect(described_class).to receive(:find_on_or_after_latest_membership_start)
                                     .with(grace_user)
        described_class.completed_membership_guidelines_checklist?(grace_user)
      end
    end

    context 'user is not in the grace period' do

      it 'is always false if the user is a former member' do
        former_member = build(:user, membership_status: :former_member)
        expect(described_class).not_to receive(:find_on_or_after_latest_membership_start)
        expect(described_class).not_to receive(:membership_guidelines_list_for)
        expect( described_class.completed_membership_guidelines_checklist?(former_member)).to be_falsey
      end

      let(:not_in_grace_user) { build(:user) }
      before(:each) { allow(not_in_grace_user).to receive(:in_grace_period?).and_return(false) }

      it 'the latest checklist must be completed' do
        expect(described_class).to receive(:membership_guidelines_list_for)
                                     .with(not_in_grace_user)
        described_class.completed_membership_guidelines_checklist?(not_in_grace_user)
      end

      it 'true if all are completed' do
        completed = create(:user_checklist, :completed, num_completed_children: 2)
        allow(described_class).to receive(:membership_guidelines_list_for)
                                    .with(not_in_grace_user)
                                    .and_return(completed)
        expect(described_class.completed_membership_guidelines_checklist?(not_in_grace_user)).to be_truthy
      end

      it 'false if all are not completed' do
        not_completed = create(:user_checklist, num_children: 2)
        allow(described_class).to receive(:membership_guidelines_list_for)
                                    .with(not_in_grace_user)
                                    .and_return(not_completed)
        expect(described_class.completed_membership_guidelines_checklist?(not_in_grace_user)).to be_falsey
      end
    end

    it 'returns false if there are no lists for the user' do
      allow(AdminOnly::MasterChecklist).to receive(:latest_membership_guideline_master)
                                             .and_return(create(:membership_guidelines_master_checklist))
      expect(described_class.completed_membership_guidelines_checklist?(create(:user))).to be_falsey
    end

    it 'calls UserChecklist .all_completed? to determine if it is complete or not' do
      checklist = create(:user_checklist)
      user_for_checklist = checklist.user

      allow(UserChecklist).to receive(:membership_guidelines_for_user).and_return([checklist])
      expect(checklist).to receive(:all_completed?)

      described_class.completed_membership_guidelines_checklist?(user_for_checklist)
    end
  end


  describe '.find_or_create_on_or_after_latest_membership_start' do
    let(:latest_membership) { build(:membership, user: user, first_day: yesterday) }

    let(:most_recent_checklist) { build(:user_checklist, :completed, user: user,
                                        date_completed: completion_date_20200102) }

    it 'gets the most recent membership for the user' do
      allow(described_class).to receive(:create_for_user_if_needed)
      expect(MembershipsManager).to receive(:most_recent_membership)
                                      .with(u)
                                      .and_return(nil)
      described_class.find_or_create_on_or_after_latest_membership_start(u)
    end

    it 'creates Membership guideline checklists for the user if there is no recent membership' do
      allow(MembershipsManager).to receive(:most_recent_membership)
                                      .with(u)
                                      .and_return(nil)

      expect(described_class).to receive(:create_for_user_if_needed)
                                   .with(u)
      described_class.find_or_create_on_or_after_latest_membership_start(u)
    end

    context 'there is a recent membershp' do
      before(:each) do
        allow(MembershipsManager).to receive(:most_recent_membership)
                                       .with(u)
                                       .and_return(latest_membership)
      end

      it "gets the user's guideline checklists created on or after the first day of the user's latest membership" do
        top_level_checklists = double("UserChecklist::ActiveRecord_Relation")
        allow(top_level_checklists).to receive(:uncompleted).and_return([])
        allow(described_class).to receive(:create_for_user_if_needed)
        expect(UserChecklist).to receive(:most_recently_created_top_level_guidelines)
                                   .with(u, latest_membership.first_day)
                                   .and_return(top_level_checklists)
        described_class.find_or_create_on_or_after_latest_membership_start(u)
      end

      context 'no incomplete guideline checklists created on or after the first day of the latest membership' do
        before(:each) do
          top_level_checklists = double("UserChecklist::ActiveRecord_Relation")
          allow(top_level_checklists).to receive(:uncompleted).and_return([])
        end

        it 'calls create for user if needed with the user and a nil guideline' do
          expect(described_class).to receive(:create_for_user_if_needed).with(u, guideline: nil)
          described_class.find_or_create_on_or_after_latest_membership_start(u)
        end
      end

      context 'there are incomplete checklists created on or after the first day of the latest membership' do
        before(:each) do
          top_level_checklists = double("UserChecklist::ActiveRecord_Relation")
          allow(UserChecklist).to receive(:most_recently_created_top_level_guidelines)
                                    .and_return(top_level_checklists)
          allow(top_level_checklists).to receive(:uncompleted).and_return([most_recent_checklist])
        end

        it 'calls create for user if needed with the user and the latest found guideline checklist' do
          expect(described_class).to receive(:create_for_user_if_needed).with(u, guideline: most_recent_checklist)
          described_class.find_or_create_on_or_after_latest_membership_start(u)
        end
      end
    end
  end


  describe '.first_incomplete_membership_guideline_section_for' do

    it 'nil if all are completed' do
      user_all_completed = build(:user, first_name: 'AllCompleted')
      user_checklist = create(:user_checklist, user: user_all_completed,
                              master_checklist: guideline_master,
                              num_completed_children: 2)
      allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                  .with(user_all_completed)
                                                  .and_return(user_checklist)
      expect(described_class.first_incomplete_membership_guideline_section_for(user_all_completed)).to be_nil
    end

    it 'first completed guideline (based on the list position) of the membership guidelines' do
      user_some_completed = build(:user, first_name: 'SomeCompleted')
      user_checklist = create(:user_checklist, user: user_some_completed,
                              master_checklist: guideline_master,
                              num_children: 3,
                              num_completed_children: 2)
      allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                  .with(user_some_completed)
                                                  .and_return(user_checklist)
      allow(described_class).to receive(:membership_guidelines_list_for)
                                  .with(user_some_completed)
                                  .and_return(user_checklist)
      result = described_class.first_incomplete_membership_guideline_section_for(user_some_completed)
      expect(result.completed?).to be_falsey
    end
  end


  describe 'create_for_user_if_needed' do

    it 'default guideline is nil' do
      expect(described_class).to receive(:create_for_user).with(u)
      described_class.create_for_user_if_needed(u)
    end

    it 'creates a new set of checklists for the user if the guideline is nil' do
      expect(described_class).to receive(:create_for_user).with(u)
      described_class.create_for_user_if_needed(u, guideline: nil)
    end

    it 'returns the given guideline if guideline is not nil' do
      expect(described_class).not_to receive(:create_for_user)
      described_class.create_for_user_if_needed(u, guideline: 'blorf')
    end
  end


  describe '.membership_guidelines_list_for' do

    it 'returns nil if there are no lists for the user' do
      expect(described_class.membership_guidelines_list_for(create(:user))).to be_nil
    end

    it 'returns the most recently created user checklist' do
      user = create(:user, first_name: 'User', last_name: 'With-Checklists')

      # make 2 and expect the most recently created one to be returned
      travel_to(Time.now - 2.days) do
        create(:user_checklist, :completed, user: user, name: 'older list')
      end

      create(:user_checklist, :completed, user: user, name: 'more recent list')

      allow(UserChecklist).to receive(:membership_guidelines_for_user).and_return(user.checklists)

      expect(described_class.membership_guidelines_list_for(user)).to eq UserChecklist.find_by(name: 'more recent list')
    end


  end

  describe '.completed_guidelines_for' do

    it 'empty list if  there is no list for the user' do
      user_no_checklist = build(:user)
      expect(described_class.completed_guidelines_for(user_no_checklist)).to be_empty
    end

    context 'no guidelines completed' do
      it 'empty list' do
        num_completed = 0
        user_none_completed = build(:user)
        user_checklist = create(:user_checklist, user: user_none_completed,
                                master_checklist: guideline_master,
                                num_children: 2,
                                num_completed_children: num_completed)
        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                    .with(user_none_completed)
                                                    .and_return(user_checklist)

        expect(described_class.completed_guidelines_for(user_none_completed)).to be_empty
      end
    end

    context 'some guidelines completed' do
      it 'list with only the completed guidelines' do
        num_completed = 1
        user_some_completed = build(:user, first_name: 'SomeCompleted')
        user_checklist = create(:user_checklist, user: user_some_completed,
                                master_checklist: guideline_master,
                                num_children: 3,
                                num_completed_children: num_completed)
        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                    .with(user_some_completed)
                                                    .and_return(user_checklist)
        expect(described_class.completed_guidelines_for(user_some_completed).count).to eq num_completed
      end
    end

    context 'all guidelines completed' do
      it 'list all the guidelines' do
        num_completed = 2
        user_all_completed = build(:user, first_name: 'AllCompleted')
        user_checklist = create(:user_checklist, :completed,
                                user: user_all_completed,
                                master_checklist: guideline_master,
                                num_completed_children: num_completed)
        expect(user_checklist.all_completed?).to be_truthy

        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                    .with(user_all_completed)
                                                    .and_return(user_checklist)
        expect(described_class.completed_guidelines_for(user_all_completed).count).to eq num_completed
      end
    end
  end

  describe '.not_completed_guidelines_for' do

    it 'empty list if  there is no list for the user' do
      user_no_checklist = build(:user)
      expect(described_class.not_completed_guidelines_for(user_no_checklist)).to be_empty
    end

    context 'no guidelines completed' do
      it 'all of the guidelines' do
        num_children = 2
        num_completed = 0
        user_none_completed = build(:user)
        user_checklist = create(:user_checklist, user: user_none_completed,
                                master_checklist: guideline_master,
                                num_children: num_children,
                                num_completed_children: num_completed)
        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                    .with(user_none_completed)
                                                    .and_return(user_checklist)
        expect(described_class.not_completed_guidelines_for(user_none_completed).count).to eq num_children
      end
    end

    context 'some guidelines completed' do
      it 'list with only the uncompleted guidelines' do
        num_completed = 1
        num_children = 3
        expected_uncompleted = num_children - num_completed
        user_some_completed = build(:user, first_name: 'SomeCompleted')
        user_checklist = create(:user_checklist, user: user_some_completed,
                                master_checklist: guideline_master,
                                num_children: num_children,
                                num_completed_children: num_completed)

        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                    .with(user_some_completed)
                                                    .and_return(user_checklist)
        allow(described_class).to receive(:membership_guidelines_list_for)
                                    .with(user_some_completed)
                                    .and_return(user_checklist)

        expect(user_checklist.all_that_are_completed.count).to eq 1
        expect(user_checklist.all_that_are_uncompleted.count).to eq 3

        expect(described_class.not_completed_guidelines_for(user_some_completed).count).to eq(expected_uncompleted)
      end
    end

    context 'all guidelines are completed' do
      it 'is empty' do
        num_completed = 2
        user_all_completed = build(:user, first_name: 'AllCompleted')
        user_checklist = create(:user_checklist, :completed,
                                user: user_all_completed,
                                master_checklist: guideline_master,
                                num_completed_children: num_completed)
        expect(user_checklist.all_completed?).to be_truthy

        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                    .with(user_all_completed)
                                                    .and_return(user_checklist)
        expect(described_class.not_completed_guidelines_for(user_all_completed).count).to eq 0
      end
    end
  end

  describe '.checklist_done_on_or_after_latest_membership_start?' do
    let(:latest_membership) { build(:membership, user: user, first_day: yesterday) }

    let(:most_recent_checklist) { build(:user_checklist, :completed, user: user,
                                        date_completed: completion_date_20200102) }

    it 'false if there is no recent membership for the user' do
      expect(MembershipsManager).to receive(:most_recent_membership)
                                      .with(u)
                                      .and_return(nil)
      expect(described_class.checklist_done_on_or_after_latest_membership_start?(u)).to be_falsey
    end

    context 'there is a recent membership for the user' do
      before(:each) do
        allow(MembershipsManager).to receive(:most_recent_membership)
                                       .with(u)
                                       .and_return(latest_membership)
      end

      it "gets the first day for the user's latest membership" do
        allow(UserChecklist).to receive(:most_recent_completed_top_level_guideline)
                                  .with(u)
                                  .and_return(most_recent_checklist)

        expect(latest_membership).to receive(:first_day).and_return(yesterday)
        described_class.checklist_done_on_or_after_latest_membership_start?(u)
      end

      it 'false if there is no recently completed guidelines checklist for the user' do
        allow(UserChecklist).to receive(:most_recent_completed_top_level_guideline)
                                  .with(u)
                                  .and_return(nil)

        expect(described_class.checklist_done_on_or_after_latest_membership_start?(u)).to be_falsey
      end

      context 'there is a most recently completed guidelines checklist for the user' do
        before(:each) do
          allow(UserChecklist).to receive(:most_recent_completed_top_level_guideline)
                                    .with(u)
                                    .and_return(most_recent_checklist)
        end

        it 'gets the date the most recently completed checklist was completed' do
          expect(most_recent_checklist).to receive(:date_completed).and_return(yesterday)
          described_class.checklist_done_on_or_after_latest_membership_start?(u)
        end

        it 'false if the checklist was completed before the first day of the recent membership' do
          allow(latest_membership).to receive(:first_day).and_return(yesterday)
          allow(most_recent_checklist).to receive(:date_completed).and_return(yesterday - 1)
          expect(described_class.checklist_done_on_or_after_latest_membership_start?(u)).to be_falsey
        end

        it 'true if the checklist was completed on the first day of the recent membership' do
          allow(latest_membership).to receive(:first_day).and_return(yesterday)
          allow(most_recent_checklist).to receive(:date_completed).and_return(yesterday)
          expect(described_class.checklist_done_on_or_after_latest_membership_start?(u)).to be_truthy
        end

        it 'true if the checklist was completed after the first day of the recent membership' do
          allow(latest_membership).to receive(:first_day).and_return(yesterday)
          allow(most_recent_checklist).to receive(:date_completed).and_return(yesterday + 1)
          expect(described_class.checklist_done_on_or_after_latest_membership_start?(u)).to be_truthy
        end
      end
    end
  end
end
