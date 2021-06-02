require 'rails_helper'


RSpec.describe MembershipStatusUpdater, type: :model do

  let(:subject) { MembershipStatusUpdater.instance }

  let(:mock_log) { instance_double("ActivityLogger") }
  let(:mock_email_msg) { instance_double('Mail::Message', deliver: true) }

  before(:each) do
    allow(MemberMailer).to receive(:membership_granted)
                             .and_return(mock_email_msg)
    allow(MemberMailer).to receive(:membership_renewed)
                             .and_return(mock_email_msg)

    allow_any_instance_of(ApplicationMailer).to receive(:mail).and_return(mock_email_msg)
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)
  end

  let(:payment_date_2017) { Time.zone.local(2017, 10, 1) }
  let(:payment_date_2018) { Time.zone.local(2018, 11, 21) }

  let(:user) { build(:user) }
  let(:user_app_approved) do
    u = create(:user)
    create(:shf_application,
           :accepted,
           user: u,)
    u
  end

  let(:payment_user_approved_app) do
    start_date, expire_date = User.next_membership_payment_dates(user_app_approved.id)

    create(:membership_fee_payment,
           :successful,
           user: user_app_approved,
           start_date: start_date,
           expire_date: expire_date)
  end

  let(:paid_member) { create(:member_with_membership_app) }

  let(:shf_app) { create(:shf_application) }

  it 'shf_application_updated calls update_membership_status with a message that the app was updated' do
    shf_app_updated = build(:shf_application, user: build(:user))

    expect(subject).to receive(:update_membership_status).with(shf_app_updated.user,
                                                               shf_app_updated,
                                                               subject.logmsg_app_updated,
                                                               send_email: true)
    subject.shf_application_updated(shf_app_updated)
  end


  describe 'payment_made' do
    let(:payment_for_not_expired_paid_member) { build(:payment, user: build(:user), start_date: Date.current, expire_date: Date.current + 1.day) }

    it 'calls check_grant_membership_or_renew with the log msg that the payment was made' do
      expect(subject).to receive(:check_grant_membership_or_renew).with(payment_for_not_expired_paid_member.user,
                                                                        payment_for_not_expired_paid_member,
                                                                        subject.logmsg_payment_made,
                                                                        send_email: anything)
      subject.payment_made(payment_for_not_expired_paid_member)
    end

    it 'can pass in send_email: <true|false>' do
      expect(subject).to receive(:check_grant_membership_or_renew).with(payment_for_not_expired_paid_member.user,
                                                                        payment_for_not_expired_paid_member,
                                                                        subject.logmsg_payment_made,
                                                                        send_email: false)
      subject.payment_made(payment_for_not_expired_paid_member, send_email: false)
    end

    it 'send_email: default is send_email_default' do
      expect(subject).to receive(:send_email_default).and_return(true)
      expect(subject).to receive(:check_grant_membership_or_renew).with(payment_for_not_expired_paid_member.user,
                                                                        payment_for_not_expired_paid_member,
                                                                        subject.logmsg_payment_made,
                                                                        send_email: true)
      subject.payment_made(payment_for_not_expired_paid_member)
    end
  end


  describe 'checklist_completed' do
    let(:completed_checklist) { build(:user_checklist, :completed) }
    let(:checklist_user) { completed_checklist.user }

    it 'calls check_grant_membership_or_renew with the log msg that the checklist was completed' do
      expect(subject).to receive(:check_grant_membership_or_renew).with(checklist_user,
                                                                        completed_checklist,
                                                                        subject.logmsg_checklist_completed,
                                                                        send_email: anything)
      subject.checklist_completed(completed_checklist)
    end

    it 'can pass in send_email: <true|false>' do
      expect(subject).to receive(:check_grant_membership_or_renew).with(checklist_user,
                                                                        completed_checklist,
                                                                        subject.logmsg_checklist_completed,
                                                                        send_email: false)
      subject.checklist_completed(completed_checklist, send_email: false)
    end

    it 'send_email: default is send_email_default' do
      expect(subject).to receive(:send_email_default).and_return(true)
      expect(subject).to receive(:check_grant_membership_or_renew).with(checklist_user,
                                                                        completed_checklist,
                                                                        subject.logmsg_checklist_completed,
                                                                        send_email: true)
      subject.checklist_completed(completed_checklist)
    end
  end


  describe 'user_updated' do
    it 'user_updated calls update_membership_status with a message that the user was updated and send_email: option' do
      expect(subject).to receive(:update_membership_status).with(user,
                                                                 user,
                                                                 subject.logmsg_user_updated,
                                                                 send_email: anything)
      subject.user_updated(user)
    end

    it 'can pass in send_email: <true|false>' do
      expect(subject).to receive(:update_membership_status).with(user,
                                                                 user,
                                                                 subject.logmsg_user_updated,
                                                                 send_email: false)
      subject.user_updated(user, send_email: false)
    end

    it 'send_email: default is send_email_default' do
      expect(subject).to receive(:send_email_default).and_return(true)
      expect(subject).to receive(:update_membership_status).with(user,
                                                                 user,
                                                                 subject.logmsg_user_updated,
                                                                 send_email: true)
      subject.user_updated(user)
    end

  end


  describe 'check_grant_membership_or_renew' do
    let(:built_user) { build(:user) }
    let(:notifier) { 'object that sent the notification to kick this off' }
    let(:reason) { ' ' }


    shared_examples 'it checks to see if user can renew' do |membership_status|
      let(:given_user) { build(:user, membership_status: membership_status) }

      it 'checks to see if all requirements for renewing are satisfied' do
        expect(RequirementsForRenewal).to receive(:requirements_met?).with(user: given_user)
        subject.check_grant_membership_or_renew(given_user, notifier, reason)
      end

      context 'can renew (requirements are met)' do
        before(:each) { allow(RequirementsForRenewal).to receive(:requirements_met?).and_return(true) }

        context 'membership last day is in the future' do
          before(:each) { allow(given_user).to receive(:membership_expire_date).and_return(Date.current + 2.days) }
          it 'renews the membership after the membership last day' do
            expect(given_user).to receive(:renew!).with(date: Date.current + 3.days,
                                                        send_email: true)
            subject.check_grant_membership_or_renew(given_user, notifier, reason)
          end
        end

        context 'membership last day is today or in the past' do
          before(:each) { allow(given_user).to receive(:membership_expire_date).and_return(Date.current - 2.days) }

          it 'tells the user to renew today' do
            expect(given_user).to receive(:renew!).with(date: Date.current,
                                                        send_email: true)
            subject.check_grant_membership_or_renew(given_user, notifier, reason)
          end
        end

        it 'logs that the user membership status was changed' do
          allow(given_user).to receive(:membership_changed_info)
          expect(mock_log).to receive(:info).with(given_user.membership_changed_info)
          subject.check_grant_membership_or_renew(given_user, notifier, reason)
        end

        it 'passes along the value of send_email' do
          expect(given_user).to receive(:renew!).with(date: Date.current,
                                                      send_email: false)
          subject.check_grant_membership_or_renew(given_user, notifier, reason, send_email: false)
        end
      end

      context 'cannot renew (requirements not met)' do
        before(:each) { allow(RequirementsForRenewal).to receive(:requirements_met?).and_return(false) }

        it 'does not renew' do
          expect(given_user).not_to receive(:renew!)
          subject.check_grant_membership_or_renew(given_user, notifier, reason)
        end
      end
    end


    shared_examples 'it checks to see if membership can be granted' do |membership_status|
      let(:given_user) { build(:user, membership_status: membership_status) }

      it 'checks to see if all requirements for membership are satisfied' do
        expect(RequirementsForMembership).to receive(:requirements_met?).with(user: given_user)
        subject.check_grant_membership_or_renew(given_user, notifier, reason)
      end

      context 'can grant membership (requirements are met)' do
        before(:each) { allow(RequirementsForMembership).to receive(:requirements_met?).and_return(true) }

        context 'there is no previous membership' do
          before(:each) { allow(given_user).to receive(:membership_expire_date).and_return(nil) }

          it 'starts the new membership today' do
            expect(given_user).to receive(:start_membership!).with(date: Date.current,
                                                                   send_email: true)
            subject.check_grant_membership_or_renew(given_user, notifier, reason)
          end

          it 'passes along the value of send_email' do
            expect(given_user).to receive(:start_membership!).with(date: Date.current,
                                                                   send_email: false)
            subject.check_grant_membership_or_renew(given_user, notifier, reason, send_email: false)
          end
        end

        context 'today is the last day of the membership' do
          before(:each) { allow(given_user).to receive(:membership_expire_date).and_return(Date.current) }

          it 'starts the new membership tomorrow' do
            expect(given_user).to receive(:start_membership!).with(date: Date.current + 1.day,
                                                                   send_email: true)
            subject.check_grant_membership_or_renew(given_user, notifier, reason)
          end

          it 'passes along the value of send_email' do
            expect(given_user).to receive(:start_membership!).with(date: Date.current + 1.day,
                                                                   send_email: false)
            subject.check_grant_membership_or_renew(given_user, notifier, reason, send_email: false)
          end
        end

        context 'latest membership has not ended' do
          before(:each) { allow(given_user).to receive(:membership_expire_date).and_return(Date.current + 2.days) }

          it 'starts the new membership one day after the last day of the latest membership' do
            expect(given_user).to receive(:start_membership!).with(date: Date.current + 3.days,
                                                                   send_email: true)
            subject.check_grant_membership_or_renew(given_user, notifier, reason)
          end

          it 'passes along the value of send_email' do
            expect(given_user).to receive(:start_membership!).with(date: Date.current + 3.days,
                                                                   send_email: false)
            subject.check_grant_membership_or_renew(given_user, notifier, reason, send_email: false)
          end
        end

        context 'latest membership ended before today' do
          before(:each) { allow(given_user).to receive(:membership_expire_date).and_return(Date.current - 2.days) }

          it 'starts the new membership today' do
            expect(given_user).to receive(:start_membership!).with(date: Date.current,
                                                                   send_email: true)
            subject.check_grant_membership_or_renew(given_user, notifier, reason)
          end

          it 'passes along the value of send_email' do
            expect(given_user).to receive(:start_membership!).with(date: Date.current,
                                                                   send_email: false)
            subject.check_grant_membership_or_renew(given_user, notifier, reason, send_email: false)
          end
        end

        it 'logs that the user membership status was changed' do
          allow(given_user).to receive(:membership_changed_info)
          expect(mock_log).to receive(:info).with(given_user.membership_changed_info)
          subject.check_grant_membership_or_renew(given_user, notifier, reason)
        end
      end

      context 'cannot grant membership (requirements not met)' do
        before(:each) { allow(RequirementsForMembership).to receive(:requirements_met?).and_return(false) }

        it 'does not grant membership' do
          expect(given_user).not_to receive(:start_membership!)
          subject.check_grant_membership_or_renew(given_user, notifier, reason)
        end
      end
    end

    # end shared_examples
    # -------------------------------------------------------------------------------------------


    context 'is a former member' do
      it_behaves_like 'it checks to see if membership can be granted', 'former_member'
    end

    context 'not a member (and not a former member)' do
      it_behaves_like 'it checks to see if membership can be granted', 'not_a_member'
    end

    context 'is in the renewal grace period' do
      it_behaves_like 'it checks to see if user can renew', 'in_grace_period'
    end

    context 'is a current_member' do
      it_behaves_like 'it checks to see if user can renew', 'current_member'
    end

    describe 'does nothing if not a current member, not a former member, not in the grace period, or not a member' do
      # the nonsense status 'blorf' is here to ensure we run this test with at least 1 status
      other_membership_statuses = User.membership_statuses - [:not_a_member, :former_member, :current_member, :in_grace_period] + [:blorf]
      other_membership_statuses.each do |other_status|
        it "status = #{other_status}" do
          given_user = build(:user, membership_status: other_status)
          expect(given_user).not_to receive(:start_membership!)
          expect(given_user).not_to receive(:renew!)
          subject.check_grant_membership_or_renew(given_user, notifier, reason)
        end
      end
    end


    it 'calls log_and_check with this method name, user, args ([notifier]) and notifier' do
      notifier = 'payment'
      reason = 'payment made'
      expect(subject).to receive(:log_and_check)
                           .with('check_grant_membership_or_renew',
                                 built_user, [notifier], notifier, reason)
      subject.check_grant_membership_or_renew(built_user, notifier, reason)
    end
  end


  describe 'update_membership_status' do

    context 'does nothing if user is not a current member or in the renewal grace period' do
      # the nonsense status 'blorf' is here to ensure we run this test with at least 1 status
      other_membership_statuses = User.membership_statuses - [ :current_member, :in_grace_period] + [:blorf]
      other_membership_statuses.each do |other_status|
        it "status = #{other_status}" do
          given_user = build(:user, membership_status: other_status)
          expect(given_user).not_to receive(:start_grace_period!)
          expect(given_user).not_to receive(:make_former_member!)
          subject.update_membership_status(given_user, 'some notifier', 'some reason')
        end
      end
    end


    context 'is a current member' do
      let(:user) do
        u = build(:member_with_expiration_date, expiration_date: (Date.current + 1.day))
        u.membership_status = :current_member
        u
      end

      context 'date is in the renewal grace period' do
        before(:each) do
          allow(user).to receive(:membership_expired_in_grace_period?).and_return(true)
        end

        it 'starts the grace period and logs that the membership status has changed' do
          allow(RequirementsForRenewal).to receive(:satisfied?).and_return(false)

          expect(user).to receive(:start_grace_period!).and_call_original
          expect(mock_log).to receive(:info).with("update_membership_status for #{user.inspect}")

          subject.update_membership_status(user)
        end

        it 'passes along the value of send_email' do
          expect(user).to receive(:start_grace_period!).with(send_email: false)
                            .and_call_original
          subject.update_membership_status(user, send_email: false)
        end
      end

      context 'date is past the last day of the renwal grace period' do
        before(:each) do
          allow(user).to receive(:membership_expired_in_grace_period?)
                           .and_return(false)
          allow(user).to receive(:membership_past_grace_period_end?)
                           .and_return(true)
        end

        it 'starts the grace period AND then becomes a former member and logs changes' do
          allow(RequirementsForRenewal).to receive(:satisfied?)
                                             .and_return(false)

          expect(user).to receive(:start_grace_period!)
          expect(user).to receive(:make_former_member!)

          # called once when the status is initialzed for the test,
          #   once in start_grace_period!
          #   and once in make_former_member!
          expect(user).to receive(:membership_changed_info).exactly(3).times.
            and_call_original
          expect(mock_log).to receive(:info).twice.with("#{user.membership_changed_info}")

          subject.update_membership_status(user)
        end

        it 'passes along the value of send_email' do
          expect(user).to receive(:start_grace_period!).with(send_email: false)
                                                       .and_call_original
          expect(user).to receive(:make_former_member!).with(send_email: false)
                                                       .and_call_original
          subject.update_membership_status(user, send_email: false)
        end
      end
    end


    context 'is in the renewal grace period' do

      context 'date is still in the renewal grace period' do
        it 'does nothing' do
          user = build(:user, membership_status: :in_grace_period)
          allow(user).to receive(:membership_past_grace_period_end?)
                           .and_return(false)
          expect(user).not_to receive(:start_grace_period!)
          expect(user).not_to receive(:make_former_member!)
          subject.update_membership_status(user)
        end
      end

      context 'date is past (>) the last day of the renewal grace period' do
        let(:past_grace_pd_user) do
          user = build(:user)
          user.membership_status = :in_grace_period
          user
        end

        it 'becomes a former member' do
          expect(past_grace_pd_user).to receive(:membership_past_grace_period_end?)
                            .and_return(true)
          expect(past_grace_pd_user).to receive(:make_former_member!)
          subject.update_membership_status(past_grace_pd_user)
        end

        it 'passes along the value of send_email' do
          expect(past_grace_pd_user).to receive(:membership_past_grace_period_end?)
                                          .and_return(true)
          expect(past_grace_pd_user).to receive(:make_former_member!).with(send_email: false)
          subject.update_membership_status(past_grace_pd_user, send_email: false)
        end
      end
    end


    it 'calls log_and_check with this method name, user, args ([notifier]) and notifier' do
      built_user = build(:user)
      notifier = 'updated'
      reason = 'some reason'
      expect(subject).to receive(:log_and_check)
                           .with('update_membership_status',
                                 built_user, [notifier], notifier, reason)
      subject.update_membership_status(built_user, notifier, reason)
    end
  end


  describe 'log_and_check' do
    let(:built_user) { build(:user) }
    let(:calling_method) { 'method_doing_the_action' }
    let(:reason_update_happened) { 'This is the reason this was called' }


    it 'yields to the block sent with the user, other args, and the log' do
      sender = 'Sender'
      other_args = [1,'3']
      expect(sender).to receive(:+).with("#{built_user}, #{other_args} #{mock_log}")
      subject.log_and_check(calling_method,
                            built_user, other_args,
                            nil, reason_update_happened) do | given_user, other_given_args, log|
        sender + ("#{given_user}, #{other_given_args} #{log}")
      end
    end


    describe 'opens an Activity Logger and logs the reason this was called, by whom (the notifier)' do
      it 'logs no message about the notifier if notifier is blank' do
        expect(mock_log).to receive(:info).with(/#{calling_method} for #{built_user.inspect}/)
        subject.log_and_check(calling_method,
                              built_user, [],
                              nil, reason_update_happened) {}
      end

      it 'logs a message if the notifier is not blank' do
        notifier = 'This is the object that sent the notification that caused this to be called in the first placee'
        expect(mock_log).to receive(:info).with(/#{calling_method} for #{built_user.inspect}/)
        expect(mock_log).to receive(:info).with(/#{reason_update_happened}: #{notifier.inspect}/)
        subject.log_and_check(calling_method,
                              built_user, [],
                              notifier, reason_update_happened) {}
      end
    end
  end


  it 'send_email_default is true' do
    expect(subject.send_email_default).to be_truthy
  end
end
