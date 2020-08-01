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

  let(:member) { create(:member_with_membership_app) }

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

    context 'false: not met' do

      it 'no approved application' do
        app  = create(:shf_application)
        user = app.user
        expect(subject.requirements_met?({ user: user })).to be_falsey
      end

      it 'has an approved application but has not paid the membership fee' do
        user_with_approved_app = create(:user_with_membership_app)
        shf_app                = user_with_approved_app.shf_application
        shf_app.start_review
        shf_app.accept!
        expect(subject.requirements_met?({ user: user_with_approved_app })).to be_falsey
      end

      it 'membership payment made but not yet expired' do
        create(:membership_fee_payment,
                         :successful,
                         user:        member,
                         start_date:  feb1_2018,
                         expire_date: User.expire_date_for_start_date(feb1_2018))

        Timecop.freeze(jun1_2018) do
          expect(subject.requirements_met?({ user: member })).to be_falsey
        end
      end

    end


    context 'true: has lapsed' do

      it 'has an approved application AND membership fee paid AND membership term has expired' do
        member_with_expired_payment
        expect(subject.requirements_met?({ user: member })).to be_truthy
      end

    end

  end


  describe '.satisfied?' do

    it '.has_expected_arguments? is true and requirements_met? is true' do
      member_with_expired_payment
      expect(subject.satisfied?({ user: member })).to be_truthy
    end

    it '.has_expected_arguments? is true and requirements_met? is false' do
      expect(subject.satisfied?({ user: user })).to be_falsey
    end

    it '.has_expected_arguments? is false and requirements_met? is true' do
      member_with_expired_payment
      expect(subject.satisfied?({ not_user: member })).to be_falsey
    end

    it '.has_expected_arguments? is false and requirements_met? is false' do
      expect(subject.satisfied?({ not_user: user })).to be_falsey
    end

  end

end
