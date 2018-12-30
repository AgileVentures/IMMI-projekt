require 'rails_helper'

RSpec.describe RequirementsForMembership, type: :model do

  let(:subject) { RequirementsForMembership }


  let(:user) { create(:user) }

  let(:member) { create(:member_with_membership_app) }

  let(:member_expired_payment) do
    create(:membership_fee_payment,
           :successful,
           user: member,
           start_date: Time.zone.today - 1.year - 1.month,
           expire_date: Time.zone.today - 1.year)
  end

  let(:member_current_payment) do
    start_date, expire_date = User.next_membership_payment_dates(member.id)
    create(:membership_fee_payment,
           :successful,
           user: member,
           start_date: start_date,
           expire_date: expire_date)
  end


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

    context 'does not meet membership requirements' do

      it 'user does not have an approved application (does have a payment and membership term has not expired)' do

        start_date, expire_date = User.next_membership_payment_dates(user.id)
        create(:membership_fee_payment,
               :successful,
               user: user,
               start_date: start_date,
               expire_date: expire_date)

        expect(subject.requirements_met?({ user: user })).to be_falsey
      end

      it 'membership term has expired (does have an approved application and does have a payment for membership fee)' do
        member_expired_payment
        expect(subject.requirements_met?({ user: member })).to be_falsey
      end

      it 'has an approved application but has not paid the membership fee' do
        user_with_approved_app = create(:user_with_membership_app)
        shf_app = user_with_approved_app.shf_application
        shf_app.start_review
        shf_app.accept!
        expect(subject.requirements_met?({ user: user_with_approved_app }))
      end

    end


    context 'meets the membership requirements' do

      it 'has an approved application AND membership fee paid AND membership term has not expired' do
        member_current_payment
        expect(subject.requirements_met?({ user: member })).to be_truthy
      end

    end

  end


  describe '.satisfied?' do

    it '.has_expected_arguments? is true and requirements_met? is true' do
      member_current_payment
      expect(subject.satisfied?({ user: member })).to be_truthy
    end

    it '.has_expected_arguments? is true and requirements_met? is false' do
      expect(subject.satisfied?({ user: user })).to be_falsey
    end

    it '.has_expected_arguments? is false and requirements_met? is true' do
      member_current_payment
      expect(subject.satisfied?({ not_user: member })).to be_falsey
    end

    it '.has_expected_arguments? is false and requirements_met? is false' do
      expect(subject.satisfied?({ not_user: user })).to be_falsey
    end

  end

end
