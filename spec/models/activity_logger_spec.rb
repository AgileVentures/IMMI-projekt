require 'rails_helper'

RSpec.describe ActivityLogger do

  let(:filepath) { File.join(Rails.root, 'tmp', 'testfile') }
  let(:log)      { ActivityLogger.open(filepath, 'TEST', 'open', false) }

  describe 'log file' do

    before(:each) do
      File.delete(filepath) if File.file?(filepath)
    end

    after(:all) do
      File.delete(File.join(Rails.root, 'tmp', 'testfile'))
    end

    context 'open without a block' do

      it 'creates log file' do
        log
        expect(File).to exist(filepath)
      end
      it 'returns instance of ActivityLogger' do
        expect(log).to be_an_instance_of(ActivityLogger)
      end
      it 'records message to log file' do
        log.record('info', 'this is a test message')
        expect(File.read(filepath))
          .to include '[TEST] [open] [info] this is a test message'
      end
    end

    context 'open with a block' do

      it 'creates log file' do
        ActivityLogger.open(filepath, 'TEST', 'open', false) do |log|
          expect(File).to exist(filepath)
        end
      end
      it 'returns instance of ActivityLogger' do
        ActivityLogger.open(filepath, 'TEST', 'open', false) do |log|
          expect(log).to be_an_instance_of(ActivityLogger)
        end
      end
      it 'records message to log file' do
        ActivityLogger.open(filepath, 'TEST', 'open', false) do |log|
          log.record('info', 'this is another test message')
          expect(File.read(filepath))
            .to include '[TEST] [open] [info] this is another test message'
        end
      end
    end
  end
end
