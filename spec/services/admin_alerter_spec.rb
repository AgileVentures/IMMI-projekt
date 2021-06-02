require 'rails_helper'

RSpec.describe AdminAlerter do
  let(:subject) { described_class.instance }

  let(:mock_email_msg) { instance_double('Mail::Message', deliver: true) }
  let!(:new_membership) { build(:membership) }
  let!(:given_user) { new_membership.user }
  let(:branding_fee_payment) { build(:h_branding_fee_payment, user: given_user) }
  let(:membership_payment) { build(:membership_fee_payment, user: given_user) }


  describe 'new_membership_granted' do

    describe 'deliver_email:' do

      describe 'default value of deliver_email: is our send_email value' do

        it 'set to false' do
          allow(subject).to receive(:send_email).and_return(false)
          expect(subject).to receive(:alert_admin_if_first_membership_with_good_co)
                               .with(given_user, deliver_email: false)
          subject.new_membership_granted(given_user)
        end

        it 'set to true' do
          allow(subject).to receive(:send_email).and_return(true)
          expect(subject).to receive(:alert_admin_if_first_membership_with_good_co)
                               .with(given_user, deliver_email: true)
          subject.new_membership_granted(given_user)
        end
      end
    end

    it 'calls alert_admin_if_first_membership_with_good_co with the new member and deliver_email: ' do
      expect(subject).to receive(:alert_admin_if_first_membership_with_good_co)
                                   .with(given_user, deliver_email: false)
      subject.new_membership_granted(given_user, deliver_email: false)
    end
  end

  describe 'payment_made' do

    describe 'deliver_email:' do

      describe 'default value of deliver_email: is our send_email value' do

        it 'set to false' do
          allow(subject).to receive(:send_email).and_return(false)
          expect(subject).to receive(:alert_admin_if_first_membership_with_good_co)
                               .with(given_user, deliver_email: false)
          subject.payment_made(branding_fee_payment)
        end

        it 'set to true' do
          allow(subject).to receive(:send_email).and_return(true)
          expect(subject).to receive(:alert_admin_if_first_membership_with_good_co)
                               .with(given_user, deliver_email: true)
          subject.payment_made(branding_fee_payment)
        end
      end
    end


    context 'is a h-markt branding license fee' do
      it 'calls alert_admin_if_first_membership_with_good_co with the payor (user) of the payment' do
        expect(subject).to receive(:alert_admin_if_first_membership_with_good_co)
                             .with(given_user, deliver_email: true)
        subject.payment_made(branding_fee_payment)
      end
    end

    context 'is a membership fee' do
      it 'calls alert_admin_if_first_membership_with_good_co with the payor (user) of the payment' do
        expect(subject).to receive(:alert_admin_if_first_membership_with_good_co)
                             .with(given_user, deliver_email: true)
        subject.payment_made(membership_payment)
      end
    end
  end


  describe 'alert_admin_if_first_membership_with_good_co' do

    it 'does nothing if deliver_email is false' do
      expect(AdminMailer).not_to receive(:new_membership_granted_co_hbrand_paid)
      subject.alert_admin_if_first_membership_with_good_co(given_user, deliver_email: false)
    end


    describe 'deliver_email:' do
      before(:each) do
        allow(new_membership).to receive(:first_membership?).and_return(true)
        allow(given_user).to receive(:memberships).and_return([new_membership])
        allow(given_user).to receive(:membership_status).and_return(:current_member)
        allow(given_user).to receive(:has_company_in_good_standing?).and_return(true)
      end

      describe 'default value of deliver_email: is our send_email value' do

        it 'set to false' do
          allow(subject).to receive(:send_email).and_return(false)
          expect(AdminMailer).not_to receive(:new_membership_granted_co_hbrand_paid)
          subject.alert_admin_if_first_membership_with_good_co(given_user)
        end

        it 'set to true' do
          allow(subject).to receive(:send_email).and_return(true)
          expect(AdminMailer).to receive(:new_membership_granted_co_hbrand_paid).and_return(mock_email_msg)
          subject.alert_admin_if_first_membership_with_good_co(given_user)
        end
      end
    end

    context 'deliver_email is true' do
      before(:each) { allow(subject).to receive(:send_email).and_return(true) }

      context 'is the first membership' do
        before(:each) do
          allow(new_membership).to receive(:first_membership?).and_return(true)
          allow(given_user).to receive(:memberships).and_return([new_membership])
        end

        context 'user belongs to a company in good standing' do
          before(:each) do
            allow(given_user).to receive(:membership_status).and_return(:current_member)
            allow(given_user).to receive(:has_company_in_good_standing?).and_return(true)
          end

          it 'delivers new_membership_granted_co_hbrand_paid to the Admin' do
            expect(AdminMailer).to receive(:new_membership_granted_co_hbrand_paid)
                                     .with(given_user).and_return(mock_email_msg)
            subject.alert_admin_if_first_membership_with_good_co(given_user)
          end
        end
      end

      it 'does nothing if is not the first membership' do
        allow(new_membership).to receive(:first_membership?).and_return(false)
        allow(given_user).to receive(:memberships).and_return([new_membership, build(:membership, user: given_user)])

        expect(AdminMailer).not_to receive(:new_membership_granted_co_hbrand_paid)
        subject.alert_admin_if_first_membership_with_good_co(given_user)
      end

      it 'does nothing if the user does not belong to a company in good standing' do
        allow(new_membership).to receive(:first_membership?).and_return(true)
        allow(given_user).to receive(:has_company_in_good_standing?).and_return(false)

        expect(AdminMailer).not_to receive(:new_membership_granted_co_hbrand_paid)
        subject.alert_admin_if_first_membership_with_good_co(given_user)
      end
    end
  end
end
