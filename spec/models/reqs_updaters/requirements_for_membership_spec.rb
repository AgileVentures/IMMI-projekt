require 'rails_helper'

RSpec.describe RequirementsForMembership, type: :model do

  before(:each) do
    # stub this so we don't have to create the MasterChecklist for the Member Guidelines checklist
    # if a ShfApplication is accepted.
    allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for).and_return(true)
  end


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

    context 'has approved application' do

      let(:approved_applicant) do
        approved_app = create(:shf_application, :accepted)
        approved_app.user
      end


      context 'membership guidelines are required' do
        before(:each) { allow(UserChecklistManager).to receive(:membership_guidelines_reqd_start_date).and_return(Time.zone.now - 1.year) }

        context 'membership guidelines ARE agreed to' do

          it 'true if membership payment made (and it has not expired)' do
            allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(true)
            allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?).and_return(true)

            another_approved_app = create(:shf_application, :accepted)
            approved_and_paid = another_approved_app.user

            start_date, expire_date = User.next_membership_payment_dates(approved_and_paid.id)
            create(:membership_fee_payment,
                   :successful,
                   user: approved_and_paid,
                   start_date: start_date,
                   expire_date: expire_date)

            expect(subject.requirements_met?({ user: approved_and_paid })).to be_truthy
          end

          it 'false if membership payment made and it HAS expired' do
            allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(true)
            allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?).and_return(true)

            another_approved_app = create(:shf_application, :accepted)
            approved_and_paid = another_approved_app.user

            start_date, expire_date = User.next_membership_payment_dates(approved_and_paid.id)
            create(:membership_fee_payment,
                   :successful,
                   user: approved_and_paid,
                   start_date: start_date,
                   expire_date: expire_date)

            Timecop.freeze(expire_date + 1.day) do
              expect(subject.requirements_met?({ user: approved_and_paid })).to be_falsey
            end
          end

          it 'false if membership payment not made' do
            allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(true)
            allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?).and_return(true)

            expect(subject.requirements_met?({ user: approved_applicant })).to be_falsey
          end
        end

        context 'membership guidelines NOT agreed to' do

          it 'false if membership payment made AND it does not expire until AFTER the start of the membership guidelines requirements' do
            allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(true)
            allow(UserChecklistManager).to receive(:completed_membership_guidelines_checklist?).and_return(false)

            another_approved_app = create(:shf_application, :accepted)
            approved_and_paid = another_approved_app.user

            start_date, expire_date = User.next_membership_payment_dates(approved_and_paid.id)
            create(:membership_fee_payment,
                   :successful,
                   user: approved_and_paid,
                   start_date: start_date,
                   expire_date: expire_date)

            expect(subject.requirements_met?({ user: approved_and_paid })).to be_falsey
          end

          it 'false if membership payment made and it HAS expired' do
            allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(true)
            allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?).and_return(false)

            another_approved_app = create(:shf_application, :accepted)
            approved_and_paid = another_approved_app.user

            start_date, expire_date = User.next_membership_payment_dates(approved_and_paid.id)
            create(:membership_fee_payment,
                   :successful,
                   user: approved_and_paid,
                   start_date: start_date,
                   expire_date: expire_date)

            Timecop.freeze(expire_date + 1.day) do
              expect(subject.requirements_met?({ user: approved_and_paid })).to be_falsey
            end
          end

          it 'false if membership payment not made' do
            allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(true)
            allow(UserChecklistManager).to receive(:completed_membership_guidelines_checklist?).and_return(false)

            expect(subject.requirements_met?({ user: approved_applicant })).to be_falsey
          end
        end
      end


      context 'membership guidelines are NOT required' do
        before(:each) { allow(UserChecklistManager).to receive(:membership_guidelines_reqd_start_date).and_return(Time.zone.now + 1.year) }

        context 'membership guidelines ARE agreed to' do

          it 'true if membership payment made (and it has not expired)' do
            allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(false)
            allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?).and_return(true)

            another_approved_app = create(:shf_application, :accepted)
            approved_and_paid = another_approved_app.user

            start_date, expire_date = User.next_membership_payment_dates(approved_and_paid.id)
            create(:membership_fee_payment,
                   :successful,
                   user: approved_and_paid,
                   start_date: start_date,
                   expire_date: expire_date)

            expect(subject.requirements_met?({ user: approved_and_paid })).to be_truthy
          end

          it 'false if membership payment made and it HAS expired' do
            allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(false)
            allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?).and_return(true)

            another_approved_app = create(:shf_application, :accepted)
            approved_and_paid = another_approved_app.user

            start_date, expire_date = User.next_membership_payment_dates(approved_and_paid.id)
            create(:membership_fee_payment,
                   :successful,
                   user: approved_and_paid,
                   start_date: start_date,
                   expire_date: expire_date)

            Timecop.freeze(expire_date + 1.day) do
              expect(subject.requirements_met?({ user: approved_and_paid })).to be_falsey
            end
          end

          it 'false if membership payment not made' do
            allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(false)
            allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?).and_return(true)

            expect(subject.requirements_met?({ user: approved_applicant })).to be_falsey
          end
        end

        context 'membership guidelines NOT agreed to' do

          it 'true if membership payment (and it has not yet expired)' do
            allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(false)

            another_approved_app = create(:shf_application, :accepted)
            approved_and_paid = another_approved_app.user

            start_date, expire_date = User.next_membership_payment_dates(approved_and_paid.id)
            create(:membership_fee_payment,
                   :successful,
                   user: approved_and_paid,
                   start_date: start_date,
                   expire_date: expire_date)

            expect(subject.requirements_met?({ user: approved_and_paid })).to be_truthy
          end

          it 'false if membership payment made and it HAS expired' do
            allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(false)

            another_approved_app = create(:shf_application, :accepted)
            approved_and_paid = another_approved_app.user

            start_date, expire_date = User.next_membership_payment_dates(approved_and_paid.id)
            create(:membership_fee_payment,
                   :successful,
                   user: approved_and_paid,
                   start_date: start_date,
                   expire_date: expire_date)

            Timecop.freeze(expire_date + 1.day) do
              expect(subject.requirements_met?({ user: approved_and_paid })).to be_falsey
            end
          end

          it 'false if membership payment not made' do
            allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(false)

            expect(subject.requirements_met?({ user: approved_applicant })).to be_falsey
          end
        end
      end

    end

    context 'does not have an approved application: always false' do

      context 'membership guidelines are required' do

        context 'membership guidelines ARE agreed to' do

          ShfApplication.all_states.reject { |s| s == ShfApplication::STATE_ACCEPTED }.each do |app_state|

            context "app is #{app_state}" do

              it "false if membership payment made (and it has not expired)" do
                allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(true)
                allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?).and_return(true)

                unapproved_app = create(:shf_application, state: app_state)
                unapproved_user = unapproved_app.user
                start_date, expire_date = User.next_membership_payment_dates(unapproved_user.id)
                create(:membership_fee_payment,
                       :successful,
                       user: unapproved_user,
                       start_date: start_date,
                       expire_date: expire_date)

                expect(subject.requirements_met?({ user: unapproved_user })).to be_falsey
              end

              it "false if membership payment made and it HAS expired" do
                allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(true)
                allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?).and_return(true)

                unapproved_app = create(:shf_application, state: app_state)
                unapproved_and_paid = unapproved_app.user

                start_date, expire_date = User.next_membership_payment_dates(unapproved_and_paid.id)
                create(:membership_fee_payment,
                       :successful,
                       user: unapproved_and_paid,
                       start_date: start_date,
                       expire_date: expire_date)

                Timecop.freeze(expire_date + 1.day) do
                  expect(subject.requirements_met?({ user: unapproved_and_paid })).to be_falsey
                end
              end

              it "false if membership payment not made" do
                allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(true)
                allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?).and_return(true)

                unapproved_app = create(:shf_application, state: app_state)
                unapproved_applicant = unapproved_app.user
                expect(subject.requirements_met?({ user: unapproved_applicant })).to be_falsey
              end
            end
          end
        end

      end

      context 'membership guidelines are NOT required' do

        context 'membership guidelines ARE agreed to' do
          ShfApplication.all_states.reject { |s| s == ShfApplication::STATE_ACCEPTED }.each do |app_state|

            context "app is #{app_state}" do

              it "false if membership payment made (and it has not expired)" do
                allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(false)
                allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?).and_return(true)

                unapproved_app = create(:shf_application, state: app_state)
                unapproved_user = unapproved_app.user
                start_date, expire_date = User.next_membership_payment_dates(unapproved_user.id)
                create(:membership_fee_payment,
                       :successful,
                       user: unapproved_user,
                       start_date: start_date,
                       expire_date: expire_date)

                expect(subject.requirements_met?({ user: unapproved_user })).to be_falsey
              end

              it "false if membership payment made and it HAS expired" do
                allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(false)
                allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?).and_return(true)

                unapproved_app = create(:shf_application, state: app_state)
                unapproved_and_paid = unapproved_app.user

                start_date, expire_date = User.next_membership_payment_dates(unapproved_and_paid.id)
                create(:membership_fee_payment,
                       :successful,
                       user: unapproved_and_paid,
                       start_date: start_date,
                       expire_date: expire_date)

                Timecop.freeze(expire_date + 1.day) do
                  expect(subject.requirements_met?({ user: unapproved_and_paid })).to be_falsey
                end
              end

              it "false if membership payment not made" do
                allow(UserChecklistManager).to receive(:membership_guidelines_agreement_required_now?).and_return(false)
                allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?).and_return(true)

                unapproved_app = create(:shf_application, state: app_state)
                unapproved_applicant = unapproved_app.user
                expect(subject.requirements_met?({ user: unapproved_applicant })).to be_falsey
              end
            end
          end
        end
      end

    end
  end


  describe '.satisfied?' do

    it '.has_expected_arguments? is true and requirements_met? is true' do
      member_current_payment
      build_stubbed(:user_checklist, :completed, user: member, name: 'Membership Guidelines list')
      allow(UserChecklist).to receive(:membership_guidelines_for_user).and_return(member.checklists)
      allow(UserChecklistManager).to receive(:completed_membership_guidelines_checklist?).and_return(true)

      expect(subject.satisfied?( user: member)).to be_truthy
    end

    it '.has_expected_arguments? is true and requirements_met? is false' do
      expect(subject.satisfied?({ user: user })).to be_falsey
    end

    it '.has_expected_arguments? is false and requirements_met? is true' do
      member_current_payment
      create(:user_checklist, :completed, user: member, name: 'Membership Guidelines list')
      allow(UserChecklist).to receive(:membership_guidelines_for_user).and_return(member.checklists)

      expect(subject.satisfied?({ not_user: member })).to be_falsey
    end

    it '.has_expected_arguments? is false and requirements_met? is false' do
      expect(subject.satisfied?({ not_user: user })).to be_falsey
    end

  end

end
