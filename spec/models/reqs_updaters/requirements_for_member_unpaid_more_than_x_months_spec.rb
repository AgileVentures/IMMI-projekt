require 'rails_helper'

RSpec.describe RequirementsForMemberUnpaidMoreThanXMonths, type: :model do

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

  let(:subject) { RequirementsForMemberUnpaidMoreThanXMonths }

  let(:user) { create(:user) }

  let(:member) { create(:member_with_membership_app) }

  let(:member_payment_exp_over_5_months_ago) do
    exp_date = Time.zone.now.months_ago(5).to_date
    exp_date = exp_date - 1    # make this 1 day earlier; = 5 months and 1 day ago
    create(:membership_fee_payment,
           :successful,
           user:        member,
           start_date:  User.start_date_for_expire_date(exp_date),
           expire_date: exp_date )

  end


  describe '.has_expected_arguments?' do

    it 'args has expected :user and :num_months keys' do
      expect(subject.has_expected_arguments?({ user: 'some user', num_months: 5 })).to be_truthy
    end

    it 'args does not have expected :user key' do
      expect(subject.has_expected_arguments?({ not_user: 'not some user' })).to be_falsey
    end

    it 'args does not have expected :num_months key' do
      expect(subject.has_expected_arguments?({})).to be_falsey
    end

    it 'args is nil' do
      expect(subject.has_expected_arguments?(nil)).to be_falsey
    end
  end


  describe '.requirements_met?' do

    it 'false if it does not meet the RequirementsForMembershipLapsed' do
      expect(RequirementsForMembershipLapsed).to receive(:requirements_met?).and_return(false)
      expect(subject.requirements_met?({ user: create(:user), num_months: 5 })).to be_falsey
    end

    context 'meets the RequirementsForMembershipLapsed' do
      before(:each) { expect(RequirementsForMembershipLapsed).to receive(:requirements_met?).and_return(true) }

      it 'true if today is more than num months from the last day of the membership' do
        former_member = create(:member, membership_status: :former_member, member: false,
               last_day: Date.current - 5.months - 1.day)
        expect(subject.requirements_met?({ user: former_member, num_months: 5 })).to be_truthy
      end

      it 'false if today == num months from the last day of the membership' do
        former_member = create(:member, membership_status: :former_member, member: false,
                               last_day: Date.current - 5.months)
        expect(subject.requirements_met?({ user: former_member, num_months: 5 })).to be_falsey
      end

      it 'false if today is less than the num months from the last day of the membership' do
        former_member = create(:member, membership_status: :former_member, member: false,
                               last_day: Date.current - 5.months + 1.day)
        expect(subject.requirements_met?({ user: former_member, num_months: 5 })).to be_falsey
      end
    end

  end

end
