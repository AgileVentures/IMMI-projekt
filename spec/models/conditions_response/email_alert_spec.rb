require 'rails_helper'
require 'email_spec/rspec'
require 'timecop'

require 'shared_context/stub_email_rendering'


RSpec.describe EmailAlert, type: :model do

  let(:mock_log) { instance_double("ActivityLogger") }

  # set subject appropriately since it's a Singleton
  let(:subject) { described_class.instance }

  let(:user) { create(:user) }

  let(:config) { { days: [2, 5, 10] } }

  let(:condition) { create(:condition, config: { days: [2, 5, 10] }) }
  let(:timing) { :on }

  let(:dec_1) { Time.zone.local(2018, 12, 1) }

  let(:users) do
    [create(:user, first_name: 'u1'),
     create(:user, first_name: 'u2')]
  end


  describe '.condition_response' do

    it 'gets the config from the condition' do
      # stubbed methods:
      allow(subject).to receive(:entities_to_check)
                                    .and_return([])

      allow(subject).to receive(:send_alert_this_day?)
                                    .and_return(true)

      allow(subject).to receive(:send_email)
                                    .with(anything, mock_log)

      # expected results:
      expect(described_class).to receive(:get_config)

      # actual test:
      Timecop.freeze(dec_1) do
       subject.condition_response(condition, mock_log)
      end
    end

    it 'gets the timing from the condition' do
      # stubbed methods:
      allow(subject).to receive(:entities_to_check)
                                    .and_return([])

      allow(subject).to receive(:send_alert_this_day?)
                                    .and_return(true)

      allow(subject).to receive(:send_email)
                                     .with(anything, mock_log)

      # expected results:
      expect(described_class).to receive(:get_timing)

      # actual test:
      Timecop.freeze(dec_1) do
       subject.condition_response(condition, mock_log)
      end
    end


    it 'calls process_entities' do

      # stubbed methods:
      allow(subject).to receive(:entities_to_check)
                                             .and_return(users)

      # expected results:
      expect(subject).to receive(:process_entities)
                                             .and_return(true)

      # actual test:
      Timecop.freeze(dec_1) do
       subject.condition_response(condition, mock_log)
      end

    end

  end


  describe 'process_entities' do

    it 'loops through entities_to_check and calls take_action on each' do

      # stub this method
      allow(subject).to receive(:take_action).and_return(true)

      expect(subject).to receive(:take_action).exactly(users.size).times

      # actual test:
      Timecop.freeze(dec_1) do
        subject.process_entities(users, mock_log)
      end
    end
  end


  describe 'take_action' do

    let(:entity) { create(:member_with_membership_app) }

    it 'calls send_email for the entity and log if send_alert_this_day? is true' do

      # stubbed methods:
      allow(subject).to receive(:send_alert_this_day?)
                                             .with(timing, config, anything)
                                             .and_return(true)

      # expected results:
      expect(subject).to receive(:send_alert_this_day?)
                                              .with(timing, config, anything)
                                              .once
      expect(subject).to receive(:send_email)
                                              .with(anything, mock_log)
                                              .once

      # actual test:
      Timecop.freeze(dec_1) do
        subject.timing = timing
        subject.config = config
        subject.take_action(entity, mock_log)
      end
    end

    it 'does nothing when send_alert_this_day? is false for a user' do

      # stubbed methods:
      allow(subject).to receive(:send_alert_this_day?)
                                             .with(anything, config, user)
                                             .and_return(false)

      # expected results:
      expect(subject).to receive(:send_alert_this_day?)
                                              .with(anything, config, anything)
                                              .once

      expect(subject).to receive(:send_email).never

      # actual test:
      Timecop.freeze(dec_1) do
        subject.timing = timing
        subject.config = config
        subject.take_action(entity, mock_log)
      end # Timecop

    end # it 'does nothing when send_alert_this_day? is false for a user'

  end


  it '.entities_to_check raises NoMethodError (subclasses should implement)' do
    expect {subject.entities_to_check }.to raise_exception NoMethodError
  end


  it '.mailer_class raises NoMethodError (subclasses should implement)' do
    expect {subject.mailer_class }.to raise_exception NoMethodError
  end


  it '.mailer_args raises NoMethodError (subclasses should implement)' do
    expect {subject.mailer_args(create(:user)) }.to raise_exception NoMethodError
  end


  describe '.send_email' do

    include_context 'stub email rendering'


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

    before(:each) do
      Rails.configuration.action_mailer.delivery_method = :mailgun
      ApplicationMailer.mailgun_client.enable_test_mode!

      allow(Memberships::MembershipActions).to receive(:for_user)
                                                        .and_return(true)
    end

    after(:each) { ApplicationMailer.mailgun_client.disable_test_mode! }

    let(:entity) { build(:member) }


    it 'sends alert email to user and logs a message' do
      expect(MemberMailer.fake_mailer_method(user)).to be_truthy

      # stubbed methods:
      allow(subject).to receive(:mailer_class)
                                    .and_return(MemberMailer)
      allow(subject).to receive(:mailer_args)
                                    .and_return([entity])
      allow(subject).to receive(:mailer_method).and_return(:test_email)

      allow(subject).to receive(:success_str).with(entity)
                                    .and_return('succeeded with entity')

      # expected results:
      expect(MemberMailer).to receive(:test_email).with(entity)
                                  .and_call_original

      expect(subject).to receive(:log_mail_response)

      Timecop.freeze(dec_1)
      subject.send_email(entity, mock_log)
      Timecop.return

      email = ActionMailer::Base.deliveries.last
      expect(email).to deliver_to(entity.email)
    end


    it 'does not send email if an error is raised or mail has errors' do
      subject.create_alert_logger(mock_log)

      expect(MemberMailer.fake_mailer_method(user)).to be_truthy

      # stubbed methods:
      allow(subject).to receive(:mailer_class)
                            .and_return(MemberMailer)
      allow(subject).to receive(:mailer_args)
                            .and_return([entity])
      allow(subject).to receive(:mailer_method).and_return(:test_email)

      allow(subject).to receive(:failure_str).with(entity)
                            .and_return('failed with entity')

      allow_any_instance_of(Mail::Message).to receive(:deliver)
                                                  .and_raise(Net::ProtocolError)

      # expected results:
      expect(MemberMailer).to receive(:test_email).with(entity)
                                  .and_call_original
      expect(mock_log).to receive(:error).with(/EmailAlert email ATTEMPT FAILED failed with entity\. Net::ProtocolError Also see for possible info/)

      Timecop.freeze(dec_1)
      subject.send_email(entity, mock_log)
      Timecop.return

      expect(ActionMailer::Base.deliveries.size).to eq 0
    end

  end


  describe '.mail_message' do

    let(:entity) { create(:company) }

    it 'calls mailer_args to get the arguments' do

      # stubbed methods:
      allow(subject).to receive(:mailer_method).and_return(:test_email)
      allow(subject).to receive(:mailer_class).and_return(MemberMailer)

      expect(subject).to receive(:mailer_args).with(entity)

     subject.mail_message(entity)
    end

    it 'calls mailer_class to get the mailer class' do
      # stubbed methods:
      allow(subject).to receive(:mailer_method).and_return(:test_email)
      allow(subject).to receive(:mailer_class).and_return(MemberMailer)
      allow(subject).to receive(:mailer_args).and_return([entity])

      expect(subject).to receive(:mailer_class)

     subject.mail_message(entity)
    end

    it 'sends the mailer_method to the mailer_class with the arguments' do
      # stubbed methods:
      allow(subject).to receive(:mailer_method).and_return(:test_email)
      allow(subject).to receive(:mailer_class).and_return(MemberMailer)
      allow(subject).to receive(:mailer_args).and_return([entity])

      expect(MemberMailer).to receive(:test_email).with(entity)

     subject.mail_message(entity)
    end

  end


  describe '.send_on_day_number?' do

    let(:config) { { days: [1, 3, 5] } }

    it 'true if config[:days].include? day_number' do
      expect(subject.send_on_day_number?(3, config)).to be_truthy
    end

    it 'false if day_number is not in config[:days]' do
      expect(subject.send_on_day_number?(0, config)).to be_falsey
    end

    it 'false if config does not have :days as a key' do
      expect(subject.send_on_day_number?(3, { blorf: 'blorf' })).to be_falsey
    end

  end


  describe '.log_mail_response' do

    let(:entity) { create(:user) }

    context 'no mail_response errors (successful)' do

      it 'sends log_success to the alert logger' do

        subject.create_alert_logger(mock_log)

        mail_response_dbl = double("Mail::Message")
        allow(mail_response_dbl).to receive(:errors).and_return([])

        expect_any_instance_of(AlertLogger).to receive(:log_success)

        subject.log_mail_response(mock_log, mail_response_dbl, entity)

      end
    end


    context 'with mail_response_errors (failure)' do

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


      it 'sends log_failure' do
        subject.create_alert_logger(mock_log)

        mail_response_dbl = double("Mail::Message")
        allow(mail_response_dbl).to receive(:errors).and_return([3])

        expect_any_instance_of(AlertLogger).to receive(:log_failure)

        subject.log_mail_response(mock_log, mail_response_dbl, entity)
      end

    end
  end


  it '.success_str raises NoMethodError (should be defined by subclasses)' do
    expect{subject.success_str([])}.to raise_exception NoMethodError
  end


  it '.failure_str raises NoMethodError (should be defined by subclasses)' do
    expect{subject.failure_str([])}.to raise_exception NoMethodError
  end


  it '.send_alert_this_day?(timing, config, user) raises NoMethodError (should be defined by subclasses)' do
    config = {}
    timing = 'blorf' # doesn't matter what this is
    expect {subject.send_alert_this_day?(timing, config, user) }.to raise_exception NoMethodError
  end

  it '.mailer_method raises NoMethodError (should be defined by subclasses)' do
    expect {subject.mailer_method }.to raise_exception NoMethodError
  end

end
