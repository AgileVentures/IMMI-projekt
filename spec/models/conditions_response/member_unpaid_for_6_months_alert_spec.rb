require 'rails_helper'


RSpec.describe MemberUnpaidFor6MonthsAlert, type: :model do

  let(:subject) { described_class.instance }

  let(:admin1) { create(:admin) }
  let(:user)   { create(:user)  }

  let(:config) {  { on_month_day: 12 } }
  let(:timing) { MembershipLapsedAlert::TIMING_AFTER }
  let(:condition) { create(:condition, timing: timing, config: config ) }


  describe '.add_entity_to_list?(user) if the RequirementsForMemberUnpaidForXMonths is met' do
   
    it 'RequirementsForMemberUnpaidForXMonths is not satisfied' do

      allow(RequirementsForMemberUnpaidForXMonths).to receive(:requirements_met?).and_return(false)

      expect(subject.add_entity_to_list?(user)).to be_falsey
    end


    it 'RequirementsForMemberUnpaidForXMonths is satisfied' do

      allow(RequirementsForMemberUnpaidForXMonths).to receive(:requirements_met?).and_return(true)

      expect(subject.add_entity_to_list?(user)).to be_truthy
    end
    
  end
  

  it '.mailer_method' do
    expect(subject.mailer_method).to eq :member_unpaid_for_x_months
  end


  it '.mailer_args for an admin returns [admin, entities_list, num_months]' do

    member = create(:member_with_membership_app)

    exp_date = Time.zone.now.months_ago(6).to_date

    allow(subject).to receive(:entities_list).and_return([member])

    expect(subject.mailer_args(admin1)).to match_array([admin1, [member], 6])
  end
end