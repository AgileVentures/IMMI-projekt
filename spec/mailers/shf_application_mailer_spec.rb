require 'rails_helper'
require 'email_spec/rspec'


require File.join(__dir__, 'shared_email_tests')

require_relative './previews/shf_application_mailer_preview'

# Ensure that the mail can be created
#  and the subject, recipient, and greeting are correct
#
RSpec.describe ShfApplicationMailer, type: :mailer do

  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let!(:test_user) { create(:user, email: 'user@example.com') }


  describe '#app_approved' do

    let(:approved_text) { 'mailers.shf_application_mailer.app_approved.message_text' }


    let(:accepted_app) { create(:shf_application, :accepted, user: test_user) }
    let(:email_sent) { ShfApplicationMailer.app_approved(accepted_app) }

    it_behaves_like 'a successfully created email to a member',
                    I18n.t('mailers.shf_application_mailer.app_approved.subject'),
                    'user@example.com',
                    'Firstname Lastname' do
      let(:email_created) { email_sent }
    end

    it 'says your app is approved' do
      expect(email_sent).to have_body_text(I18n.t('app_approved_and_next', scope: approved_text))
    end

    describe 'has link to where to pay your membership fee' do

      it 'html part has correct link' do
        unless email_sent.html_part.nil?
          expect(email_sent.html_part.body.encoded).to have_link(user_url(accepted_app.user))
        end
      end

      it 'text part has correct link' do
        unless email_sent.text_part.nil?
          expect(email_sent.text_part).to have_body_text(user_url(accepted_app.user))
        end
      end


    end

    it 'closes with a thank you for wanting to be a member' do
      expect(email_sent).to have_body_text(I18n.t('thanks', scope: approved_text))
    end


    context 'branding license fee is not paid' do
      it 'says branding license fee payment ' do
        expect(email_sent).to have_body_text(I18n.t('h_branding_not_paid', scope: approved_text))
      end
    end


    context 'branding license fee IS paid' do

      let(:user1) { create(:user) }

      let(:co_branding_paid) {
        co = create(:company, name: 'Paid Branding Company')

        start_date, _expire_date = Company.next_branding_payment_dates(co.id)

        payment_success = Payment.order_to_payment_status('successful')

        create(:payment,
                         user: user1,
                         status: payment_success,
                         company: co,
                         payment_type: Payment::PAYMENT_TYPE_BRANDING,
                         notes: 'this company has paid their branding licensing fee on time',
                         start_date: start_date,
                         expire_date: Time.zone.today + 1.day) # so that is has not expired

        co }


      def make_branding_payment(a_company)
        start_date, _expire_date = Company.next_branding_payment_dates(a_company.id)
        create(:payment, user: user1, status: payment_success, company: a_company,
               payment_type: Payment::PAYMENT_TYPE_BRANDING,
               notes: 'this company has paid their branding licensing fee on time',
               start_date: start_date,
               expire_date: Time.zone.today + 1.day) # so that is has not expired
      end


      let(:accepted_app_branding_paid) {
        create(:shf_application, :accepted, user: user1)
      }

      let(:email_sent_branding_paid) { ShfApplicationMailer.app_approved(accepted_app_branding_paid) }


      it 'does not say branding license fee must be paid next' do
        expect(email_sent_branding_paid).not_to have_body_text(I18n.t('how_to_pay_brandingfee', scope: approved_text))
      end

    end
  end


  describe '#acknowledge_received' do

    let(:received_app) { create(:shf_application, user: test_user) }
    let(:email_sent) { ShfApplicationMailer.acknowledge_received(received_app) }

    it_behaves_like 'a successfully created email',
                    I18n.t('mailers.shf_application_mailer.acknowledge_received.subject'),
                    'user@example.com',
                    'Firstname Lastname' do
      let(:email_created) { email_sent }
    end

  end


  it 'has a previewer' do
    expect(ShfApplicationMailerPreview).to be
  end

end
