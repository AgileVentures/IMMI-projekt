require 'rails_helper'


RSpec.describe AlertLogger do

  let(:mock_log) { instance_double("ActivityLogger") }

  let(:alert) { MembershipExpireAlert.instance }
  let(:subject) { described_class.new(mock_log, alert) }


  before(:each) do
    allow(ActivityLogger).to receive(:open).with(anything, 'TEST', 'open', false)
                                 .and_return(mock_log)
  end


  describe '.log_success' do

    it 'log msg is: <Alert class name> email sent <result of the success_method> <error message>' do
      expect(alert).to receive(:success_str).with('some-argument').and_return('success!')
      expect(subject).to receive(:msg_start).and_call_original

      expect(mock_log).to receive(:info).with(/MembershipExpireAlert email sent success!/)
      subject.log_success('some-argument')
    end

    it 'calls the success method to get the information to show in the returned string' do
      allow(subject).to receive(:msg_start).and_call_original

      expect(alert).to receive(:success_str).with('some-arg').and_return('success method result')
      expect(mock_log).to receive(:info).with("MembershipExpireAlert email sent success method result.")
      subject.log_success('some-arg')
    end


    it 'can specify a custom success method to call' do

      # define a method for this alert just for this test
      MembershipExpireAlert.class_eval do
        def custom_success_str_method(args)
          "Detta är #{args}!"
        end
      end

      alert_logger_with_custom_success_method = described_class.new(mock_log, alert, success_info_method: :custom_success_str_method)

      expect(alert).to receive(:custom_success_str_method).with('some-argument').and_call_original

      expect(mock_log).to receive(:info).with(/(.*)MembershipExpireAlert (.*) Detta är some-argument!/)
      alert_logger_with_custom_success_method.log_success('some-argument')

      # remove the method we added
      MembershipExpireAlert.undef_method(:custom_success_str_method)
    end


    describe 'handles a variable number of arguments (other than error:)' do

      it 'two args' do

        # define a method for MembershipExpireAlert just for this test
        MembershipExpireAlert.class_eval do
          def custom_success_str_method(arg1, arg2)
            "Detta är #{arg1} och #{arg2}!"
          end
        end

        alert_logger_custom_str = described_class.new(mock_log, alert, success_info_method: :custom_success_str_method)

        expect(alert).to receive(:custom_success_str_method).with(1, 'big').and_call_original

        expect(mock_log).to receive(:info).with(/Detta är 1 och big!/)
        alert_logger_custom_str.log_success(1, 'big')

        # remove the method we added
        MembershipExpireAlert.undef_method(:custom_success_str_method)
      end


      it 'five args' do

        five_args = [1, 2, 3, 4, 5]

        # define a method for MembershipExpireAlert just for this test
        MembershipExpireAlert.class_eval do
          def custom_success_str_method(*args)
            "Detta är #{args.join(', ')}"
          end
        end

        alert_logger_custom_str = described_class.new(mock_log, alert, success_info_method: :custom_success_str_method)

        expect(alert).to receive(:custom_success_str_method).with(five_args).and_call_original

        expect(mock_log).to receive(:info).with(/Detta är 1, 2, 3, 4, 5/)
        alert_logger_custom_str.log_success(five_args)

        # remove the method we added
        MembershipExpireAlert.undef_method(:custom_success_str_method)
      end

    end

  end


  describe '.log_failure' do

    it 'log msg is: <Alert class name> email ATTEMPT FAILED <result of the failure_method> <error message>' do
      expect(alert).to receive(:failure_str).with('some-arg').and_return('failure method result')
      expect(subject).to receive(:msg_start).and_call_original

      expect(mock_log).to receive(:error).with(/MembershipExpireAlert email ATTEMPT FAILED failure method result/)
      subject.log_failure('some-arg', error: Net::ProtocolError)
    end

    it 'calls the failure method to get the information to show in the returned string' do
      allow(subject).to receive(:msg_start).and_call_original

      expect(alert).to receive(:failure_str).with('some-arg').and_return('failure method result')
      expect(mock_log).to receive(:error).with(/MembershipExpireAlert email ATTEMPT FAILED failure method result\.  Also see for possible info (.*)log\/test_Class.log/)
      subject.log_failure('some-arg')
    end

    it 'includes error info if any error is given' do
      allow(alert).to receive(:failure_str).with('some-arg').and_return('failure method result')
      expect(subject).to receive(:msg_start).and_call_original

      expect(mock_log).to receive(:error).with(/(.*) Net::ProtocolError/)
      subject.log_failure('some-arg', error: Net::ProtocolError)
    end


    it "says 'Also see for possible info' with the Mailer log" do
      expect(alert).to receive(:failure_str).with('some-arg').and_return('failure method result')
      expect(subject).to receive(:msg_start).and_call_original

      expect(mock_log).to receive(:error).with(/Also see for possible info #{ApplicationMailer.logfile_name}/)
      subject.log_failure('some-arg', error: Net::ProtocolError)
    end


    it 'can specify a custom method to call for the failure info callback' do

      # define a method for MembershipExpireAlert just for this test
      MembershipExpireAlert.class_eval do
        def custom_failure_str_method(args)
          "Detta är ett stort #{args}"
        end
      end

      alert_logger_custom_str = described_class.new(mock_log, alert, failure_info_method: :custom_failure_str_method)

      expect(alert).to receive(:custom_failure_str_method).with('misslyckande').and_call_original

      expect(mock_log).to receive(:error).with(/(.*)MembershipExpireAlert (.*) Detta är ett stort misslyckande./)
      alert_logger_custom_str.log_failure('misslyckande')

      # remove the method we added
      MembershipExpireAlert.undef_method(:custom_failure_str_method)
    end


    describe 'handles a variable number of arguments (other than error:)' do

      it 'two args' do

        # define a method for MembershipExpireAlert just for this test
        MembershipExpireAlert.class_eval do
          def custom_failure_str_method(arg1, arg2)
            "Dessa är dåliga: #{arg1} och #{arg2}!"
          end
        end

        alert_logger_custom_str = described_class.new(mock_log, alert, failure_info_method: :custom_failure_str_method)

        expect(alert).to receive(:custom_failure_str_method).with(1, 'bug').and_call_original

        expect(mock_log).to receive(:error).with(/(.*)MembershipExpireAlert (.*) Dessa är dåliga: 1 och bug!./)

        alert_logger_custom_str.log_failure(1, 'bug', error: Net::ProtocolError)

        # remove the method we added
        MembershipExpireAlert.undef_method(:custom_failure_str_method)
      end


      it 'five args ([1,2,3,4,5]) and error: ' do

        five_args = [1, 2, 3, 4, 5]

        # define a method for MembershipExpireAlert just for this test
        MembershipExpireAlert.class_eval do
          def custom_failure_str_method(*args)
            "Dessa är dåliga: #{args.join(', ')}"
          end
        end

        alert_logger_custom_str = described_class.new(mock_log, alert, failure_info_method: :custom_failure_str_method)

        expect(alert).to receive(:custom_failure_str_method).with(five_args).and_call_original

        expect(mock_log).to receive(:error).with(/(.*)MembershipExpireAlert (.*) Dessa är dåliga: 1, 2, 3, 4, 5. Net::ProtocolError/)

        alert_logger_custom_str.log_failure(five_args, error: Net::ProtocolError)

        # remove the method we added
        MembershipExpireAlert.undef_method(:custom_failure_str_method)
      end

    end

  end

end
