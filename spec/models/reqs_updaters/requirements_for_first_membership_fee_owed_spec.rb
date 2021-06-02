require 'rails_helper'

RSpec.describe RequirementsForFirstMembershipFeeOwed, type: :model do

  let(:subject) { RequirementsForFirstMembershipFeeOwed }

  let(:user) { create(:user) }


  describe '.has_expected_arguments?' do

    it 'args has expected :user key' do
      expect(subject.has_expected_arguments?({ user: 'some user' })).to be_truthy
    end

    it 'args does not have expected :user key' do
      expect(subject.has_expected_arguments?({ not_user: 'not some user' })).to be_falsey
    end

    it 'args is nil' do
      expect(subject.has_expected_arguments?(nil)).to be_falsey
    end
  end


  describe '.requirements_met?' do

    describe 'false: not met' do

      it 'no approved application' do
        shf_app = create(:shf_application)
        user = shf_app.user
        expect(subject.requirements_met?({ user: user })).to be_falsey
      end

      it 'membership term is current' do
        current_member = create(:member_with_membership_app)
        start_date = Time.zone.today
        create(:membership_fee_payment,
               :successful,
               user: current_member,
               start_date: start_date,
               expire_date: User.expire_date_for_start_date(start_date))

        expect(subject.requirements_met?({ user: current_member })).to be_falsey
      end

      it 'membership term has expired and application was approved before the last membership payment made' do

        start_date_last_year = Time.zone.today - 1.year - 1.month
        past_member = create(:member, first_day: start_date_last_year)
        past_member.shf_application.when_approved = start_date_last_year

        create(:membership_fee_payment,
               :successful,
               user: past_member,
               start_date: start_date_last_year,
               expire_date: User.expire_date_for_start_date(start_date_last_year))

        expect(past_member.payments_current?).to be_falsey
        expect(subject.requirements_met?({ user: past_member })).to be_falsey
      end
    end


    describe 'true: requirement met' do

      let(:user_with_approved_app) do
        shf_app = create(:shf_application, :accepted)
        u = shf_app.user
        faux_co = create(:company)
        create(:h_branding_fee_payment, user: u, company: faux_co) # having a H-Branding fee payment shouldn't matter
        u
      end

      it 'has an approved application but has no membership fee payments' do
        expect(subject.requirements_met?({ user: user_with_approved_app })).to be_truthy
      end


      it 'has an application approved after previous membership term has expired AND membership fee paid' do
        expire_date_last_month = Time.zone.today - 1.month
        create(:membership_fee_payment,
               :successful,
               user: user_with_approved_app,
               start_date: User.start_date_for_expire_date(expire_date_last_month),
               expire_date: expire_date_last_month)

        expect(subject.requirements_met?({ user: user_with_approved_app })).to be_truthy
      end
    end

  end

end
