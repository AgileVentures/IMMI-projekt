require 'rails_helper'

require 'email_spec'
require 'email_spec/rspec'

require File.join(__dir__, 'shared_email_tests')



shared_examples 'delivery is OK' do

  # Need to check these expectations within the same it block else .deliveries will not be accurate
  it 'is delivered (delivery count, delivered id OK)' do
    expect(email_response.message_id).not_to be_nil

    delivered = ApplicationMailer.deliveries
    expect(delivered.count).to eq 1
    expect(email_response[:message_id]).to eq(delivered.first[:message_id])
  end

end

#----------------------------------------

RSpec.describe ApplicationMailer, type: :mailer do


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

    it 'can be nil (which would then rightly mean an error response from Mailgun)' do

      stub_const('ENV', ENV.to_hash)
      ENV.delete('MAILGUN_DOMAIN')

      expect(subject.domain).to be_nil
    end


    it 'can be some value (not nil)' do
      stub_const('ENV', ENV.to_hash.merge('MAILGUN_DOMAIN' => 'blorf.com'))
      expect(subject.domain).to eq 'blorf.com'
    end

  end


  describe 'header info is correct' do

    before(:each) do
      @test_user = create(:user)
      @email = ApplicationMailer.test_email(@test_user)
    end

    it "should be set to be delivered to the email passed in" do
      expect(@email).to deliver_to(@test_user.email)
    end

    it "should have the correct subject" do
      expect(@email).to have_subject(I18n.t('mailers.application_mailer.greeting', greeting_name: @test_user.full_name))
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { @email.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) {  @email }
    end

  end


  describe 'greeting is correct for the locale' do

    let(:test_user) { create(:user) }

    it ':en' do
      I18n.locale = :en
      email = ApplicationMailer.test_email(test_user)
      expect(email).to have_subject(I18n.t('mailers.application_mailer.greeting', greeting_name: test_user.full_name, locale: :en))
    end

    it ':sv' do
      I18n.locale = :sv
      email = ApplicationMailer.test_email(test_user)
      expect(email).to have_subject(I18n.t('mailers.application_mailer.greeting', greeting_name: test_user.full_name, locale: :sv))
    end

  end


  describe 'use :mailgun delivery method (test mode)' do

    before(:each) { Rails.configuration.action_mailer.delivery_method = :mailgun
    ApplicationMailer.mailgun_client.enable_test_mode!
    }

    after(:each) { ApplicationMailer.mailgun_client.disable_test_mode! }


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


  describe 'logs Mailgun errors', vcr: { cassette_name: 'mailgun', record: :none } do

    # do not actually hit the net; mock the responses from the vcr file instead
    before(:each) do

      @orig_delivery_method = ApplicationMailer.delivery_method
      ApplicationMailer.delivery_method = :mailgun

      WebMock.disable_net_connect!(allow_localhost: true)
    end

    after(:each) do
      ApplicationMailer.delivery_method = @orig_delivery_method
      WebMock.allow_net_connect!(allow_localhost: true)
    end


    # return the number of matches in the file.
    # Don't read the entire file into memory;
    # read it only (num_lines_per_batch) lines at a time
    def num_matches_in_file(fname, match_regexp)

      num_lines_per_batch = 5000

      num_matched = 0

      if File.exist? fname
        File.open(fname, "r") do |f|

          # use an enumerator to read just (num_lines_per_batch) lines at a time
          f.lazy.each_slice(num_lines_per_batch) do |lines|

            num_matched += lines.count { |line| line.match(match_regexp) }

          end

        end
      else
        num_matched = 0
      end

      num_matched
    end


    it 'will write to the Mailgun log file if there was a problem sending info to Mailgun' do

      test_user = create(:user)
      mail_to_send = ApplicationMailer.test_email(test_user)

      log_fname = ApplicationMailer::LOG_FILE

      mailgun_error_regexp = /\s+Could not send email via mailgun at/
      vcr_error_regexp     = /An HTTP request has been made that VCR does not know how to handle/

      before_mailgun_errors = num_matches_in_file(log_fname, mailgun_error_regexp)
      before_vcr_errors     = num_matches_in_file(log_fname, vcr_error_regexp)

      # this is a mocked post and response that will return an error from the vcr cassette file
      expect{mail_to_send.deliver_now}.to raise_error(Mailgun::CommunicationError)

      after_mailgun_errors = num_matches_in_file(log_fname, mailgun_error_regexp)
      after_vcr_errors     = num_matches_in_file(log_fname, vcr_error_regexp)

      expect(after_mailgun_errors - before_mailgun_errors).to eq 1
      expect(after_vcr_errors - before_vcr_errors).to eq 0
    end

  end

end
