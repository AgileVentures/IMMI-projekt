require 'rails_helper'

RSpec.describe RequirementsForMembershipLapsed, type: :model do

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


  let(:feb1_2018) { Date.new(2018, 2, 1) }
  let(:jun1_2018) { Date.new(2018, 6, 1) }

  let(:subject) { RequirementsForMembershipLapsed }

  let(:user) { create(:user) }

  let(:member) { create(:member) }

  let(:member_with_expired_payment) do
    start_date = Time.zone.today - 1.year - 1.month
    create(:membership_fee_payment,
           :successful,
           user:        member,
           start_date:  start_date,
           expire_date: User.expire_date_for_start_date(start_date) )
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

    it 'true if in the grace period' do
      grace_period_member = create(:member, last_day: Date.current - 5.days,
                                   membership_status: :in_grace_period,
                                   member: false,)
      expect(subject.requirements_met?(user: grace_period_member)).to be_truthy
    end


    it 'true if a former member' do
      former_member = create(:member, last_day: Date.current - 500.days,
                                   membership_status: :former_member,
                                   member: false,)
      expect(subject.requirements_met?(user: former_member)).to be_truthy
    end


    describe 'false for any other membership status' do

      it 'current member' do
        expect(subject.requirements_met?(user: create(:member))).to be_falsey
      end

      it 'not a member' do
        expect(subject.requirements_met?(user: create(:user))).to be_falsey
      end

      other_membership_statuses = User.membership_statuses - [:current_member, :not_a_member, :in_grace_period, :former_member]
      other_membership_statuses.each do |other_status|
        it "#{other_status} is false" do
          expect(subject.requirements_met?(user: create(:user, membership_status: other_status))).to be_falsey
        end
      end

    end

  end
end
