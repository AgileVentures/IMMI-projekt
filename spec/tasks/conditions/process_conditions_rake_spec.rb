require 'rails_helper'
require 'shared_context/rake'

RSpec.describe 'conditions/process_conditions shf:process_conditions', type: :task do

  include_context 'rake'

  EXPECTED_PROCESSING_EXCEPTION_LOG_ENTRY = 'Exception: uninitialized constant ' +
                                            'AnInvalidClass:  #<NameError: ' +
                                            'uninitialized constant AnInvalidClass>'

  EXPECTED_SLACK_EXCEPTION_LOG_ENTRIES =
      [
        'Slack::Notifier::APIError Exception:',
        'Slack Notifications turned off! Condition processing continuing without it.',
        'Retrying the previous condition...'
      ]

  let(:filepath) { LogfileNamer.name_for(Condition) }

  let(:mock_log) { instance_double("ActivityLogger") }

  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)

    File.delete(filepath) if File.file?(filepath)
  end

  after(:each) do
    File.delete(filepath) if File.file?(filepath)
  end


  let(:valid_conditions) do
    [{ class_name: 'HBrandingFeeDueAlert',
       timing:     :after,
       config:     { days: [2, 9, 14, 30, 60] } },
     { class_name: 'HBrandingFeeWillExpireAlert',
        timing:     :before,
        config:     { days: [2, 9, 14, 30, 60] } }
    ]
  end

  let(:invalid_condition) do
    [{ class_name: 'AnInvalidClass', # must sort _before_ other (valid) condition class names
       timing:     :after,
       config:     { days: [2, 9, 14, 30, 60] } },
    ]
  end

  describe 'normal processing' do

    before(:each) { Condition.create!(valid_conditions) }

    it 'logs all conditions processed and indicates no errors' do

      # stub out the Slack notification methods
      allow(SHFNotifySlack).to receive(:notification)
                                   .and_return(true)

      # should never create a SlackNotifier during this test
      expect(Slack::Notifier).not_to receive(:new)

      valid_conditions.each do | condition|
        expect(mock_log).to receive(:info).with(/#{condition[:class_name]}/)
      end

      expect(mock_log).not_to receive(:error)

      expect { subject.invoke }.not_to raise_error
    end
  end

  describe 'exception handling' do

    before(:each) { Condition.create!(valid_conditions) }

    describe 'Slack Notification failure' do

      it 'logs the notification error but keeps processing all conditions' do

        # Slack notification error will be raised:
        allow(SHFNotifySlack).to receive(:notification)
                                     .and_raise(Slack::Notifier::APIError)

        # should never create a SlackNotifier during this test
        expect(Slack::Notifier).not_to receive(:new)


        valid_conditions.each do | condition|
          expect(mock_log).to receive(:info).with(/#{condition[:class_name]}/)
        end

        # Slack notification errors:
        EXPECTED_SLACK_EXCEPTION_LOG_ENTRIES.each do | slack_error |
          expect(mock_log).to receive(:error).with(/#{slack_error}/)
        end

        # the errors will not percolate up and be raised; processing continues
        expect { subject.invoke }.not_to raise_error
      end

      end


    describe 'processing failure does not stop other condition processing' do

      it 'logs the processing error and continues with other conditions' do

        Condition.create!(invalid_condition)

        # stub out the Slack notification methods
        allow(SHFNotifySlack).to receive(:notification)
                                     .and_return(true)

        # should never create a SlackNotifier during this test
        expect(Slack::Notifier).not_to receive(:new)


        valid_conditions.each do | condition|
          expect(mock_log).to receive(:info).with(/#{condition[:class_name]}/)
        end

        expect(mock_log).to receive(:error).with(/#{EXPECTED_PROCESSING_EXCEPTION_LOG_ENTRY}/)
        expect(mock_log).to receive(:error).with(/Class: #{invalid_condition[0][:class_name]}/)

        expect { subject.invoke }.not_to raise_error
      end

    end

    describe 'processing AND slack notification failures does not stop condition processing' do

      it 'retries condition after Slack error, logs condition error and continues with remaining conditions' do

        Condition.create!(invalid_condition)

        # Slack notification error that will be raised:
        allow(SHFNotifySlack).to receive(:notification)
                             .and_raise(Slack::Notifier::APIError)

        # should never create a SlackNotifier during this test
        expect(Slack::Notifier).not_to receive(:new)

        valid_conditions.each do | condition|
          expect(mock_log).to receive(:info).with(/#{condition[:class_name]}/)
        end

        expect(mock_log).to receive(:error).with(/#{EXPECTED_PROCESSING_EXCEPTION_LOG_ENTRY}/)
        expect(mock_log).to receive(:error).with(/Class: #{invalid_condition[0][:class_name]}/)

        # Slack notification errors:
        EXPECTED_SLACK_EXCEPTION_LOG_ENTRIES.each do | slack_error |
          expect(mock_log).to receive(:error).with(/#{slack_error}/)
        end

        expect { subject.invoke }.not_to raise_error
    end

  end

    end
  end
