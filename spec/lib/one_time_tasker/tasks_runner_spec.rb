require 'rails_helper'
# rails_helper is needed because TasksRunner uses mattr_accessor
# (TasksRunner also uses TaskAttempt, which is an ActiveRecord, but these tests
# do not; they're stubbed out.)

lib_dir = File.join(__dir__,  '..', '..', '..', 'lib',)
require_relative File.join(lib_dir, 'one_time_tasker', 'tasks_runner')

# This sets up .rake files and tasks in them
require_relative 'shared_context/many_task_files_context'

# This is required for testing Rake tasks
require_relative 'shared_context/mock_rake_task'

RSpec.describe OneTimeTasker::TasksRunner do

  describe 'Unit tests' do

    let(:q1_rakefile) { File.join(OneTimeTasker::TasksRunner.tasks_directory, '2019_Q1', 'q1.rake') }
    let(:q2_rakefile) { File.join(OneTimeTasker::TasksRunner.tasks_directory, '2019_q2', 'q2.rake') }
    let(:blorfo_rakefile) { File.join(OneTimeTasker::TasksRunner.tasks_directory, 'blorfo', 'blorfo.rake') }

    let(:mock_log) { instance_double("ActivityLogger") }

    before(:each) do
      allow(ActivityLogger).to receive(:new).and_return(mock_log)
      allow(mock_log).to receive(:info)
      allow(mock_log).to receive(:record)
      allow(mock_log).to receive(:close)
    end


    describe '.run_onetime_tasks' do
      before(:each) do
        @tasks_directory = Dir.mktmpdir('test-onetime_rake_files')
        OneTimeTasker::TasksRunner.tasks_directory = @tasks_directory

        allow(Rake.application).to receive(:[]).with('environment', anything).and_call_original
        allow(Rake.application).to receive(:[]).with('shf:deploy:run_onetime_tasks').and_call_original

        # Rakefiles and tasks  Each EvaluatedRakefile will run all tasks we've added via the allow statements
        @ev_rakefile_q1 = OneTimeTasker::EvaluatedRakeFile.new(q1_rakefile, task_names: ['shf:test:task0_2019Q1'])
        allow(@ev_rakefile_q1).to receive(:tasks_to_run).and_return(@ev_rakefile_q1.all_tasks)

        @ev_rakefile_q2 = OneTimeTasker::EvaluatedRakeFile.new(q2_rakefile, task_names: ['shf:test:task0_2019Q2'])
        allow(@ev_rakefile_q2).to receive(:tasks_to_run).and_return(@ev_rakefile_q2.all_tasks)

        @ev_rakefile_blorfo = OneTimeTasker::EvaluatedRakeFile.new(blorfo_rakefile, task_names: ['shf:test:task0_blorf', 'shf:test:task1_blorf'])
        allow(@ev_rakefile_blorfo).to receive(:tasks_to_run).and_return(@ev_rakefile_blorfo.all_tasks)
      end

      it 'every task in every file is invoked' do
        files_and_tasks = {
            q1_rakefile => @ev_rakefile_q1,
            q2_rakefile => @ev_rakefile_q2,
            blorfo_rakefile => @ev_rakefile_blorfo
        }
        allow_any_instance_of(OneTimeTasker::TasksFinder).to receive(:files_with_tasks_to_run).and_return(files_and_tasks)

        allow(described_class).to receive(:record_successful_task_attempt).and_return(true)
        allow(described_class).to receive(:rename_rakefile).and_return(true)


        expect(described_class).to receive(:task_invoked_successfully?)
                               .with('shf:test:task0_blorf', blorfo_rakefile).and_return(true)

        expect(described_class).to receive(:task_invoked_successfully?)
                               .with('shf:test:task1_blorf', blorfo_rakefile).and_return(true)

        expect(described_class).to receive(:task_invoked_successfully?)
                               .with('shf:test:task0_2019Q2', q2_rakefile).and_return(true)

        expect(described_class).to receive(:task_invoked_successfully?)
                               .with('shf:test:task0_2019Q1', q1_rakefile).and_return(true)

        described_class.run_onetime_tasks(mock_log, logging: false)
      end

      context 'a task fails' do
        it 'the error is logged but the error is not raised so other tasks can be invoked' do
          @failed_task_name = 'shf:test:task0_blorf'

          files_and_tasks = {
              blorfo_rakefile => @ev_rakefile_blorfo
          }
          allow_any_instance_of(OneTimeTasker::TasksFinder).to receive(:files_with_tasks_to_run).and_return(files_and_tasks)

          allow(Rake).to receive(:load_rakefile).with(blorfo_rakefile)
          allow(Rake.application).to receive(:[]).with(@failed_task_name).and_raise(NoMethodError)
          allow(Rake.application).to receive(:[]).with('shf:test:task1_blorf').and_return(MockRakeTask)

          allow(OneTimeTasker::TasksRunner).to receive(:record_failed_task_attempt)


          expect(described_class).to receive(:task_failed_log_entry).and_call_original
          expect(mock_log).to receive(:error).with("Task #{@failed_task_name} did not run successfully: NoMethodError")

          described_class.run_onetime_tasks(mock_log)

          expect(File.exist?("#{blorfo_rakefile}.ran")).to be_falsey
        end
      end

      describe 'record task attempts' do
        before(:each) do
          @task0_name = 'shf:test:task0_blorf'
          @task1_name = 'shf:test:task1_blorf'

          files_and_tasks = {
              blorfo_rakefile => @ev_rakefile_blorfo
          }
          allow_any_instance_of(OneTimeTasker::TasksFinder).to receive(:files_with_tasks_to_run).and_return(files_and_tasks)

          allow(Rake).to receive(:load_rakefile).with(blorfo_rakefile)
          allow(Rake.application).to receive(:[]).with(@task0_name).and_return(MockRakeTask)

        end

        it 'successful task creates a SuccessfulTaskAttempt' do
          allow(Rake.application).to receive(:[]).with(@task1_name).and_return(MockRakeTask)

          expect(OneTimeTasker::SuccessfulTaskAttempt).to receive(:create)
                                                              .with(task_name: @task0_name,
                                                                    task_source: blorfo_rakefile)
          expect(OneTimeTasker::SuccessfulTaskAttempt).to receive(:create)
                                                              .with(task_name: @task1_name,
                                                                    task_source: blorfo_rakefile)
          described_class.run_onetime_tasks(logging: false)
        end

        it 'failed task creates a FailedTaskAttempt' do

          allow(Rake.application).to receive(:[]).with(@task1_name).and_raise(NoMethodError)

          expect(OneTimeTasker::FailedTaskAttempt).to receive(:create)
                                                          .with(task_name: @task1_name,
                                                                task_source: blorfo_rakefile,
                                                                notes: NoMethodError.to_s)
          described_class.run_onetime_tasks(logging: false)
        end
      end

      describe 'rakefile is renamed only if all tasks in it pass' do
        it 'all tasks in a rakefile pass, the rakefile is renamed' do
          files_and_tasks = {
              blorfo_rakefile => @ev_rakefile_blorfo # @ev_rakefile_q1
          }
          allow_any_instance_of(OneTimeTasker::TasksFinder).to receive(:files_with_tasks_to_run).and_return(files_and_tasks)

          allow(described_class).to receive(:task_invoked_successfully?).and_return(true)

          expect(OneTimeTasker::TasksRunner).to receive(:rename_rakefile).with(blorfo_rakefile, anything)
          expect(mock_log).not_to receive(:error)

          described_class.run_onetime_tasks(mock_log, logging: false)
        end

        it 'a task fails, the rakefile is not renamed' do
          files_and_tasks = {
              q1_rakefile => @ev_rakefile_q1,
              blorfo_rakefile => @ev_rakefile_blorfo
          }
          allow_any_instance_of(OneTimeTasker::TasksFinder).to receive(:files_with_tasks_to_run).and_return(files_and_tasks)

          allow(described_class).to receive(:task_invoked_successfully?).with('shf:test:task0_2019Q1', q1_rakefile).and_return(true)
          allow(described_class).to receive(:task_invoked_successfully?).with('shf:test:task0_blorf', blorfo_rakefile).and_return(false) # failing task
          allow(described_class).to receive(:task_invoked_successfully?).with('shf:test:task1_blorf', blorfo_rakefile).and_return(true)

          # the successful rakefile is renamed, the failed one is not
          expect(OneTimeTasker::TasksRunner).to receive(:rename_rakefile).with(q1_rakefile, anything).once
          expect(OneTimeTasker::TasksRunner).not_to receive(:rename_rakefile).with(blorfo_rakefile, anything)
          described_class.run_onetime_tasks(mock_log, logging: false)
        end
      end

      context 'no tasks found' do
        it 'no rakefiles loaded, no TaskAttempts created' do
          allow_any_instance_of(OneTimeTasker::TasksFinder).to receive(:files_with_tasks_to_run).and_return({})

          expect(described_class).not_to receive(:task_invoked_successfully?)
          expect(described_class).not_to receive(:rename_rakefile)
          expect(OneTimeTasker::TaskAttempt).not_to receive(:create)

          described_class.run_onetime_tasks(mock_log, logging: false)
        end
      end
    end

    it '.rename_rakefile appends .successful_rakefile_extension to the filename' do
      orig_filename = File.join(described_class.tasks_directory, 'blorfo.rake')
      rakefile = File.new(orig_filename, 'w')
      expect(File.exist?(rakefile)).to be_truthy

      described_class.successful_rakefile_extension = 'blorf'

      described_class.rename_rakefile(orig_filename, mock_log)

      expect(File.exist?(orig_filename)).to be_falsey
      expect(File.exist?("#{orig_filename}blorf")).to be_truthy
      File.delete("#{orig_filename}blorf")
    end

    describe '.configure' do
      it 'sets the tasks directory' do
        described_class.configure do |config|
          config.tasks_directory = 'blorf'
        end
        expect(described_class.tasks_directory).to eq 'blorf'
      end

      it 'sets the successful rakefile extension' do
        described_class.configure do |config|
          config.successful_rakefile_extension = '.flurb'
        end
        expect(described_class.successful_rakefile_extension).to eq '.flurb'
      end


      it 'sets the log facility tag' do
        described_class.configure do |config|
          config.log_facility_tag = 'FACILITY TAG'
        end
        expect(described_class.log_facility_tag).to eq 'FACILITY TAG'
      end


      it 'sets the log activity tag' do
        described_class.configure do |config|
          config.log_activity_tag = 'ACTIVITY TAG'
        end
        expect(described_class.log_activity_tag).to eq 'ACTIVITY TAG'
      end
    end

    it '.default_tasks_directory is Rails.root/lib/tasks/one_time' do
      expect(described_class.default_tasks_directory).to eq File.absolute_path(File.join(Rails.root, 'lib', 'tasks', 'one_time'))
    end

    it '.default_successful_rakefile_extension is .ran' do
      expect(described_class.default_successful_rakefile_extension).to eq '.ran'
    end

    it '.default_log_facility_tag is the full class name' do
      expect(described_class.default_log_facility_tag).to eq described_class.name
    end

    it ".default_log_activity_tag is 'Run onetime tasks'" do
      expect(described_class.default_log_activity_tag).to eq 'Run onetime tasks'
    end
  end

  describe 'Acceptance testing' do

    include_context 'many task files'

    let(:mock_log) { instance_double("ActivityLogger") }

    before(:each) do
      allow(ActivityLogger).to receive(:new).and_return(mock_log)
      allow(mock_log).to receive(:info)
      allow(mock_log).to receive(:record)
      allow(mock_log).to receive(:close)

      # There are duplicate tasks and tasks that have already been run.
      #  So errors will be logged.  We're not testing them here.
      allow(mock_log).to receive(:error)

      @all_tests_base_dir = Dir.mktmpdir('test-onetime_rake_files')
      described_class.tasks_directory = @all_tests_base_dir

      make_many_task_files(described_class.tasks_directory)
      create_5_successful_task_attempts(@all_tests_base_dir)
    end

    describe 'many rake files' do

      it 'task attempts recorded' do
        expect(described_class).to receive(:record_successful_task_attempt)
                                       .with('shf:test:some_task_4', anything)
                                       .and_call_original
        expect(described_class).to receive(:record_successful_task_attempt)
                                       .with('shf:test:some_task_1', anything)
                                       .and_call_original
        expect(described_class).to receive(:record_successful_task_attempt)
                                       .with('shf:test:run_this_task', anything)
                                       .and_call_original
        expect(described_class).not_to receive(:record_successful_task_attempt)
                                           .with('shf:test:some_task_5', anything)

        expect { described_class.run_onetime_tasks(mock_log, logging: false) }
            .to change { OneTimeTasker::SuccessfulTaskAttempt.count }
                    .from(5).to(8)
      end

      it '1 successful rakefile renamed' do
        allow(described_class).to receive(:record_successful_task_attempt)
        allow(described_class).to receive(:record_failed_task_attempt)

        run_this_fn = File.absolute_path(File.join(@all_tests_base_dir, RUN_THIS_RAKEFILE))

        expect(described_class).to receive(:rename_rakefile).with(run_this_fn, mock_log)
        described_class.run_onetime_tasks(mock_log, logging: false)
      end
    end

    describe 'many rake files - run again after first run' do
      include_context 'many task files'

      before(:each) do
        orig_run_this_fn = File.absolute_path(File.join(@all_tests_base_dir, RUN_THIS_RAKEFILE))
        q1_some_tasks_too_fn = File.absolute_path(File.join(@all_tests_base_dir, Q1_DIR, SOME_TASKS_RAKEFILE))

        # Add the task_attempts that would be done after a 1st run:
        create(:one_time_tasker_task_attempt, :successful_task,
               task_name: RUNTHISTASK,
               task_source: orig_run_this_fn)
        create(:one_time_tasker_task_attempt, :successful_task,
               task_name: SOMETASK1_SCOPED,
               task_source: q1_some_tasks_too_fn)
        create(:one_time_tasker_task_attempt, :successful_task,
               task_name: SOMETASK4_SCOPED,
               task_source: q1_some_tasks_too_fn)

        # rename the .rake files that would be completely successful after a 1st run:
        File.rename(orig_run_this_fn, "#{orig_run_this_fn}.ran")

        # There are duplicate tasks and tasks that have already been run.
        #  So errors will be logged.  We're not testing them here.
        allow(mock_log).to receive(:error)
      end

      it 'no tasks are run a 2nd time' do
        expect(described_class).not_to receive(:task_invoked_successfully?)
        described_class.run_onetime_tasks(mock_log, logging: false)
      end

      it 'task attempts recorded' do
        expect(described_class).not_to receive(:record_successful_task_attempt).with('shf:test:some_task_5', anything)
        expect(OneTimeTasker::SuccessfulTaskAttempt.count).to eq 8
        described_class.run_onetime_tasks(mock_log, logging: false)
      end

      it 'no successful rakefiles renamed' do
        expect(described_class).not_to receive(:rename_rakefile)
        described_class.run_onetime_tasks(mock_log, logging: false)
      end
    end


    it 'errors are logged: duplicates and tasks that have already been run' do
      allow(described_class).to receive(:record_successful_task_attempt)
      allow(described_class).to receive(:record_failed_task_attempt)

      # We expect these specific errors:
      expect(mock_log).to receive(:error).with(/Task Already Ran: Task named 'shf:test:set_when_approved_data'/)
      expect(mock_log).to receive(:error).with(/Task Already Ran: Task named 'shf:test:good_task/)
      expect(mock_log).to receive(:error).with(/Task Already Ran: Task named 'shf:test:some_task_2'/)
      expect(mock_log).to receive(:error).with(/Task Already Ran: Task named 'shf:test:some_task_3'/)
      expect(mock_log).to receive(:error).with(/Duplicate task name! Task named 'shf:test:simple_task'/)
      expect(mock_log).to receive(:error).with(/Duplicate task name! Task named 'shf:test:some_task_5'/)

      described_class.run_onetime_tasks(mock_log, logging: false)
    end

  end
end
