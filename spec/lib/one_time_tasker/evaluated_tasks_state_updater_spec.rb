require 'rails_helper'
# rails_helper is needed so we can use ActivityLogger


lib_dir = File.join(__dir__, '..', '..', '..', 'lib',)
require_relative File.join(lib_dir, 'one_time_tasker', 'evaluated_tasks_state_updater.rb')
require_relative File.join(lib_dir, 'one_time_tasker', 'evaluated_rake_file')

# This sets up .rake files and tasks in them
require_relative 'shared_context/many_task_files_context'
require_relative 'shared_context/simple_rake_task_files_maker'


RSpec.describe OneTimeTasker::EvaluatedTasksStateUpdater do

  include_context 'simple rake task files maker'

  let(:mock_log) { instance_double("ActivityLogger") }

  Q1_DIR = '2019_Q1' unless defined?(Q1_DIR)
  Q2_DIR = '2019_Q2' unless defined?(Q2_DIR)
  BLORF_DIR = 'blorf' unless defined?(BLORF_DIR)
  BLORF2_DIR = 'blorf2' unless defined?(BLORF2_DIR)

  RAKEFILENAME = 'test.rake' unless defined?(RAKEFILENAME)


  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)

    @tasks_directory = Dir.mktmpdir('test-onetime_rake_files')
    @q1_rakefile = File.absolute_path(File.join(@tasks_directory, Q1_DIR, RAKEFILENAME))
    @q2_rakefile = File.absolute_path(File.join(@tasks_directory, Q2_DIR, RAKEFILENAME))
    @blorf_rakefile = File.absolute_path(File.join(@tasks_directory, BLORF_DIR, RAKEFILENAME))
  end


  describe 'Unit tests' do

    describe 'initialize' do

      it 'sets a log if one is given' do
        expect(OneTimeTasker::EvaluatedTasksStateUpdater).to receive(:new)
                                                                 .with(mock_log).and_call_original

        new_tasks_state_updater = OneTimeTasker::EvaluatedTasksStateUpdater.new(mock_log)
        expect(new_tasks_state_updater.log).to eq mock_log
      end
    end


    describe '.set_and_log_duplicate_task' do

      before(:each) do
        @given_task = instance_double(' OneTimeTasker::EvaluatedRakeTask')
        allow(@given_task).to receive(:filename).and_return('source_filename1')
        allow(@given_task).to receive(:name).and_return('dup:task_name')

        @other_task = instance_double(' OneTimeTasker::EvaluatedRakeTask')
        allow(@other_task).to receive(:filename).and_return('source_filename2')
        allow(@other_task).to receive(:name).and_return('dup:task_name')
        allow(@other_task).to receive(:add_duplicate)

        @tasks_with_same_name = [@given_task, @other_task]
      end

      it 'sets this as a duplicate for others' do
        expect(mock_log).to receive(:error).with(/Duplicate task name!/)
        expect(@other_task).to receive(:add_duplicate).with(@given_task.filename)
        subject.set_and_log_task_as_duplicate(@given_task, @tasks_with_same_name)
      end


      it 'logs the task as a duplicate' do
        expect(subject).to receive(:log_as_duplicate).with(@given_task)
        subject.set_and_log_task_as_duplicate(@given_task, @tasks_with_same_name)
      end

    end


    describe '.set_and_log_task_as_already_ran' do

      before(:each) do
        @given_task = instance_double(' OneTimeTasker::EvaluatedRakeTask')
        allow(@given_task).to receive(:filename).and_return('source_filename1')
        allow(@given_task).to receive(:name).and_return('dup:task_name')
        allow(@given_task).to receive(:add_previous_run)

        @successful_time = DateTime.new(2019, 6, 11, 1, 2, 3)
        @successful_attempt = instance_double('OneTimeTasker::SuccessfulTaskAttempt')
        allow(@successful_attempt).to receive(:task_source).and_return('successful source')
        allow(@successful_attempt).to receive(:task_name).and_return('dup:task_name')
        allow(@successful_attempt).to receive(:attempted_on).and_return(@successful_time)
      end

      it 'adds info about when it was previously successfully run' do
        expect(mock_log).to receive(:error).with(/Task Already Ran/)
        expect(@given_task).to receive(:add_previous_run).with('successful source', @successful_time)
        subject.set_and_log_task_as_already_ran(@given_task, @successful_attempt)
      end


      it 'logs the task as already ran' do
        expect(subject).to receive(:log_already_ran).with(@given_task, @successful_attempt)
        subject.set_and_log_task_as_already_ran(@given_task, @successful_attempt)
      end

    end


    describe '.log_already_ran' do

      it 'writes a task_already_ran_log_entry message to the log' do
        allow(subject).to receive(:log).and_return(mock_log)

        given_task = instance_double('OneTimeTasker::EvaluatedRakeTask')
        allow(given_task).to receive(:filename).and_return('source_filename1')
        allow(given_task).to receive(:name).and_return('already_ran:task_name')

        @successful_time = DateTime.new(2019, 6, 11, 1, 2, 3)
        @successful_attempt = instance_double('OneTimeTasker::SuccessfulTaskAttempt')
        allow(@successful_attempt).to receive(:task_source).and_return('successful source')
        allow(@successful_attempt).to receive(:task_name).and_return('already_ran:task_name')
        allow(@successful_attempt).to receive(:attempted_on).and_return(@successful_time)

        expect(subject).to receive(:task_already_ran_log_entry).and_call_original

        expect(mock_log).to receive(:error).with(/Task Already Ran\: Task named 'already_ran\:task_name' in the file source_filename1\: Task has already been successfully run on (.*) from source\: successful source/)
        subject.log_already_ran(given_task, @successful_attempt)
      end

    end


    describe '.log_as_duplicate' do

      it 'writes to the logfile with the duplicate_task_log_entry message' do
        allow(subject).to receive(:log).and_return(mock_log)

        given_task = instance_double('OneTimeTasker::EvaluatedRakeTask')
        allow(given_task).to receive(:filename).and_return('source_filename1')
        allow(given_task).to receive(:name).and_return('dup:task_name')

        expect(subject).to receive(:duplicate_task_log_entry).and_call_original

        expect(mock_log).to receive(:error).with(/Duplicate task name\! Task named 'dup\:task_name' in the file source_filename1\: This task is a duplicate: more than 1 task to be run has this task name\. This task cannot be run\./)

        subject.log_as_duplicate(given_task)
      end
    end

  end

end
