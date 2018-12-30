require 'rails_helper'
require 'email_spec/rspec'
require 'timecop'


LOG_DIR      = 'tmp'
LOG_FILENAME = 'testlog.txt'


RSpec.describe UserEmailAlert, type: :model do

  let(:user) { create(:user) }

  let(:config) { { days: [2, 5, 10] } }

  let(:condition) { create(:condition, config: { days: [2, 5, 10] }) }
  let(:timing)    { :on }

  let(:filepath) { File.join(Rails.root, LOG_DIR, LOG_FILENAME) }
  let(:log) { ActivityLogger.open(filepath, 'TEST', 'open', false) }


  before(:each) do
    File.delete(filepath) if File.file?(filepath)
  end

  after(:all) do
    tmpfile = File.join(Rails.root, LOG_DIR, LOG_FILENAME)
    File.delete(tmpfile) if File.exist?(tmpfile)
  end


  describe '.condition_response' do

    before(:all) do

      # define a method for MemberMailer just for this test
      MemberMailer.class_eval do
        def fake_mailer_method(_user)
          nil
        end
      end

    end

    after(:all) do
      # remove the method we added
      MemberMailer.undef_method(:fake_mailer_method)
    end


    let(:dec_1) { Time.zone.local(2018, 12, 1) }


    context 'sends_alert_this_day? is true' do

      before(:each) do
        Rails.configuration.action_mailer.delivery_method = :mailgun
        ApplicationMailer.mailgun_client.enable_test_mode!
      end

      after(:each) { ApplicationMailer.mailgun_client.disable_test_mode! }


      it 'sends alert email to user and logs a message' do
        expect(MemberMailer.fake_mailer_method(user)).to be_truthy

        num_alerts = condition.config[:days].length

        # stubbed methods:
        allow(described_class).to receive(:mailer_method).and_return(:test_email)
        allow(described_class).to receive(:send_alert_this_day?)
                                      .with(timing, config, user,)
                                      .and_return(true)
        allow(described_class).to receive(:log_msg_start).and_return('UserEmailAlert')

        # expected results:
        expect(MemberMailer).to receive(:test_email).with(user)
                                    .and_call_original
                                    .exactly(num_alerts).times
        expect(described_class).to receive(:send_alert_this_day?)
                                       .with(timing, config, user)
        expect(log).to receive(:record)
                           .exactly(1 + 2).times
                           .and_call_original

        condition.config[:days].each do | day_on |
          Timecop.freeze(dec_1 - day_on.days)
          described_class.condition_response(condition, log)
          Timecop.return

          email = ActionMailer::Base.deliveries.last
          expect(email).to deliver_to(user.email)

          expect(File.read(filepath)).to include("[info] UserEmailAlert email sent to id: #{user.id} email: #{user.email}")
        end
      end


      it 'logs an error if any error is raised or mail has errors' do
        expect(MemberMailer.fake_mailer_method(user)).to be_truthy

        num_alerts = condition.config[:days].length

        # stubbed methods:
        allow(described_class).to receive(:mailer_method).and_return(:test_email)
        allow(described_class).to receive(:send_alert_this_day?)
                                      .with(timing, config, user,)
                                      .and_return(true)

        allow_any_instance_of(Mail::Message).to receive(:deliver)
                                                    .and_raise(  Net::ProtocolError )

        # expected results:
        expect(MemberMailer).to receive(:test_email).with(user)
                                    .exactly(num_alerts).times
                                    .and_call_original

        condition.config[:days].each do | day_on |

          Timecop.freeze(dec_1 - day_on.days)
          described_class.condition_response(condition, log)
          Timecop.return

          expect(ActionMailer::Base.deliveries.size).to eq 0
          expect(File.read(filepath)).to include("[error] UserEmailAlert email ATTEMPT FAILED to id: #{user.id} email: #{user.email}")
        end
      end

    end # context 'sends_alert_this_day? is true'


    it 'does nothing when send_alert_this_day? is false for a user' do

      # stubbed methods:
      allow(described_class).to receive(:send_alert_this_day?)
                                    .with(anything, config, user)
                                    .and_return(false)

      allow(described_class).to receive(:mailer_method).and_return(:fake_mailer_method)


      # expected results:
      expect(MemberMailer).not_to receive(:fake_mailer_method).with(user)

      expect(described_class).to receive(:send_alert_this_day?)
                                     .with(anything, config, user)

      expect(log).to receive(:record)
                         .exactly(2).times
                         .and_call_original


      # actual test:
      Timecop.freeze(dec_1) do
        described_class.condition_response(condition, log)
        log.close
      end # Timecop

      expect(File.read(filepath)).not_to include "[info] UserEmailAlert alert sent to #{user.email}"

    end

  end


  describe '.send_on_day_number?' do

    let(:config) { { days: [1, 3, 5] } }

    it 'true if config[:days].include? day_number' do
      expect(described_class.send_on_day_number?(3, config)).to be_truthy
    end

    it 'false if day_number is not in config[:days]' do
      expect(described_class.send_on_day_number?(0, config)).to be_falsey
    end

    it 'false if config does not have :days as a key' do
      expect(described_class.send_on_day_number?(3, { blorf: 'blorf' })).to be_falsey
    end

  end


  it '.log_msg_start is the class name' do
    expect( described_class.log_msg_start ).to eq described_class.name
  end


  describe '.log_mail_response' do

    it 'creates the user_info string to use in the log' do
      mail_response_dbl = double("Mail::Message")
      allow(mail_response_dbl).to receive(:errors).and_return([])

      expect(UserEmailAlert).to receive(:user_info)

      described_class.log_mail_response(log, mail_response_dbl, 5, 'hello@example.com')
    end


    it 'passes the log_msg_start to the log success or failure methods' do
      mail_response_dbl = double("Mail::Message")
      allow(mail_response_dbl).to receive(:errors).and_return([])

      expect(UserEmailAlert).to receive(:log_msg_start).and_call_original
      expect(UserEmailAlert).to receive(:log_success)
          .with(log, 'UserEmailAlert', anything)

      described_class.log_mail_response(log, mail_response_dbl, 5, 'hello@example.com')
    end

    context 'no mail_response errors' do

      it 'sends log_success' do
        mail_response_dbl = double("Mail::Message")
        allow(mail_response_dbl).to receive(:errors).and_return([])

        expect(UserEmailAlert).to receive(:log_success).with(log, 'UserEmailAlert', anything)

        described_class.log_mail_response(log, mail_response_dbl, 5, 'hello@example.com')
      end
    end

    context 'with mail_response_errors' do

      it 'sends log_failure' do

        mail_response_dbl = double("Mail::Message")
        allow(mail_response_dbl).to receive(:errors).and_return([3])

        expect(UserEmailAlert).to receive(:log_failure).with(log, 'UserEmailAlert', anything)

        described_class.log_mail_response(log, mail_response_dbl, 5, 'hello@example.com')
      end
    end
  end


  describe '.log_success(log, msg_start, user_email)' do

    it 'writes info to the log with the userid and email' do
      described_class.log_success(log, 'log-start-msg', 'user-info')
      expect(File.read(filepath)).to include("[info] log-start-msg email sent user-info.")
    end
  end


  describe ".log_failure(log, msg_start, user_info_str, error = '')" do

    it 'writes an error message to the log' do
      described_class.log_failure(log, 'log-start-msg', 'user-info')
      expect(File.read(filepath)).to include("[error] log-start-msg email ATTEMPT FAILED user-info")
    end

    it 'includes error info if any error: is given' do
      described_class.log_failure(log, 'log-start-msg', 'user-info',  Net::ProtocolError)
      expect(File.read(filepath)).to include("[error] log-start-msg email ATTEMPT FAILED user-info. #{Net::ProtocolError}")
    end

    it "says 'Also see for possible info' with the Mailer log" do
      described_class.log_failure(log, 'log-start-msg', 'user-info')
      expect(File.read(filepath)).to include("Also see for possible info #{ApplicationMailer::LOG_FILE}")
    end
  end


  describe 'user_info' do

    it 'returns a string with user id and email' do
      expect(described_class.user_info(3, 'hello@example.com')).to eq 'to id: 3 email: hello@example.com'
    end
  end

  it '.send_alert_this_day?(timing, config, user) raises NoMethodError (should be defined by subclasses)' do
    config = {}
    timing = 'blorf'  # doesn't matter what this is
    expect { described_class.send_alert_this_day?(timing, config, user) }.to raise_exception NoMethodError
  end

  it '.mailer_method raises NoMethodError (should be defined by subclasses)' do
    expect { described_class.mailer_method }.to raise_exception NoMethodError
  end

end
