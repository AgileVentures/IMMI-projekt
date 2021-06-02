require 'rails_helper'

RSpec.describe UserChecklistsController, type: :controller do
  let(:not_completed_checklist) { create(:user_checklist) }
  let(:completed_checklist) { create(:user_checklist, :completed) }


  # This assumes that params has been defined, e.g. with a let statement
  # This assumes that completed_checklist has been defined, e.g. with a let statement
  shared_examples 'it calls MembershipStatusUpdater when the checklist is 100% complete' do |post_method|
    before(:each) {}

    it 'calls MembershipStatusUpdater when the checklist is 100% complete' do
      allow(subject).to receive(:validate_and_authorize_xhr).and_return(true)
      completed_checklist_root = completed_checklist.root
      allow(completed_checklist_root).to receive(:percent_complete).and_return(100)
      allow(UserChecklist).to receive(:find).with("#{completed_checklist.id}")
                                            .and_return(completed_checklist)
      expect(MembershipStatusUpdater.instance).to receive(:checklist_completed).with(completed_checklist_root)
      post post_method, params: params
    end
  end

  # This assumes that params has been defined, e.g. with a let statement
  # # This assumes that not_completed_checklist has been defined, e.g. with a let statement
  shared_examples 'it does not call MembershipStatusUpdater if the root is not 100% complete' do | post_method|
    it 'MembershipStatusUpdater is not called' do
      allow(subject).to receive(:validate_and_authorize_xhr).and_return(true)
      not_completed_checklist_root = not_completed_checklist.root
      allow(not_completed_checklist_root).to receive(:percent_complete).and_return(99)
      allow(UserChecklist).to receive(:find).with("#{not_completed_checklist.id}")
                                            .and_return(not_completed_checklist)

      expect(MembershipStatusUpdater.instance).not_to receive(:checklist_completed)
      post post_method, params: params
    end
  end
  #   end shared_examples
  # --------------------------------------------------------------------------------------------


  describe 'set_complete_including_kids' do
    before(:each) { allow(subject).to receive(:validate_and_authorize_xhr).and_return(true) }

    it_behaves_like 'it calls MembershipStatusUpdater when the checklist is 100% complete', :set_complete_including_kids do
      let(:params) { { 'id' => "#{completed_checklist.id}" } }
    end

    it_behaves_like 'it does not call MembershipStatusUpdater if the root is not 100% complete', :set_complete_including_kids do
      let(:params) { { 'id' => "#{not_completed_checklist.id}" } }
    end
  end


  describe 'all_changed_by_completion_toggle' do
    before(:each) { allow(subject).to receive(:validate_and_authorize_xhr).and_return(true) }

    it_behaves_like 'it calls MembershipStatusUpdater when the checklist is 100% complete', :all_changed_by_completion_toggle do
      let(:params) { { 'id' => "#{completed_checklist.id}" } }
    end

    it_behaves_like 'it does not call MembershipStatusUpdater if the root is not 100% complete', :all_changed_by_completion_toggle do
      let(:params) { { 'id' => "#{not_completed_checklist.id}" } }
    end
  end


  describe 'show_progress' do
    before(:each) { allow(subject).to receive(:authorize_user_checklist).and_return(true) }


    it 'calls MembershipStatusUpdater if the checklist root is 100% complete ' do
      expect(MembershipStatusUpdater.instance).to receive(:checklist_completed).with(completed_checklist.root)
      post :show_progress, params: { 'user_id' => "#{completed_checklist.user.id}", 'user_checklist_id' => "#{completed_checklist.id}" }
    end


    it 'does not call MembershipStatusUpdater if the checklist is not 100% complete' do
      expect(MembershipStatusUpdater.instance).not_to receive(:checklist_completed)
      post :show_progress, params: { 'user_id' => "#{not_completed_checklist.user.id}", 'user_checklist_id' => "#{not_completed_checklist.id}" }
    end
  end
end
