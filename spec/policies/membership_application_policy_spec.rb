require 'rails_helper'


describe MembershipApplicationPolicy do


  describe 'policy for the state attribute' do

    let(:application_owner) { create(:user, email: 'owner@random.com') }
    let(:admin) { create(:user, email: 'admin@sgf.com', admin: true) }
    let(:not_the_owner) { create(:user, email: 'user_2@random.com') }

    let(:application) { create(:membership_application,
                               user: application_owner,
                               state: :under_review)    }


    describe 'For the MembershipApplication creator' do

      subject { described_class.new(application_owner, application) }

      it 'permits show' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:show)
      end

      it 'permits create' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:create)
      end

      it 'permits edit when not accepted or rejected' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:edit)
      end

      it 'forbids edit when accepted' do
        application.accept
        is_expected.to forbid_mass_assignment_of(:state).for_action(:edit)
      end

      it 'forbids edit when rejected' do
        application.reject
        is_expected.to forbid_mass_assignment_of(:state).for_action(:edit)
      end

      it 'permits update when not accepted or rejected' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:update)
      end

      it 'forbids update when accepted' do
        application.accept
        is_expected.to forbid_mass_assignment_of(:state).for_action(:update)
      end

      it 'forbids update when rejected' do
        application.reject
        is_expected.to forbid_mass_assignment_of(:state).for_action(:update)
      end

      it 'forbids destroy' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:destroy)
      end

    end


    describe 'for user not the owner' do
      subject { described_class.new(not_the_owner, application) }

      it 'permits show' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:show)
      end

      it 'forbids create' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:create)
      end

      it 'forbids edit' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:edit)
      end

      it 'forbids update' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:update)
      end

      it 'forbids destroy' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:destroy)
      end
    end


    describe 'for a visitor' do
      subject { described_class.new(Visitor.new, application) }

      it 'forbits create' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:create)
      end

      it 'forbids edit' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:edit)
      end
      it 'forbids update' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:update)
      end
      it 'forbids destroy' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:destroy)
      end

      it 'forbids see (show)' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:show)
      end
    end

    describe 'For admins' do
      subject { described_class.new(admin, application) }

      it 'permits show the state' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:show)
      end

      it 'permits create a state' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:create)
      end

      it 'permits do all actions with #state' do
        is_expected.to permit_mass_assignment_of(:state)
      end

      it 'permits edit the state' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:edit)
      end

      it 'permits update the state' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:update)
      end

      it 'permits destroy the state' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:destroy)
      end
    end

  end


  describe 'actions on the membership application' do

    let(:user_1) { create(:user, email: 'user_1@random.com') }
    let(:user_2) { create(:user, email: 'user_2@random.com') }
    let(:admin)  { create(:user, email: 'admin@sgf.com', admin: true) }
    let(:visitor) { build(:visitor) }
    let(:application) { create(:membership_application,
                               user: user_1,
                               state: :under_review) }

    describe 'For visitors (not logged in)' do
      subject { described_class.new(visitor, application) }

      it 'forbids new' do
        is_expected.to forbid_action :new
      end
      it 'forbids create' do
        is_expected.to forbid_action :create
      end

      it 'forbids show' do
        is_expected.to forbid_action :show
      end
      it 'forbids index' do
        is_expected.to forbid_action :index
      end

      it 'forbids edit' do
        is_expected.to forbid_action :edit
      end
      it 'forbids update' do
        is_expected.to forbid_action :update
      end

      it 'forbids destroy' do
        is_expected.to forbid_action :destroy
      end

      it 'forbids information' do
        is_expected.to forbid_action :information
      end

      it 'forbids accept' do
        is_expected.to forbid_action :accept
      end
      it 'forbids reject' do
        is_expected.to forbid_action :reject
      end
      it 'forbids need_info' do
        is_expected.to forbid_action :need_info
      end
      it 'forbids cancel_need_info' do
        is_expected.to forbid_action :cancel_need_info
      end
    end

    describe 'For other users of MembershipApplication' do
      subject { described_class.new(user_2, application) }

      it 'forbids new' do
        is_expected.to forbid_action :new
      end
      it 'forbids create' do
        is_expected.to forbid_action :create
      end

      it 'forbids show' do
        is_expected.to forbid_action :show
      end
      it 'forbids index' do
        is_expected.to forbid_action :index
      end

      it 'forbids edit' do
        is_expected.to forbid_action :edit
      end
      it 'forbids update' do
        is_expected.to forbid_action :update
      end

      it 'forbids destroy' do
        is_expected.to forbid_action :destroy
      end

      it 'forbids accept' do
        is_expected.to forbid_action :accept
      end
      it 'forbids reject' do
        is_expected.to forbid_action :reject
      end
      it 'forbids need_info' do
        is_expected.to forbid_action :need_info
      end
      it 'forbids cancel_need_info' do
        is_expected.to forbid_action :cancel_need_info
      end
    end

    describe 'For Creator of MembershipApplication' do
      subject { described_class.new(user_1, application) }

      it 'forbids new' do
        is_expected.to forbid_action :new
      end
      it 'forbids create' do
        is_expected.to forbid_action :create
      end

      it 'permits show' do
        is_expected.to permit_action :show
      end
      it 'forbids index' do
        is_expected.to forbid_action :index
      end

      it 'permits edit when not accepted or rejected' do
        is_expected.to permit_action :edit
      end

      it 'forbids edit for accepted' do
        application.accept
        is_expected.to forbid_action :edit
      end

      it 'forbids edit for rejected' do
        application.reject
        is_expected.to forbid_action :edit
      end

      it 'permits update when not accepted or rejected' do
        is_expected.to permit_action :update
      end

      it 'forbids update for accepted' do
        application.accept
        is_expected.to forbid_action :update
      end

      it 'forbids update for rejected' do
        application.reject
        is_expected.to forbid_action :update
      end

      it 'forbids destroy' do
        is_expected.to forbid_action :destroy
      end

      it 'forbids accept' do
        is_expected.to forbid_action :accept
      end
      it 'forbids reject' do
        is_expected.to forbid_action :reject
      end
      it 'forbids need_info' do
        is_expected.to forbid_action :need_info
      end
      it 'forbids cancel_need_info' do
        is_expected.to forbid_action :cancel_need_info
      end
    end


    describe 'For admins' do
      subject { described_class.new(admin, application) }

      it 'permits new' do
        is_expected.to permit_action :new
      end
      it 'permits create' do
        is_expected.to permit_action :create
      end

      it 'permits show' do
        is_expected.to permit_action :show
      end
      it 'permits index' do
        is_expected.to permit_action :index
      end

      it 'permits edit' do
        is_expected.to permit_action :edit
      end
      it 'permits update' do
        is_expected.to permit_action :update
      end

      it 'permits destroy' do
        is_expected.to permit_action :destroy
      end

      it 'permits accept' do
        is_expected.to permit_action :accept
      end
      it 'permits reject' do
        is_expected.to permit_action :reject
      end
      it 'permits need_info' do
        is_expected.to permit_action :need_info
      end
      it 'permits cancel_need_info' do
        is_expected.to permit_action :cancel_need_info
      end

    end
  end

end
