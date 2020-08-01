require 'rails_helper'


describe ShfApplicationPolicy do

  let(:mock_log) { instance_double("ActivityLogger") }

  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)

    # stub this so we don't have to create the MasterChecklist for the Member Guidelines checklist
    # if a ShfApplication is accepted.
    allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for).and_return(true)
  end


  SHFAPP_CRUD_ACTIONS = [:new, :create, :show, :edit, :update,  :destroy].freeze unless defined?(SHFAPP_CRUD_ACTIONS)

  APP_STATE_CHANGE_ACTIONS = [:accept, :reject, :need_info, :cancel_need_info, :start_review].freeze  unless defined?(APP_STATE_CHANGE_ACTIONS)


  let(:admin) { create(:user, email: 'admin@shf.se', admin: true) }

  let(:member_not_owner) { create(:member_with_membership_app, email: 'member_not_owner@random.com') }
  let(:member_applicant) do
    member = create(:user, member: true, email: 'member_owner@random.com')
    member.shf_application = create(:shf_application, state: :new)
    member
  end

  let(:user_not_owner) { create(:user, email: 'user_not_owner@random.com') }
  let(:user_applicant) { create(:user_with_membership_app, email: 'user_owner@random.com') }
  let(:user_2) { create(:user) }
  let(:application) { create(:shf_application, state: :new) }

  let(:visitor) { build(:visitor) }


  describe 'changing the application state attribute, given a controller action' do

    describe 'for a Visitor' do
      subject { described_class.new(visitor, application) }

      SHFAPP_CRUD_ACTIONS.each do |action|
        it "forbids :state change for :#{action} action" do
          is_expected.to forbid_mass_assignment_of(:state).for_action(action)
        end
      end
    end


    describe 'Member or User not the owner - :state assignment only allowed for new, create' do

      { 'Member': :member_not_owner,
        'User': :user_not_owner }.each do |user_class, current_user|

        describe "For #{user_class} (not the owner of the application)" do

          let(:app_being_checked) { user_applicant.shf_application }

          SHFAPP_CRUD_ACTIONS.each do |action|
            it "forbids :state to be changed for :#{action} action" do
              expect(described_class.new(self.send(current_user), app_being_checked)).to forbid_mass_assignment_of(:state).for_action(action)
            end
          end
        end
      end
    end


    describe 'Member or User that is the owner of a *new* SHFApplication' do

      { 'Member': :member_applicant,
        'User': :user_applicant }.each do |user_class, current_user|

        describe "For #{user_class} (is the owner of a new application)" do

          let(:app_being_checked) { self.send(current_user).shf_application }

          (SHFAPP_CRUD_ACTIONS - [:destroy]).each do |action|
            it "permits :state to be changed for :#{action} action" do
              expect(described_class.new(self.send(current_user), app_being_checked)).to permit_mass_assignment_of(:state).for_action(action)
            end
          end

          it 'forbids :state to be changed for destroy' do
            expect(described_class.new(self.send(current_user), app_being_checked)).to forbid_mass_assignment_of(:state).for_action(:destroy)
          end
        end
      end
    end


    describe 'For the Member owner of an *approved* SHFApplication' do

      let(:application) do
        member_applicant.shf_application.update(state: :accepted)
        member_applicant.shf_application
      end

      subject { described_class.new(member_applicant, application) }

      it 'permits show' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:show)
      end

      (SHFAPP_CRUD_ACTIONS - [:show]).each do |action|
        it "forbids :state to be changed for #{action}" do
          is_expected.to forbid_mass_assignment_of(:state).for_action(action)
        end
      end
    end


    describe 'for Admins' do
      subject { described_class.new(admin, application) }

      SHFAPP_CRUD_ACTIONS.each do |action|
        it "permits :state to be changed for :#{action} action" do
          is_expected.to permit_mass_assignment_of(:state).for_action(action)
        end
      end
    end

  end


  describe 'actions on the membership application' do

    describe 'For visitors (not logged in)' do
      subject { described_class.new(visitor, application) }

      it 'forbids :information' do
        is_expected.to forbid_action :information
      end

      it 'forbids :index' do
        is_expected.to forbid_action :index
      end

      it 'forbids all CRUD actions' do
        is_expected.to forbid_actions(SHFAPP_CRUD_ACTIONS)
      end

      it 'forbids all application state change actions' do
        is_expected.to forbid_actions APP_STATE_CHANGE_ACTIONS
      end

    end


    describe 'Member or User not the owner can only create a new one and view information' do

      describe "For User (without an application)" do

        let(:current_user) { :user_not_owner }

        it 'permits new for a new application (not already instantiated)' do
          expect(described_class.new(self.send(current_user), ShfApplication)).to permit_action :new
        end

        it 'forbids new for an existing application (already instantiated)' do
          expect(described_class.new(self.send(current_user), application)).to forbid_action :new
        end

        it 'permits create for a new application (not already instantiated)' do
          expect(described_class.new(self.send(current_user), ShfApplication)).to permit_action :create
        end

        it 'forbids create for an existing application (already instantiated)' do
          expect(described_class.new(self.send(current_user), application)).to forbid_action :create
        end

        it 'forbids all other CRUD actions (that are not :new or :create)' do
          expect(described_class.new(self.send(current_user), application)).to forbid_actions(SHFAPP_CRUD_ACTIONS - [:new, :create])
        end

        it 'permits :information' do
          expect(described_class.new(self.send(current_user), application)).to permit_action :information
        end

        it 'forbids :index' do
          expect(described_class.new(self.send(current_user), application)).to forbid_action :index
        end

        it 'forbids all application state change actions' do
          expect(described_class.new(self.send(current_user), application)).to forbid_actions APP_STATE_CHANGE_ACTIONS
        end

      end

      describe "For Member (who already has application)" do

        let(:current_user) { :member_not_owner }

        it 'forbids new for a new application (not already instantiated)' do
          expect(described_class.new(self.send(current_user), ShfApplication)).to forbid_action :new
        end

        it 'forbids new for an existing application (already instantiated)' do
          expect(described_class.new(self.send(current_user), application)).to forbid_action :new
        end

        it 'forbids create for a new application (not already instantiated)' do
          expect(described_class.new(self.send(current_user), ShfApplication)).to forbid_action :create
        end

        it 'forbids create for an existing application (already instantiated)' do
          expect(described_class.new(self.send(current_user), application)).to forbid_action :create
        end

        it 'forbids all other CRUD actions (that are not :new or :create)' do
          expect(described_class.new(self.send(current_user), application)).to forbid_actions(SHFAPP_CRUD_ACTIONS - [:new, :create])
        end

        it 'permits :information' do
          expect(described_class.new(self.send(current_user), application)).to permit_action :information
        end

        it 'forbids :index' do
          expect(described_class.new(self.send(current_user), application)).to forbid_action :index
        end

        it 'forbids all application state change actions' do
          expect(described_class.new(self.send(current_user), application)).to forbid_actions APP_STATE_CHANGE_ACTIONS
        end

      end

    end


    describe 'For User or Member that is the owner of a *new* SHFApplication' do

      { 'Member': :member_applicant,
        'User': :user_applicant }.each do |user_class, current_user|

        describe "For #{user_class} (is the owner of a new application)" do

          let(:app_being_checked) { self.send(current_user).shf_application }

          it 'forbids new for a new application (not already instantiated)' do
            expect(described_class.new(self.send(current_user), ShfApplication)).to forbid_action :new
          end

          describe 'For other users of ShfApplication' do
            subject { described_class.new(user_2, application) }
            it 'forbids new for an existing application (already instantiated)' do
              expect(described_class.new(self.send(current_user), app_being_checked)).to forbid_action :new
            end

            it 'forbids create for a new application (not already instantiated)' do
              expect(described_class.new(self.send(current_user), described_class)).to forbid_action :create
            end

            it 'permits create for an existing application (already instantiated)' do
              expect(described_class.new(self.send(current_user), app_being_checked)).to permit_action :create
            end

            it 'permits show' do
              expect(described_class.new(self.send(current_user), app_being_checked)).to permit_action :show
            end

            it 'forbids index' do
              expect(described_class.new(self.send(current_user), app_being_checked)).to forbid_action :index
            end

            it 'permits :information' do
              expect(described_class.new(self.send(current_user), app_being_checked)).to permit_action :information
            end

            describe 'permits changes (:edit, :update) when application is not approved or rejected' do

              it 'application is new' do
                expect(described_class.new(self.send(current_user), app_being_checked)).to permit_edit_and_update_actions
              end

              it 'application is under_review' do
                app_being_checked.start_review
                expect(described_class.new(self.send(current_user), app_being_checked)).to permit_edit_and_update_actions
              end

              it 'application is waiting_for_applicant' do
                app_being_checked.start_review
                app_being_checked.ask_applicant_for_info
                expect(described_class.new(self.send(current_user), app_being_checked)).to permit_edit_and_update_actions
              end

              it 'application is ready_for_review' do
                app_being_checked.start_review
                app_being_checked.ask_applicant_for_info
                app_being_checked.is_ready_for_review
                expect(described_class.new(self.send(current_user), app_being_checked)).to permit_edit_and_update_actions
              end

            end

            it 'forbids edit and update for an approved application' do

              app_being_checked.start_review
              app_being_checked.accept
              expect(described_class.new(self.send(current_user), app_being_checked)).to forbid_edit_and_update_actions
            end

            it 'forbids edit and update for a rejected application' do
              app_being_checked.start_review
              app_being_checked.reject
              expect(described_class.new(self.send(current_user), app_being_checked)).to forbid_edit_and_update_actions
            end

            it 'forbids destroy' do
              expect(described_class.new(self.send(current_user), app_being_checked)).to forbid_action :destroy
            end

            it "forbids all application state change actions (#{user_class} cannot change the app state)" do
              expect(described_class.new(self.send(current_user), app_being_checked)).to forbid_actions APP_STATE_CHANGE_ACTIONS
            end

          end

        end
      end

    end


    describe 'For Member that is the owner of an *approved* SHFApplication' do
      let(:application) do
        member_applicant.shf_application.update(state: :accepted)
        member_applicant.shf_application
      end

      subject { described_class.new(member_applicant, application) }

      it 'forbids new for a new application (not already instantiated)' do
        expect(described_class.new(member_applicant, ShfApplication)).to forbid_action :new
      end

      it 'forbids new for an existing application (already instantiated)' do
        is_expected.to forbid_action :new
      end

      it 'forbids create for a new application (not already instantiated)' do
        expect(described_class.new(member_applicant, ShfApplication)).to forbid_action :create
      end

      it 'permits create for an existing application (already instantiated)' do
        is_expected.to permit_action :create
      end

      it 'permits show' do
        is_expected.to permit_action :show
      end

      it 'forbids changing or deleting the application [:edit, :update, :destroy]' do
        is_expected.to forbid_actions [:edit, :update, :destroy]
      end

      it 'forbids index' do
        is_expected.to forbid_action :index
      end

      it 'permits :information' do
        is_expected.to permit_action :information
      end

      it 'forbids all application state change actions' do
        is_expected.to forbid_actions APP_STATE_CHANGE_ACTIONS
      end

    end


    describe 'For Admins' do
      subject { described_class.new(admin, application) }

      it 'forbids new (not already instantiated)' do
        is_expected.to forbid_action :new
      end

      it 'forbids create (already instantiated)' do
        is_expected.to forbid_action :create
      end

      describe 'permits all CRUD actions except :new and :create' do
        (SHFAPP_CRUD_ACTIONS - [:new, :create]).each do |action|
          it "permits #{action}" do
            is_expected.to permit_action action
          end
        end
      end

      it 'permits index' do
        is_expected.to permit_action :index
      end

      it 'permits information' do
        is_expected.to permit_action :information
      end

      describe 'permits all application state change actions' do
        APP_STATE_CHANGE_ACTIONS.each do |state_change|
          it "permits #{state_change}" do
            is_expected.to permit_action state_change
          end
        end
      end
    end


  end

end
