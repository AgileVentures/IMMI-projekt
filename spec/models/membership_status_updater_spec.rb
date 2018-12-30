require 'rails_helper'

RSpec.describe MembershipStatusUpdater, type: :model do

  let(:subject) { MembershipStatusUpdater.instance }

  let(:payment_date_2017) { Time.zone.local(2017, 10, 1) }
  let(:payment_date_2018) { Time.zone.local(2018, 11, 21) }

  let(:user) { create(:user) }
  let(:user_app_approved) do
    u = create(:user)
    create( :shf_application,
            :accepted,
            user: u, )
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

  let(:payment_not_expired_paid_member) do
    start_date, expire_date = User.next_membership_payment_dates(paid_member.id)

    create(:membership_fee_payment,
           :successful,
           user: paid_member,
           start_date: start_date,
           expire_date: expire_date)
  end

  let(:shf_app) { create(:shf_application) }


  it '#shf_application_updated' do
    expect(subject).to receive(:check_requirements_and_act).with({user: shf_app.user})

    subject.shf_application_updated(shf_app)
  end


  it '#payment_made' do
    expect(subject).to receive(:check_requirements_and_act).with({user: payment_not_expired_paid_member.user})

    subject.payment_made(payment_not_expired_paid_member)
  end


  it '#user_updated' do
    expect(subject).to receive(:check_requirements_and_act).with({user: user})

    subject.user_updated(user)
  end


  describe '#check_requirements_and_act' do

    it 'does nothing if not a member' do
      subject.check_requirements_and_act({user: user})
      expect(user.member?).to be_falsey
    end

    it 'does nothing if a member and payment not expired' do
      payment_not_expired_paid_member

      subject.check_requirements_and_act({user: paid_member})
      expect(paid_member.member?).to be_truthy
    end

    it 'revokes membership if is a member and payment has expired' do
      Timecop.freeze(payment_date_2018)

      payment_not_expired_paid_member

      Timecop.freeze(Time.zone.today + 1.year)  # move past the expiration date for the membership term to make it expired

      subject.check_requirements_and_act({user: paid_member})
      expect(paid_member.member?).to be_falsey

      Timecop.return
    end

    it 'does nothing if not a member and does not meet membership criteria' do

    end

    describe 'sending emails' do

      before(:each) do
        # mock the MemberMailer so we don't try to send emails
        allow(MemberMailer).to receive(:membership_granted).with(user_app_approved).and_return(double('MemberMailer', deliver: true))
      end


      it 'sends emails by default' do
        expect(subject).to receive(:update_action).with({user: user_app_approved})
        payment_user_approved_app
        subject.check_requirements_and_act({user: user_app_approved})
      end

      it 'send_email: true will send emails' do
        expect(subject).to receive(:update_action).with({user: user_app_approved, send_email: true } )
        payment_user_approved_app
        subject.check_requirements_and_act({user: user_app_approved, send_email: true} )
      end

      it 'send_email: false will not send emails' do
        expect(subject).to receive(:update_action).with({user: user_app_approved, send_email: false } )
        payment_user_approved_app
        subject.check_requirements_and_act({user: user_app_approved, send_email: false} )
      end
    end

  end


  describe '#update_action' do

    # Note - since this is a private method, we can only do unit testing of it
    # with RSpec if we explicitly :send the message to the subject

    it 'user.member? is true' do
      # mock the MemberMailer so we don't try to send emails
      expect(MemberMailer).to receive(:membership_granted).with(user).and_return(double('MemberMailer', deliver: true))

      subject.send(:update_action, {user: user}) # this is equivalent to subject.update_action(user)
      expect(user.member?).to be_truthy
    end

    it 'sends emails out by default' do
      expect_any_instance_of(MemberMailer).to receive(:membership_granted).with(user)
      subject.send(:update_action, {user: user}) # this is equivalent to subject.update_action(user)
    end

    it 'send_email: true sends email to the member to let them know they are now a member' do
      expect_any_instance_of(MemberMailer).to receive(:membership_granted).with(user)
      subject.send(:update_action, {user: user, send_email: true}) # this is equivalent to subject.update_action([]user, send_email: true ])
    end

    it 'send_email: false does not send email to the member to let them know they are now a member' do
      expect_any_instance_of(MemberMailer).not_to receive(:membership_granted).with(user)
      subject.send(:update_action, {user: user, send_email: false}) # this is equivalent to subject.update_action([user, send_email: false ])
    end

  end


  describe '#revoke_update_action' do

    # Note - since this is a private method, we can only do unit testing of it
    # with RSpec if we explicitly :send the message to the subject

    it 'user.member? is false' do
      subject.send(:revoke_update_action, {user: user}) # this is equivalent to subject.revoke_update_action({user: user})
      expect(user.member?).to be_falsey
    end

  end

end
