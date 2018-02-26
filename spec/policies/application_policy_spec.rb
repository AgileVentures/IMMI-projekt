require 'rails_helper'

RSpec.describe ApplicationPolicy do


  # Have to use a child class for the record.
  # BusinessCategories are small and simple and used when ownership is not being tested
  # ShfApplications can be created by both Members and users.
  #    These are used when ownership is part of the test

  describe 'CRUD actions (default policies for the application)' do

    let(:admin) { create(:user, email: 'admin@shf.se', admin: true) }

    let(:member_not_owner) { create(:member_with_membership_app, email: 'member_not_owner@random.com') }
    let(:member_owner) { create(:member_with_membership_app, email: 'member_owner@random.com') }


    let(:user_not_owner) { create(:user, email: 'user_not_owner@random.com') }
    let(:user_owner) { create(:user_with_membership_app, email: 'user_owner@random.com') }


    let(:visitor) { build(:visitor) }


    let(:business_cat) { BusinessCategory.new }


    describe 'new' do
      let(:action_tested) { :new }

      describe 'For admins' do
        it 'permitted if the record is a Class (not an already instantiated object)' do
          expect(described_class.new(admin, ShfApplication)).to permit_action action_tested
        end

        it 'forbidden if the record is an instantianted object' do
          expect(described_class.new(admin, business_cat)).to forbid_action action_tested
        end
      end

      describe 'Member that owns the record' do
        it 'forbidden if the record is an instantianted object' do
          expect(described_class.new(member_owner, member_owner.shf_application)).to forbid_action action_tested
        end
      end

      describe 'Member that is not the record owner' do
        it 'permitted if the record is a Class (not an already instantiated object)' do
          expect(described_class.new(member_not_owner, BusinessCategory)).to permit_action action_tested
        end

        it 'forbidden if the record is an instantianted object' do
          expect(described_class.new(member_not_owner, business_cat)).to forbid_action action_tested
        end
      end

      describe 'User that is not the record owner' do
        it 'permitted if the record is a Class (not an already instantiated object)' do
          expect(described_class.new(member_not_owner, BusinessCategory)).to permit_action action_tested
        end

        it 'forbidden if the record is an instantianted object' do
          expect(described_class.new(member_not_owner, business_cat)).to forbid_action action_tested
        end
      end

      describe 'User that owns the record' do
        it 'forbidden if the record is an instantianted object' do
          expect(described_class.new(user_owner, user_owner.shf_application)).to forbid_action action_tested
        end
      end

      describe 'Visitor' do
        it 'permitted if the record is a Class (not an already instantiated object)' do
          expect(described_class.new(visitor, BusinessCategory)).to permit_action action_tested
        end

        it 'forbidden if the record is an instantianted object' do
          expect(described_class.new(visitor, business_cat)).to forbid_action action_tested
        end
      end
    end


    describe 'create' do
      let(:action_tested) { :create }

      it 'permitted for Admins' do
        expect(described_class.new(admin, business_cat)).to permit_action action_tested
      end

      it 'permitted for Member that owns the record' do
          expect(described_class.new(member_owner, member_owner.shf_application)).to permit_action action_tested
      end

      it 'forbidden for Member that is not the record owner' do
          expect(described_class.new(member_not_owner, business_cat)).to forbid_action action_tested
      end

      it 'permitted for User that owns the record' do
        expect(described_class.new(user_owner, user_owner.shf_application)).to permit_action action_tested
      end

      it 'forbidden for User that is not the record owner' do
        expect(described_class.new(user_not_owner, business_cat)).to forbid_action action_tested
      end

      it 'forbidden for Visitors' do
        expect(described_class.new(visitor, business_cat)).to forbid_action action_tested
      end

    end

    describe 'index' do
      let(:action_tested) { :index }

      it 'permitted for Admins' do
        expect(described_class.new(admin, BusinessCategory)).to permit_action action_tested
      end

      it 'forbidden for Members' do
        expect(described_class.new(member_owner, BusinessCategory)).to forbid_action action_tested
      end

      it 'forbidden for Users' do
        expect(described_class.new(user_owner, BusinessCategory)).to forbid_action action_tested
      end

      it 'forbidden for Visitors' do
        expect(described_class.new(visitor, BusinessCategory)).to forbid_action action_tested
      end

    end


    describe 'show' do
      let(:action_tested) { :show }

      it 'permitted for Admins' do
        expect(described_class.new(admin, business_cat)).to permit_action action_tested
      end

      it 'permitted for Member that owns the record' do
        expect(described_class.new(member_owner, member_owner.shf_application)).to permit_action action_tested
      end

      it 'forbidden for Member that is not the record owner' do
        expect(described_class.new(member_not_owner, business_cat)).to forbid_action action_tested
      end

      it 'permitted for User that owns the record' do
        expect(described_class.new(user_owner, user_owner.shf_application)).to permit_action action_tested
      end

      it 'forbidden for User that is not the record owner' do
        expect(described_class.new(user_not_owner, business_cat)).to forbid_action action_tested
      end

      it 'forbidden for Visitors' do
        expect(described_class.new(visitor, business_cat)).to forbid_action action_tested
      end

    end


    describe 'edit' do
      let(:action_tested) { :edit }

      it 'permitted for Admins' do
        expect(described_class.new(admin, business_cat)).to permit_action action_tested
      end

      it 'permitted for Member that owns the record' do
        expect(described_class.new(member_owner, member_owner.shf_application)).to permit_action action_tested
      end

      it 'forbidden for Member that is not the record owner' do
        expect(described_class.new(member_not_owner, business_cat)).to forbid_action action_tested
      end

      it 'permitted for User that owns the record' do
        expect(described_class.new(user_owner, user_owner.shf_application)).to permit_action action_tested
      end

      it 'forbidden for User that is not the record owner' do
        expect(described_class.new(user_not_owner, business_cat)).to forbid_action action_tested
      end

      it 'forbidden for Visitors' do
        expect(described_class.new(visitor, BusinessCategory)).to forbid_action action_tested
      end

    end


    describe 'update' do
      let(:action_tested) { :update }

      it 'permitted for Admins' do
        expect(described_class.new(admin, business_cat)).to permit_action action_tested
      end

      it 'permitted for Member that owns the record' do
        expect(described_class.new(member_owner, member_owner.shf_application)).to permit_action action_tested
      end

      it 'forbidden for Member that is not the record owner' do
        expect(described_class.new(member_not_owner, business_cat)).to forbid_action action_tested
      end

      it 'permitted for User that owns the record' do
        expect(described_class.new(user_owner, user_owner.shf_application)).to permit_action action_tested
      end

      it 'forbidden for User that is not the record owner' do
        expect(described_class.new(user_not_owner, business_cat)).to forbid_action action_tested
      end

      it 'forbidden for Visitors' do
        expect(described_class.new(visitor, business_cat)).to forbid_action action_tested
      end

    end


    describe 'destroy' do
      let(:action_tested) { :destroy }

      it 'permitted for Admins' do
        expect(described_class.new(admin, business_cat)).to permit_action action_tested
      end

      it 'forbidden for Member that owns the record' do
        expect(described_class.new(member_owner, member_owner.shf_application)).to forbid_action action_tested
      end

      it 'forbidden for Member that is not the record owner' do
        expect(described_class.new(member_not_owner, business_cat)).to forbid_action action_tested
      end

      it 'forbidden for User that owns the record' do
        expect(described_class.new(user_owner, user_owner.shf_application)).to forbid_action action_tested
      end

      it 'forbidden for User that is not the record owner' do
        expect(described_class.new(user_not_owner, business_cat)).to forbid_action action_tested
      end

      it 'forbidden for Visitors' do
        expect(described_class.new(visitor, business_cat)).to forbid_action action_tested
      end

    end

  end


end
