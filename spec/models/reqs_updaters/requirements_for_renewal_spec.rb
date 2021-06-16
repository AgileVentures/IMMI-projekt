require 'rails_helper'

RSpec.describe RequirementsForRenewal, type: :model do

  let(:subject) { RequirementsForRenewal }
  let(:user) { build(:user) }
  let(:yesterday) { Date.current - 1.day }


  describe 'specifications and Unit Tests' do

    before(:each) do
      # stub this so we don't have to create the MasterChecklist for the Member Guidelines checklist
      # if a ShfApplication is accepted.
      allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for).and_return(true)
    end


    describe '.requirements_excluding_payments_met?' do

      it 'checks state machine to confirm membership_status is in the correct state to call the renew event' do
        expect(user).to receive(:may_renew?).and_return(true)
        subject.requirements_excluding_payments_met?(user)
      end

      it 'false if state machine says it cannot do the renew event (membership_status is in the wrong state)' do
        allow(user).to receive(:may_renew?).and_return(false)

        expect(subject.requirements_excluding_payments_met?(user)).to be_falsey
      end


      context 'user can renew on the given date' do
        before(:each) {  allow(user).to receive(:may_renew?).and_return(true) }

        context 'user can renew on the given date' do
          before(:each) do
            allow(user).to receive(:current_member?).and_return(true)
            allow(user).to receive(:valid_date_for_renewal?).and_return(true)
          end

          context 'user has an approved SHF application' do
            before(:each) { allow(user).to receive(:has_approved_shf_application?).and_return(true) }

            context 'user has agreed to the membership guidelines' do
              before(:each) { allow(subject).to receive(:membership_guidelines_checklist_done?).and_return(true) }

              it 'true if documents have been uploaded during the current membership term' do
                allow(subject).to receive(:doc_uploaded_during_this_membership_term?).and_return(true)

                expect(subject.requirements_excluding_payments_met?(user)).to be_truthy
              end

              it 'false if no documents have been uploaded during the current membership term' do
                allow(subject).to receive(:doc_uploaded_during_this_membership_term?).and_return(false)

                expect(subject.requirements_excluding_payments_met?(user)).to be_falsey
              end
            end

            it 'false if the user has not agreed to the membership guidelines' do
              allow(subject).to receive(:membership_guidelines_checklist_done?).and_return(false)

              expect(subject).not_to receive(:doc_uploaded_during_this_membership_term?)
              expect(subject.requirements_excluding_payments_met?(user)).to be_falsey
            end
          end

          it 'false if user does not have an approved SHF application' do
            allow(user).to receive(:has_approved_shf_application?).and_return(false)

            expect(subject).not_to receive(:membership_guidelines_checklist_done?)
            expect(subject).not_to receive(:doc_uploaded_during_this_membership_term?)
            expect(subject.requirements_excluding_payments_met?(user)).to be_falsey
          end
        end

        it 'false if user cannot renew on the given date' do
          allow(user).to receive(:valid_date_for_renewal?).and_return(false)

          expect(user).not_to receive(:has_approved_shf_application?)
          expect(subject).not_to receive(:membership_guidelines_checklist_done?)
          expect(subject).not_to receive(:doc_uploaded_during_this_membership_term?)
          expect(subject.requirements_excluding_payments_met?(user)).to be_falsey
        end
      end

      it 'false if user cannot renew' do
        allow(user).to receive(:may_renew?).and_return(false)

        expect(subject.requirements_excluding_payments_met?(user)).to be_falsey
      end
    end


    describe '.doc_uploaded_during_this_membership_term?' do

      describe 'queries the user to see if files have been uploaded on or after the term start' do
        it 'true if files have been uploaded' do
          allow(user).to receive(:file_uploaded_during_this_membership_term?)
                           .and_return(true)
          expect(subject.doc_uploaded_during_this_membership_term?(user)).to be_truthy
        end

        it 'false if files were not uploaded during the term' do
          allow(user).to receive(:file_uploaded_during_this_membership_term?)
                           .and_return(false)
          expect(subject.doc_uploaded_during_this_membership_term?(user)).to be_falsey
        end
      end
    end
  end


  describe '.payment_requirements_met?' do

    it 'true if all payments are current' do
      u = build(:user)
      expect(u).to receive(:payments_current_as_of?).and_return(true)
      expect(subject.payment_requirements_met?(u)).to be_truthy
    end

    it 'false if no payments have been made' do
      u = build(:user)
      expect(subject.payment_requirements_met?(u)).to be_falsey
    end
  end

  # ------------------------------------------------------------------------------------------

  # TODO: Are any of these really needed?  can things be mocked or stubbed?
  describe 'Integration tests' do
    let(:member) { build(:member_with_membership_app) }
    let(:days_can_renew_early) { 5 }

    describe '.requirements_met?' do
      before(:each) { allow(MembershipsManager).to receive(:days_can_renew_early).and_return(days_can_renew_early) }

      it 'always false if has never made a payment' do
        approved_app = create(:shf_application, :accepted)
        expect(subject.requirements_met?({ user: approved_app.user })).to be_falsey
      end


      context 'has approved application' do

        let(:approved_applicant) do
          approved_app = create(:shf_application, :accepted)
          approved_app.user
        end

        context 'membership guidelines ARE agreed to' do
          before(:each) do
            allow(UserChecklistManager).to receive(:completed_membership_guidelines_checklist?).and_return(true)
            allow_any_instance_of(UserChecklist).to receive(:set_complete_including_children)
          end

          context 'file has been uploaded during this membership term' do
            before(:each) { allow(described_class).to receive(:doc_uploaded_during_this_membership_term?).and_return(true) }

            context 'membership has not expired' do
              let(:last_day) { Date.current + 100 }
              let(:current_member) { create(:member_with_expiration_date, expiration_date: last_day) }

              it 'true if not too early to renew' do
                # set today to a day that the member can renew early
                travel_to(last_day - days_can_renew_early + 2) do
                  expect(current_member.valid_date_for_renewal?(Date.current)).to be_truthy
                  expect(current_member.has_approved_shf_application?).to be_truthy
                  expect(current_member.membership_guidelines_checklist_done?).to be_truthy
                  expect(subject.doc_uploaded_during_this_membership_term?(current_member)).to be_truthy

                  expect(subject.requirements_excluding_payments_met?(current_member)).to be_truthy
                  expect(subject.payment_requirements_met?(current_member)).to be_truthy

                  expect(subject.requirements_met?({ user: current_member })).to be_truthy
                end
              end

              it 'false if too early to renew' do
                # set today to a day that is too early to renew
                travel_to(last_day - days_can_renew_early - 2) do
                  expect(current_member.today_is_valid_renewal_date?).to be_falsey
                  expect(current_member.membership_guidelines_checklist_done?).to be_truthy
                  expect(subject.doc_uploaded_during_this_membership_term?(current_member)).to be_truthy

                  expect(subject.requirements_met?({ user: current_member })).to be_falsey
                end
              end
            end

            context 'membership has expired' do

              it 'false if member is no longer a member; (past the in grace period)' do
                grace_period_length = 4.days
                allow(MembershipsManager).to receive(:grace_period).and_return(grace_period_length)
                former_member = create(:member_with_expiration_date, expiration_date: yesterday)

                allow(former_member).to receive(:current_member?).and_return(false)
                allow(former_member).to receive(:in_grace_period?).and_return(false)
                allow(former_member).to receive(:former_member?).and_return(true)

                # set today to a date that is past the grace period
                travel_to(Date.current + grace_period_length + 1.day) do
                  expect(subject.requirements_met?({ user: former_member })).to be_falsey
                end
              end
            end

            it 'false if membership payment not made' do
              expect(subject.requirements_met?({ user: approved_applicant })).to be_falsey
            end
          end

          context 'no file uploaded during this membership term' do
            it 'always false' do
              allow(described_class).to receive(:doc_uploaded_during_this_membership_term?)
                                          .and_return(false)

              last_day = Date.current + 100
              approved_and_paid = create(:member_with_expiration_date, expiration_date: last_day)

              travel_to(last_day - 3) do
                expect(approved_and_paid.today_is_valid_renewal_date?).to be_truthy
                expect(approved_and_paid.membership_guidelines_checklist_done?).to be_truthy

                expect(approved_and_paid.has_approved_shf_application?).to be_truthy
                expect(subject.doc_uploaded_during_this_membership_term?(approved_and_paid)).to be_falsey

                expect(subject.requirements_excluding_payments_met?(approved_and_paid)).to be_falsey
                expect(subject.payment_requirements_met?(approved_and_paid)).to be_truthy

                expect(subject.requirements_met?({ user: approved_and_paid })).to be_falsey
              end
            end
          end

        end

        context 'membership guidelines NOT agreed to' do
          before(:each) { allow(UserChecklistManager).to receive(:completed_membership_guidelines_checklist?).and_return(false) }

          it 'always false' do
            approved_and_paid = create(:member_with_expiration_date, expiration_date: Date.current + 100)
            expect(subject.requirements_met?(user: approved_and_paid)).to be_falsey
          end
        end
      end

      context 'does not have an approved application: always false' do

        context 'membership guidelines ARE agreed to' do
          before(:each) { allow(UserChecklistManager).to receive(:completed_membership_guidelines_checklist?).and_return(true) }

          ShfApplication.all_states.reject { |s| s == ShfApplication::STATE_ACCEPTED }.each do |app_state|

            context "app is #{app_state}" do

              it "false if membership payment made (and it has not expired)" do
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

              it "false if membership payment made and it HAS expired FIXME" do
                # FIXME - should this be a former member?
                unapproved_app = create(:shf_application, state: app_state)
                unapproved_and_paid = unapproved_app.user

                start_date, expire_date = User.next_membership_payment_dates(unapproved_and_paid.id)
                create(:membership_fee_payment,
                       :successful,
                       user: unapproved_and_paid,
                       start_date: start_date,
                       expire_date: expire_date)

                travel_to(expire_date + 1.day) do
                  expect(subject.requirements_met?({ user: unapproved_and_paid })).to be_falsey
                end
              end

              it "false if membership payment not made" do
                unapproved_app = create(:shf_application, state: app_state)
                unapproved_applicant = unapproved_app.user
                expect(subject.requirements_met?({ user: unapproved_applicant })).to be_falsey
              end
            end
          end
        end
      end
    end

    it 'false if user cannot renew on the given date' do
      allow(user).to receive(:today_is_valid_renewal_date?).and_return(false)

      expect(user).not_to receive(:has_approved_shf_application?)
      expect(subject).not_to receive(:membership_guidelines_checklist_done?)
      expect(subject).not_to receive(:doc_uploaded_during_this_membership_term?)
      expect(subject.requirements_excluding_payments_met?(user)).to be_falsey
    end
  end
end
