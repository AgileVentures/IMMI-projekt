require 'rails_helper'

RSpec.describe Memberships::MembershipActions do

  let(:mock_log) { instance_double("ActivityLogger") }

  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:warn)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)
  end


  describe '.for_user?' do
    before(:each) { allow(described_class).to receive(:log_message_success).and_return('MembershipAction was successful.') }


    describe 'checking other keyword arguments' do
      before(:each) { allow(described_class).to receive(:accomplish_actions).and_return(true) }

      it 'checks to see if the other keyword arguments are valid' do
        expect(described_class).to receive(:other_keyword_args_valid?)
                                     .with(some_other_arg: 'some value').and_return(true)

        described_class.for_user('user', some_other_arg: 'some value')
      end
    end

    context 'other keyword args are valid' do
      before(:each) do
        allow(described_class).to receive(:other_keyword_args_valid?)
                                     .and_return(true)
      end

      it 'opens the log file and starts writing' do
        expect(ActivityLogger).to receive(:open)
                                    .with(described_class.log_filename,
                                          described_class.name,
                                          described_class.log_message_success,
                                          false)
        described_class.for_user('user')
      end

      it 'calls accomplish_actions to do whatever needs to be done for this action' do
        expect(described_class).to receive(:accomplish_actions)
                                    .with('user',
                                          send_email: true,
                                          this_arg: 'this_value',
                                          that_arg: 'that_value')
        described_class.for_user('user', send_email: true, this_arg: 'this_value', that_arg: 'that_value')
      end

      it 'writes success message only if actions were successful' do
        allow(described_class).to receive(:accomplish_actions)
                                    .and_return(true)
        expect(mock_log).to receive(:info).with("#{described_class.log_message_success}: \"some_user\"")
        described_class.for_user('some_user')

        allow(described_class).to receive(:accomplish_actions)
                                    .and_return(false)
        expect(mock_log).not_to receive(:info).with("#{described_class.log_message_success}: \"some_user\"")
        described_class.for_user('some_user')
      end
    end

  end


  describe '.other_keyword_args_valid?' do
    it 'raises an error saying the subclasses must implement this' do
      expect { described_class.other_keyword_args_valid?({}) }.to raise_error(NoMethodError)
    end
  end


  describe '.accomplish_actions' do
    it 'raises an error saying the subclasses must implement this' do
      expect { described_class.accomplish_actions('user') }.to raise_error(NoMethodError)
    end
  end


  describe '.log_message_success' do
    it 'raises an error saying the subclasses must implement this' do
      expect { described_class.log_message_success }.to raise_error(NoMethodError)
    end
  end


  describe '.log_filename' do
    it 'logs to the MembershipUpdater logfilename' do
      expect(LogfileNamer).to receive(:name_for).with(MembershipStatusUpdater.name)
      described_class.log_filename
    end
  end
end
