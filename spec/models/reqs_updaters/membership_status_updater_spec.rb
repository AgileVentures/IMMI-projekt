require 'rails_helper'

require 'shared_context/users'

RSpec.describe MembershipStatusUpdater, type: :model do

  let(:subject) { MembershipStatusUpdater.instance }

  let(:mock_log) { instance_double("ActivityLogger") }
  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)
  end


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


  it '#revoke_user_membership' do
    expect(subject).to receive(:check_requirements_and_act).with({user: user})

    subject.revoke_user_membership(user)
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


    describe 'sending emails' do

      before(:each) do
        # mock the MemberMailer so we don't try to send emails
        allow(MemberMailer).to receive(:membership_granted).with(user_app_approved).and_return(double('MemberMailer', deliver: true))
      end


      it 'sends emails by default' do
        allow(subject.class.update_requirements_checker).to receive(:satisfied?).and_return(true)

        expect(subject).to receive(:update_action).with({user: user_app_approved})

        payment_user_approved_app
        subject.check_requirements_and_act({user: user_app_approved})
      end

      it 'send_email: true will send emails' do
        allow(subject.class.update_requirements_checker).to receive(:satisfied?).and_return(true)

        expect(subject).to receive(:update_action).with({user: user_app_approved, send_email: true } )

        payment_user_approved_app
        subject.check_requirements_and_act({user: user_app_approved, send_email: true} )
      end

      it 'send_email: false will not send emails' do
        allow(subject.class.update_requirements_checker).to receive(:satisfied?).and_return(true)

        expect(subject).to receive(:update_action).with({user: user_app_approved, send_email: false } )

        payment_user_approved_app
        subject.check_requirements_and_act({user: user_app_approved, send_email: false} )
      end
    end

  end


  describe '#update_action' do

    # Note - since this is a private method, we can only do unit testing of it
    # with RSpec if we explicitly :send the message to the subject

    it 'user.member? is true after update' do
      expect(subject).to receive(:grant_membership).and_call_original

      # mock the MemberMailer so we don't try to send emails
      expect(MemberMailer).to receive(:membership_granted).with(user).and_return(double('MemberMailer', deliver: true))

      subject.send(:update_action, {user: user}) # this is equivalent to subject.update_action(user); assumes that the pre-conditions have been checked and met
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

    describe 'new_membership_granted_co_hbrand_paid email sent only if new member has at least one company that is complete and branding license is current' do

      let(:new_member) do
        u = create(:user)
        create( :shf_application,
                          :accepted,
                          user: u )
        u
      end

      let(:co) { new_member.shf_application.companies.first }


      it 'has 1 co. complete AND branding license current = mail sent' do
        create(:h_branding_fee_payment, :successful, user: new_member, company: co)

        # mock the MemberMailer and AdminMailer so we don't try to send emails
        expect(MemberMailer).to receive(:membership_granted).with(new_member).and_return(double('MemberMailer', deliver: true))
        expect(AdminMailer).to receive(:new_membership_granted_co_hbrand_paid).with(new_member).and_return(double('AdminMailer', deliver: true))

        subject.send(:update_action, {user: new_member}) # this is equivalent to subject.update_action(new_member)
      end

      it 'has 1 co complete (but branding lic. not current) = no mail sent' do
        # mock the MemberMailer and AdminMailer so we don't try to send emails
        expect(MemberMailer).to receive(:membership_granted).with(new_member).and_return(double('MemberMailer', deliver: true))
        expect(AdminMailer).not_to receive(:new_membership_granted_co_hbrand_paid).with(new_member)

        subject.send(:update_action, {user: new_member}) # this is equivalent to subject.update_action(new_member)

      end


      it 'has 1 co branding lic. is current but not complete = no mail sent' do
        create(:h_branding_fee_payment, :successful, user: new_member, company: co)
        co.name = '' # make this not complete

        # mock the MemberMailer and AdminMailer so we don't try to send emails
        expect(MemberMailer).to receive(:membership_granted).with(new_member).and_return(double('MemberMailer', deliver: true))
        expect(AdminMailer).not_to receive(:new_membership_granted_co_hbrand_paid).with(new_member)

        subject.send(:update_action, {user: new_member}) # this is equivalent to subject.update_action(new_member)

      end
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

  describe 'grant membership' do

    include_context 'create users'

    before(:each) do
      # mock the MemberMailer so we don't try to send emails
      allow(MemberMailer).to receive(:membership_granted).and_return(double('MemberMailer', deliver: true))
    end

    describe 'sends the Admin an email only if this is the first membership granted to a user' do

      describe 'it is based on the previous membership status and membership number' do

        it 'sends email if previous membership status = false (not a member) AND no previous membership number' do
          expect(AdminMailer).to receive(:new_membership_granted_co_hbrand_paid).and_return(double('AdminMailer', deliver: true))
          is_first_membership = user_all_paid_membership_not_granted
          subject.send(:grant_membership,is_first_membership, true)
        end

        it 'no email sent if previous membership status = true (was a member)' do
          expect(AdminMailer).not_to receive(:new_membership_granted_co_hbrand_paid) #.and_return(double('AdminMailer', deliver: true))
          subject.send(:grant_membership, member_paid_up, true)
        end

        it 'no email sent if there was a previous membership number' do
          expect(AdminMailer).not_to receive(:new_membership_granted_co_hbrand_paid) #.and_return(double('AdminMailer', deliver: true))
          had_membership_number = user_all_paid_membership_not_granted
          had_membership_number.membership_number = '1'
          subject.send(:grant_membership,had_membership_number, true)
        end
      end
    end

  end


  describe 'first_membership?(previous_membership_status, previous_membership_number)' do

    context 'previous membership status = true' do

      it 'false if previous membership number not nil' do
        expect(subject.send(:first_membership?, true, 'blorf') ).to be_falsey
      end

      it  'false if previous membership number is nil'  do
        expect(subject.send(:first_membership?, true, nil) ).to be_falsey
        expect(subject.send(:first_membership?, true) ).to be_falsey
      end
    end

    context 'previous membership status = false' do

      it 'false if previous membership number not nil' do
        expect(subject.send(:first_membership?, false, '') ).to be_falsey
      end

      it 'true if previous membership number is nil'  do
        expect(subject.send(:first_membership?, false, nil) ).to be_truthy
        expect(subject.send(:first_membership?, false) ).to be_truthy
      end
    end

  end

end
