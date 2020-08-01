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

    context 'false: not met' do

      it 'no approved application' do
        app  = create(:shf_application)
        user = app.user
        expect(subject.requirements_met?({ user: user, num_months: 5 })).to be_falsey
      end

      it 'has an approved application but has not paid the membership fee' do
        user_with_approved_app = create(:user_with_membership_app)
        shf_app                = user_with_approved_app.shf_application
        shf_app.start_review
        shf_app.accept!
        expect(subject.requirements_met?({ user: user_with_approved_app, num_months: 5 })).to be_falsey
      end

      it 'membership payment made but not yet expired' do
        create(:membership_fee_payment,
                         :successful,
                         user:        member,
                         start_date:  feb1_2018,
                         expire_date: User.expire_date_for_start_date(feb1_2018))

        Timecop.freeze(jun1_2018) do
          expect(subject.requirements_met?({ user: member, num_months: 5 })).to be_falsey
        end
      end

      it 'membership expired but not num_months ago' do
        expected_num_months = 5

        expired_num_months_plus1 = Time.zone.now.months_ago(expected_num_months + 1).to_date

        create(:membership_fee_payment,
               :successful,
               user:        member,
               start_date:  (expired_num_months_plus1 - 364),
               expire_date: expired_num_months_plus1)

        Timecop.freeze(jun1_2018) do
          expect(subject.requirements_met?({ user: member, num_months: expected_num_months })).to be_falsey
        end
      end

    end


    context 'true: expired num_months ago' do

      it 'has an approved application AND membership fee paid AND membership term has expired' do

        member_payment_exp_over_5_months_ago
        expect(subject.requirements_met?({ user: member, num_months: 5 })).to be_truthy
      end

    end

  end


  describe '.satisfied?' do

    it '.has_expected_arguments? is true and requirements_met? is true' do
      member_payment_exp_over_5_months_ago
      expect(subject.satisfied?({ user: member, num_months: 5 })).to be_truthy
    end

    it '.has_expected_arguments? is true and requirements_met? is false' do
      expect(subject.satisfied?({ user: user, num_months: 5 })).to be_falsey
    end

    it '.has_expected_arguments? is false and requirements_met? is true' do
      member_payment_exp_over_5_months_ago
      expect(subject.satisfied?({ not_user: member, blorf: 'florb' })).to be_falsey
    end

    it '.has_expected_arguments? is false and requirements_met? is false' do
      expect(subject.satisfied?({ not_user: user })).to be_falsey
    end

  end

end
