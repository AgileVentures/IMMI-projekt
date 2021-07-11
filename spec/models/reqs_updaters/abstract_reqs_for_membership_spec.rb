require 'rails_helper'

RSpec.describe AbstractReqsForMembership, type: :model do

  before(:each) do
    # stub this so we don't have to create the MasterChecklist for the Member Guidelines checklist
    # if a ShfApplication is accepted.
    allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for).and_return(true)
  end

  let(:subject) { AbstractReqsForMembership }
  let(:user) { build(:user) }
  let(:yesterday) { Date.current - 1.day }
  let(:jan_1) { Date.new(2017, 1, 1) }

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


  describe '.requirements_excluding_payments_met?' do

    it 'subclasses must define this; raises NoMethodError' do
      expect { subject.requirements_excluding_payments_met?({ }) }.to raise_error NoMethodError
    end
  end

  describe '.requirements_met?' do

    it 'for a specific date: passes that date to the methods called' do
      expect(subject).to receive(:requirements_excluding_payments_met?)
                           .with(user, yesterday)
                           .and_return(true)
      expect(subject).to receive(:payment_requirements_met?)
                           .with(user, yesterday)
                           .and_return(true)
      expect(subject.requirements_met?(user: user, date: yesterday)).to be_truthy
    end

    it 'all non-payment requirements && all payment requirements' do
      expect(subject).to receive(:requirements_excluding_payments_met?).with(user, anything)
                                                                       .and_return(true)
      expect(subject).to receive(:payment_requirements_met?).with(user, anything)
                                                            .and_return(true)
      expect(subject.requirements_met?(user: user)).to be_truthy
    end
  end

  describe '.payment_requirements_met?' do

    it 'result = user.payments_current_as_of?' do
      u = build(:user)
      expect(u).to receive(:payments_current_as_of?).and_return(true)
      expect(subject.payment_requirements_met?(u)).to be_truthy

      expect(u).to receive(:payments_current_as_of?).and_return(false)
      expect(subject.payment_requirements_met?(u)).to be_falsey
    end

    it 'for a specific date: it passes that date to payments_current_as_of?' do
      u = build(:user)
      expect(u).to receive(:payments_current_as_of?)
                     .with(yesterday).and_return(true)
      expect(subject.payment_requirements_met?(u, yesterday)).to be_truthy
      expect(u).to receive(:payments_current_as_of?)
                     .with(yesterday).and_return(false)
      expect(subject.payment_requirements_met?(u, yesterday)).to be_falsey
    end
  end

  describe '.membership_guidelines_checklist_done?' do
    it 'calls UserChecklistManager to see if the user has completed the Ethical guidelines checklist' do
      expect(UserChecklistManager).to receive(:completed_membership_guidelines_checklist?)
                                        .with(user)
      subject.membership_guidelines_checklist_done?(user)
    end
  end
end
