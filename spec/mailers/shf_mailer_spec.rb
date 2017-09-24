require 'rails_helper'

require 'email_spec'
require 'email_spec/rspec'

#  shared examples for RSpec below

shared_examples 'delivery is OK' do

  # Need to check these expectations within the same it block else .deliveries will not be accurate
  it 'is delivered (delivery count, delivered id OK)' do
    expect(email_response.message_id).not_to be_nil

    delivered = ShfMailer.deliveries
    expect(delivered.count).to eq 1
    expect(email_response[:message_id]).to eq(delivered.first[:message_id])
  end

end

#----------------------------------------

RSpec.describe ShfMailer, type: :mailer do

  include Devise::Mailers::Helpers

  TEST_TEMPLATE = 'empty_template'


  describe '#mailgun_client' do

    let(:mg_client) { subject.mailgun_client }

    it 'is never nil' do
      expect(mg_client).not_to be_nil
    end

    it 'is a Mailgun::Client.new' do
      expect(mg_client).to be_an_instance_of(Mailgun::Client)
    end

  end


  describe '#message_builder' do

    let(:mg_builder) { subject.message_builder }

    it 'is never nil' do
      expect(mg_builder).not_to be_nil
    end

    it 'is a Mailgun::MessageBuilder.new' do
      expect(mg_builder).to be_an_instance_of(Mailgun::MessageBuilder)
    end

    it "default from address is ENV['SHF_SENDER_EMAIL']" do
      expect(mg_builder.message[:from]).to eq([ENV['SHF_SENDER_EMAIL']])
    end

  end


  describe '#domain' do

    it 'can be nil (which should then rightly mean an error response from Mailgun)' do

      stub_const('ENV', ENV.to_hash)
      ENV.delete('MAILGUN_DOMAIN')

      expect(subject.domain).to be_nil
    end


    it 'can be some value (not nil)' do
      stub_const('ENV', ENV.to_hash.merge('MAILGUN_DOMAIN' => 'blorf.com'))
      expect(subject.domain).to eq 'blorf.com'
    end

  end


  describe 'content is correct' do

    before(:all) do
      @recipient = create(:user)
      # we can do this because ShfMailer < Devise::Mailer
      @email = ShfMailer.reset_password_instructions(@recipient, :reset_password_instructions)
    end

    it "should be set to be delivered to the email passed in" do
      expect(@email).to deliver_to(@recipient.email)
    end

    it "should have the correct subject" do
      initialize_from_record(@recipient) # required to use Devise::Mailers::Helpers subject_for
      expect(@email).to have_subject(subject_for(:reset_password_instructions))
    end

    it "default from address is ENV['SHF_NOREPLY_EMAIL']" do
      expect(@email).to be_delivered_from(ENV['SHF_NOREPLY_EMAIL'])
    end

  end


  describe 'content is correct for the locale' do

    before(:all) { @orig_local = I18n.locale }

    after(:all) { I18n.locale = @orig_local }

    let(:test_user) { create(:user) }

    it ':en' do
      I18n.locale = :en
      email = ShfMailer.reset_password_instructions(test_user, :reset_password_instructions)
      expect(email).to have_subject(I18n.t('devise.mailer.reset_password_instructions.subject', locale: :en))
    end

    it ':sv' do
      I18n.locale = :sv
      email = ShfMailer.reset_password_instructions(test_user, :reset_password_instructions)
      expect(email).to have_subject(I18n.t('devise.mailer.reset_password_instructions.subject', locale: :sv))
    end

  end


  describe 'use :mailgun delivery method (test mode)' do

    before(:all) { Rails.configuration.action_mailer.delivery_method = :mailgun
    ShfMailer.mailgun_client.enable_test_mode!
    }

    after(:all) { ShfMailer.mailgun_client.disable_test_mode! }


    describe 'simple test email (no attachments)' do

      it_behaves_like 'delivery is OK' do
        let(:email_response) {
          result = subject.mail(to: 'recipient@example.com', subject: "Test email from SHF", template_name: TEST_TEMPLATE)
          result.deliver
        }
      end

    end


    describe 'email with attachments' do

      it_behaves_like 'delivery is OK' do
        let(:email_response) {

          attachment1 = {
              content: file_fixture('diploma.pdf'),
              mime_type: 'application/pdf',
          }
          attachment2 = {
              content: file_fixture('microsoft-word.docx'),
              mime_type: 'application/docx',
          }

          result = subject.mail(to: 'recipient@example.com',
                                subject: 'Test email with attachment',
                                template_name: TEST_TEMPLATE,
                                attachments: [attachment1, attachment2])
          result.deliver
        }
      end

    end


  end

end
