require 'rails_helper'
# rails_helper is needed because this uses TaskAttempts, which are ActiveRecords


lib_dir = File.join(__dir__, '..', '..', '..', 'lib',)
require_relative File.join(lib_dir, 'one_time_tasker', 'tasks_finder')
require_relative File.join(lib_dir, 'one_time_tasker', 'evaluated_rake_file')

# This sets up .rake files and tasks in them
require_relative 'shared_context/many_task_files_context'

require_relative 'shared_context/simple_rake_task_files_maker'
require_relative 'shared_context/mock_rake_task'


RSpec.describe OneTimeTasker::TasksFinder do

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
    subject.tasks_directory = @tasks_directory

    @q1_rakefile = File.absolute_path(File.join(@tasks_directory, Q1_DIR, RAKEFILENAME))
    @q2_rakefile = File.absolute_path(File.join(@tasks_directory, Q2_DIR, RAKEFILENAME))
    @blorf_rakefile = File.absolute_path(File.join(@tasks_directory, BLORF_DIR, RAKEFILENAME))
  end


  describe 'Unit tests' do
    describe 'initialize' do
      it 'sets a log if one is given' do
        expect(OneTimeTasker::TasksFinder).to receive(:new)
                                                  .with(mock_log).and_call_original

        new_tasks_finder = OneTimeTasker::TasksFinder.new(mock_log)
        expect(new_tasks_finder.log).to eq mock_log
      end

      it 'creates a tasks_updater to use' do
        expect(OneTimeTasker::TasksFinder).to receive(:new).and_call_original

        new_tasks_finder = OneTimeTasker::TasksFinder.new
        expect(new_tasks_finder.tasks_updater).to be_a OneTimeTasker::EvaluatedTasksStateUpdater
      end
    end

    describe '.files_with_tasks_to_run' do
      it 'resets all tasks known to the finder' do
        allow(subject).to receive(:set_or_create_log)
        allow(subject).to receive(:set_and_log_duplicate_tasks)
        allow(subject).to receive(:set_and_log_tasks_already_ran)
        allow(subject).to receive(:close_log_if_this_created_it)

        expect(subject).to receive(:clear_all_tasks_and_rakefiles)
        subject.files_with_tasks_to_run
      end

      it 'sets the tasks already run' do
        allow(subject).to receive(:clear_all_tasks_and_rakefiles)
        allow(subject).to receive(:set_or_create_log)
        allow(subject).to receive(:set_and_log_duplicate_tasks)
        allow(subject).to receive(:close_log_if_this_created_it)

        expect(subject).to receive(:set_and_log_tasks_already_ran)
        subject.files_with_tasks_to_run
      end

      it 'sets duplicate tasks' do
        allow(subject).to receive(:clear_all_tasks_and_rakefiles)
        allow(subject).to receive(:set_or_create_log)
        allow(subject).to receive(:set_and_log_tasks_already_ran)
        allow(subject).to receive(:close_log_if_this_created_it)

        expect(subject).to receive(:set_and_log_duplicate_tasks)
        subject.files_with_tasks_to_run
      end

      it 'returns a Hash: key = rakefile name, value = EvaluatedRakeFile' do
        # Create 1 .rake file in the directory
        make_simple_rakefiles_under_subdir(subject.tasks_directory, '.', 1)

        result = subject.files_with_tasks_to_run
        expect(result).to be_a Hash
        expect(result.values.first).to be_a OneTimeTasker::EvaluatedRakeFile
      end

      describe 'logs an error if one is raised and there is a log file' do
        context 'there is a log file' do
          it 'error is written to the log file' do

            task_finder_with_log = described_class.new(mock_log, logging: true)
            task_finder_with_log.tasks_directory = @tasks_directory

            # stub methods:
            allow(task_finder_with_log).to receive(:set_and_log_duplicate_tasks).and_raise(NoMethodError)
            allow(task_finder_with_log).to receive(:set_and_log_tasks_already_ran)

            expect(mock_log).to receive(:error).with('Error during OneTimeTasker::TasksFinder  files_with_tasks_to_run!  NoMethodError')
            expect { task_finder_with_log.files_with_tasks_to_run }.to raise_error(NoMethodError)
          end
        end
      end
    end

    describe '.rakefiles_with_tasks_to_run' do
      it 'empty if there are no tasks to run' do
        allow(subject).to receive(:all_tasks).and_return([])
        allow(subject).to receive(:all_rakefiles).and_return([])

        expect(subject.rakefiles_with_tasks_to_run).to be_empty
      end

      it 'includes only rakefiles with tasks to be run' do

        # Set up duplicates:
        dup1_1_rake_fn = File.join(subject.tasks_directory, 'dup1-1.rake')
        dup1_2_rake_fn = File.join(subject.tasks_directory, 'dup1-2.rake')

        ev_dup1_1_task = OneTimeTasker::EvaluatedRakeTask.new('dup1', dup1_1_rake_fn)
        ev_dup1_1_task.add_duplicate(dup1_2_rake_fn)
        ev_dup1_2_task = OneTimeTasker::EvaluatedRakeTask.new('dup1', dup1_2_rake_fn)
        ev_dup1_2_task.add_duplicate(dup1_1_rake_fn)

        ev_dup1_1_rakefile = OneTimeTasker::EvaluatedRakeFile.new(dup1_1_rake_fn)
        ev_dup1_1_rakefile.add_eval_task(ev_dup1_1_task)
        ev_dup1_2_rakefile = OneTimeTasker::EvaluatedRakeFile.new(dup1_2_rake_fn,
                                                                  task_names: [ev_dup1_2_task])

        # Set up a task already run:
        already_ran1_rake_fn = File.join(subject.tasks_directory, 'already_ran.rake')
        already_ran2_rake_fn = File.join(subject.tasks_directory, 'already_ran2.rake')
        ev_already_ran2_task = OneTimeTasker::EvaluatedRakeTask.new('already_ran2', already_ran2_rake_fn)
        ev_already_ran2_task.add_previous_run(already_ran1_rake_fn, Time.zone.now)

        ev_already_ran2_rakefile = OneTimeTasker::EvaluatedRakeFile.new(already_ran2_rake_fn,
                                                                        task_names: [ev_already_ran2_task])

        # 2 tasks to be run
        run_me1_rake_fn = File.join(subject.tasks_directory, 'run_me1.rake')
        ev_run_me1_task = OneTimeTasker::EvaluatedRakeTask.new('run_me1', run_me1_rake_fn)
        ev_run_me1_rakefile = OneTimeTasker::EvaluatedRakeFile.new(run_me1_rake_fn,
                                                                   task_names: [ev_run_me1_task])

        run_me2_rake_fn = File.join(subject.tasks_directory, 'run_me2.rake')
        ev_run_me2_task = OneTimeTasker::EvaluatedRakeTask.new('run_me2', run_me2_rake_fn)
        ev_run_me2_rakefile = OneTimeTasker::EvaluatedRakeFile.new(run_me2_rake_fn,
                                                                   task_names: [ev_run_me2_task])

        # add a duplicate task to this Rakefile
        ev_run_me2_rakefile.add_eval_task(ev_dup1_2_task)
        # add a task already run to this Rakefile
        ev_run_me2_rakefile.add_eval_task(ev_already_ran2_task)


        allow(subject).to receive(:all_tasks).and_return([ev_dup1_1_task,
                                                          ev_dup1_2_task,
                                                          ev_already_ran2_task,
                                                          ev_run_me1_task,
                                                          ev_run_me2_task
                                                         ])
        allow(subject).to receive(:all_rakefiles).and_return({ dup1_1_rake_fn => ev_dup1_1_rakefile,
                                                               dup1_2_rake_fn => ev_dup1_2_rakefile,
                                                               already_ran2_rake_fn => ev_already_ran2_rakefile,
                                                               run_me1_rake_fn => ev_run_me1_rakefile,
                                                               run_me2_rake_fn => ev_run_me2_rakefile
                                                             })

        actual_rakefiles_with_tasks = subject.rakefiles_with_tasks_to_run
        expect(actual_rakefiles_with_tasks.keys).to match_array([run_me1_rake_fn, run_me2_rake_fn])

        expect(actual_rakefiles_with_tasks[run_me1_rake_fn].tasks_to_run).to match_array([ev_run_me1_task])
        expect(actual_rakefiles_with_tasks[run_me2_rake_fn].tasks_to_run).to match_array([ev_run_me2_task])
      end

      it 'is a Hash with each key = rakefilename, value = EvaluatedRakeFile' do

        # create 1 task to be run
        run_me1_rakefile = File.absolute_path(File.join(subject.tasks_directory, 'run_me1.rake'))
        ev_run_me1_task = OneTimeTasker::EvaluatedRakeTask.new('run_me1', run_me1_rakefile)
        ev_run_me1_rakefile = OneTimeTasker::EvaluatedRakeFile.new(run_me1_rakefile,
                                                                   task_names: [ev_run_me1_task])

        allow(subject).to receive(:all_tasks).and_return([ev_run_me1_task])
        allow(subject).to receive(:all_rakefiles).and_return({ run_me1_rakefile => ev_run_me1_rakefile })

        actual_rakefiles_with_tasks = subject.rakefiles_with_tasks_to_run
        expect(actual_rakefiles_with_tasks).to be_a Hash
        expect(actual_rakefiles_with_tasks.values.first).to be_a OneTimeTasker::EvaluatedRakeFile
      end
    end

    describe '.clear_all_tasks_and_rakefiles' do
      before(:each) do
        # Create 1 .rake file in the directory
        make_simple_rakefiles_under_subdir(subject.tasks_directory, '.', 1)
        subject.files_with_tasks_to_run
      end

      it 'all_rakefiles is reset to empty' do
        expect(subject.all_rakefiles).not_to be_empty
        subject.clear_all_tasks_and_rakefiles
        expect(subject.all_rakefiles).to be_empty
      end

      it 'all_tasks is reset to empty' do
        expect(subject.all_tasks).not_to be_empty
        subject.clear_all_tasks_and_rakefiles
        expect(subject.all_tasks).to be_empty
      end
    end

    describe '.add_rakefile_and_tasks' do
      describe 'we already have an EvaluatedRakeFile for this rake file name' do
        before(:each) do
          # Create 1 .rake file in the directory
          make_simple_rakefiles_under_subdir(subject.tasks_directory, '.', 1)
          subject.files_with_tasks_to_run

          @base_dir = subject.tasks_directory

          expect(subject.all_rakefiles.size).to eq 1
          expect(subject.all_rakefiles.keys.first).to eq(File.join(@base_dir, 'test0.rake'))
          expect(subject.all_tasks.size).to eq 1
          expect(subject.all_tasks.first.name).to eq 'shf:test:task0'

          @existing_rakefile_name = File.join(@base_dir, 'test0.rake')
          @existing_task_name = 'shf:test:task0'
        end

        it 'does not add a brand new EvaluatedRakefile to our list of rakefiles' do
          new_task_names = %w(task1)
          subject.add_rakefile_and_tasks(@existing_rakefile_name, new_task_names)

          expect(subject.all_rakefiles.size).to eq 1
        end

        it 'adds a new EvaluatedRakeTask for each task name not already in the EvaluatedRakeFile tasks' do

          new_task_names = %w(task1 task2)
          subject.add_rakefile_and_tasks(@existing_rakefile_name, new_task_names)

          actual_ev_rakefile = subject.all_rakefiles[@existing_rakefile_name]

          expect(actual_ev_rakefile.all_tasks.map(&:name)).to match_array([@existing_task_name] + new_task_names)
        end
      end

      describe 'we do not have an EvaluatedRakefile for this rake file name' do
        it 'adds a new EvaluatedRakefile to our list of rakefiles' do
          expect(subject.all_rakefiles).to be_empty
          expect(subject.all_tasks).to be_empty

          new_rakefile_name = 'new/rake/file'
          new_task_names = %w(task1 task2)
          subject.add_rakefile_and_tasks(new_rakefile_name, new_task_names)

          expect(subject.all_rakefiles.keys).to include(new_rakefile_name)
          expect(subject.all_rakefiles[new_rakefile_name]).to be_a OneTimeTasker::EvaluatedRakeFile
          actual_ev_rakefile = subject.all_rakefiles[new_rakefile_name]
          expect(actual_ev_rakefile.filename).to eq new_rakefile_name
          expect(actual_ev_rakefile.all_tasks.map(&:name)).to match_array(new_task_names)
        end
      end
    end

    describe '.onetime_rake_files' do
      it 'empty if the onetime path does not exist' do
        subject.tasks_directory = BLORF_DIR
        expect(subject.onetime_rake_files).to be_empty
      end

      it 'empty if no .rake files' do
        expect(subject.onetime_rake_files).to be_empty
      end

      it 'only returns .rake files' do

        # Create 1 .rake file in the directory
        make_simple_rakefiles_under_subdir(subject.tasks_directory, '.', 1)

        # Create 3 .rake files in the 'blorfo' subdirectory
        make_simple_rakefiles_under_subdir(subject.tasks_directory, 'blorfo', 3)

        # Create 2 .rake files in the 'flurb' subdirectory
        make_simple_rakefiles_under_subdir(subject.tasks_directory, 'flurb', 2)

        # Create some files that do not have a .rake extension
        not_rake_files = ['blorf.rake.txt', 'blorf.txt', BLORF_DIR, 'rake']
        not_rake_files.each do |not_a_rake_file|
          filepath_created = File.join(File.absolute_path(subject.tasks_directory), not_a_rake_file)
          File.open(filepath_created, 'w') do |f|
            f.puts 'blorf is here'
          end
        end

        expect(subject.onetime_rake_files).to match_array(["test0.rake", "blorfo/test0.rake", "blorfo/test1.rake", "blorfo/test2.rake", "flurb/test0.rake", "flurb/test1.rake"])
      end

      it 'ignores a file a file named .rake (the extension only)' do

        # Create a file that is named ".rake"  It wil
        filepath_created = File.join(File.absolute_path(subject.tasks_directory), '.rake')
        File.open(filepath_created, 'w') do |f|
          f.puts 'this file is named with only the .rake extension'
        end

        expect(subject.onetime_rake_files).to be_empty
      end
    end

    describe '.get_tasks_from_rakefiles' do
      it 'an empty list if no rakefiles' do
        expect(Dir.children(subject.tasks_directory)).to be_empty
        expect(subject.get_tasks_from_rakefiles).to be_empty
      end

      it 'an empty list if no tasks' do
        # create 3 empty .rake files
        3.times do |i|
          filepath_created = File.join(File.absolute_path(subject.tasks_directory), "task_#{i}.rake")
          File.open(filepath_created, 'w') do |f|
            f.puts ''
          end
        end

        expect(subject.get_tasks_from_rakefiles).to be_empty
      end

      it 'returns all tasks' do

        # Create 1 .rake file in the directory
        make_simple_rakefiles_under_subdir(subject.tasks_directory, '.', 1)

        rakefile_tasks = subject.get_tasks_from_rakefiles
        expect(rakefile_tasks.first).to be_a OneTimeTasker::EvaluatedRakeTask

        expect(rakefile_tasks).to match_array subject.all_tasks
      end

      it 'it adds an EvalutedRakeFile for each new rakefile read in' do

        expect(subject.all_rakefiles).to be_empty

        # Create 1 .rake file in the directory
        make_simple_rakefiles_under_subdir(subject.tasks_directory, '.', 1)

        subject.get_tasks_from_rakefiles

        expect(subject.all_rakefiles.size).to eq 1
      end

      describe 'tasks in many .rake files' do
        include_context 'many task files'

        before(:each) { make_many_task_files(subject.tasks_directory) }


        it 'adds each task to the list of all_tasks' do

          expected_tasks = all_evaluated_tasks_in_files(subject.tasks_directory)

          actual_tasks = subject.get_tasks_from_rakefiles

          expect(actual_tasks.size).to eq(expected_tasks.size)
          expect(actual_tasks.map { |t| [t.name, t.filename] }).to match_array(expected_tasks.map { |t| [t.name, t.filename] })
        end

        it 'adds each .rake file to the list of all_rakefiles' do
          expect(subject.all_rakefiles).to be_empty

          base_dir = subject.tasks_directory
          expected_rakefiles = Dir.glob(File.join("**", "*.rake"), base: base_dir)
          # need to add the directory name to the filenames returned by .glob above
          expected_rakefiles = expected_rakefiles.map { |fn| File.absolute_path(File.join(base_dir, fn)) }

          subject.get_tasks_from_rakefiles

          expect(subject.all_rakefiles.keys).to match_array(expected_rakefiles)
        end
      end
    end

    describe '.set_and_log_tasks_already_ran' do
      it 'returns an empty list and logs nothing if list is empty' do
        expect(subject.set_and_log_tasks_already_ran([])).to be_empty
      end

      describe 'list of tasks to check is not empty' do
        before(:each) do
          # previously run successful tasks:
          allow(subject).to receive(:successful_task_attempts)
                                .and_return([build(:one_time_tasker_task_attempt, :successful_task,
                                                   task_name: 'shf:test:task0', task_source: 'flurb'),

                                             build(:one_time_tasker_task_attempt, :successful_task,
                                                   task_name: 'shf:test:task1', task_source: 'blorfo.rake')
                                            ])

          @blorf_dir = File.absolute_path(File.join(subject.tasks_directory, BLORF_DIR))
          @q1_dir = File.absolute_path(File.join(subject.tasks_directory, Q1_DIR))

          # TODO would be better if these were _doubles_
          @ev_task0 = OneTimeTasker::EvaluatedRakeTask.new('shf:test:task0', @blorf_dir)
          @ev_task1 = OneTimeTasker::EvaluatedRakeTask.new('shf:test:task1', @blorf_dir)
          @ev_blorf_not_run = OneTimeTasker::EvaluatedRakeTask.new('shf:test:not_run', @blorf_dir)
          @tasks_to_check = [@ev_task0, @ev_task1, @ev_blorf_not_run]

          @successful_attempt = double('a OneTimeTasker::SuccessfulTaskAttempt')
          allow(@successful_attempt).to receive(:task_source).and_return('successful source')
          allow(@successful_attempt).to receive(:task_name).and_return('dup:task_name')
          allow(@successful_attempt).to receive(:attempted_on).and_return(@successful_time)
        end

        describe 'no successful task attempt found for a task' do
          before(:each) { allow(subject).to receive(:find_successful_attempt_for_task).and_return(nil) }


          it 'the task is not set as having a previous successful run, nor is it logged' do
            expect(subject.tasks_updater).not_to receive(:set_and_log_task_as_already_ran).with(@ev_task0, anything)
            expect(subject.tasks_updater).not_to receive(:set_and_log_task_as_already_ran).with(@ev_task1, anything)
            expect(subject.tasks_updater).not_to receive(:set_and_log_task_as_already_ran).with(@ev_blorf_not_run, anything)

            subject.set_and_log_tasks_already_ran(@tasks_to_check)
          end
        end

        describe 'found a successful task attempt for a task' do
          before(:each) { allow(subject).to receive(:find_successful_attempt_for_task).and_return(@successful_attempt) }

          it 'finds the first successful task attempt for each task' do
            expect(subject).to receive(:find_successful_attempt_for_task).with(@ev_task0)
            expect(subject).to receive(:find_successful_attempt_for_task).with(@ev_task1)
            expect(subject).to receive(:find_successful_attempt_for_task).with(@ev_blorf_not_run)

            subject.set_and_log_tasks_already_ran(@tasks_to_check)
          end

          it 'calls the tasks manager to set and log each task' do
            expect(subject.tasks_updater).to receive(:set_and_log_task_as_already_ran).with(@ev_task0, anything)
            expect(subject.tasks_updater).to receive(:set_and_log_task_as_already_ran).with(@ev_task1, anything)
            expect(subject.tasks_updater).to receive(:set_and_log_task_as_already_ran).with(@ev_blorf_not_run, anything)

            subject.set_and_log_tasks_already_ran(@tasks_to_check)
          end
        end

        it 'returns the previously run tasks, may include duplicates' do
          tasks_to_check = [
              OneTimeTasker::EvaluatedRakeTask.new('shf:test:task0', @blorf_dir),
              OneTimeTasker::EvaluatedRakeTask.new('shf:test:task1', @blorf_dir),
              OneTimeTasker::EvaluatedRakeTask.new('shf:test:not_run', @blorf_dir),
              OneTimeTasker::EvaluatedRakeTask.new('shf:test:task0', @q1_dir),
          ]

          expected_tasks = [
              OneTimeTasker::EvaluatedRakeTask.new('shf:test:task0', @blorf_dir),
              OneTimeTasker::EvaluatedRakeTask.new('shf:test:task1', @blorf_dir),
              OneTimeTasker::EvaluatedRakeTask.new('shf:test:task0', @q1_dir),
          ]

          expect(subject.set_and_log_tasks_already_ran(tasks_to_check).map { |t| [t.name, t.filename] }).to match_array(expected_tasks.map { |t| [t.name, t.filename] })
        end
      end
    end

    describe '.set_and_log_duplicate_tasks' do
      @tasks_directory = Dir.mktmpdir('test-onetime_rake_files')

      before(:each) do
        subject.tasks_directory = @tasks_directory
      end

      describe 'no duplicates' do
        before(:each) do
          @ev_task1 = OneTimeTasker::EvaluatedRakeTask.new('task1', @q1_rakefile)
          @ev_task2 = OneTimeTasker::EvaluatedRakeTask.new('task2', @q2_rakefile)
          @ev_task3 = OneTimeTasker::EvaluatedRakeTask.new('task3', @blorf_rakefile)

          @tasks_with_no_duplicates = [@ev_task1, @ev_task2, @ev_task3]
        end

        it "list of duplicate tasks is empty" do
          expect(subject.set_and_log_duplicate_tasks(@tasks_with_no_duplicates)).to be_empty
        end

        it 'tasks manager is never called to set and log duplicates' do
          expect(subject.tasks_updater).not_to receive(:set_and_log_task_as_duplicate)

          subject.set_and_log_duplicate_tasks(@tasks_with_no_duplicates)
        end
      end

      describe 'one taskname is duplicated 3 times' do
        duplicated_task_name = 'shf:test:task0'

        before(:each) do
          # TODO these would be better as doubles
          @ev_dup1_task = OneTimeTasker::EvaluatedRakeTask.new(duplicated_task_name, @q1_rakefile)
          @ev_dup2_task = OneTimeTasker::EvaluatedRakeTask.new(duplicated_task_name, @q2_rakefile)
          @ev_dup3_task = OneTimeTasker::EvaluatedRakeTask.new(duplicated_task_name, @blorf_rakefile)

          @ev_not_a_dup_task = OneTimeTasker::EvaluatedRakeTask.new('not_a_duplicate', @q1_rakefile)

          @all_ev_tasks = [@ev_not_a_dup_task, @ev_dup1_task, @ev_dup2_task, @ev_dup3_task]

          @duplicated_tasks = [@ev_dup1_task, @ev_dup2_task, @ev_dup3_task]
        end

        it 'tells the tasks manager to set and log each of the duplicates' do
          @duplicated_tasks.each do |duplicated_task|
            expect(subject.tasks_updater).to receive(:set_and_log_task_as_duplicate).with(duplicated_task, @duplicated_tasks)
          end

          subject.set_and_log_duplicate_tasks(@all_ev_tasks)
        end

        it 'duplicate tasks are correct' do
          expected_dup_tasks = [@ev_dup1_task, @ev_dup2_task, @ev_dup3_task]

          actual_dup_tasks = subject.set_and_log_duplicate_tasks(@all_ev_tasks)
          expect(actual_dup_tasks.map(&:name)).to match_array(expected_dup_tasks.map(&:name))
          expect(actual_dup_tasks.map { |dup| [dup.name, dup.filename] }.flatten).to match_array(expected_dup_tasks.map { |dup| [dup.name, dup.filename] }.flatten)
        end
      end

      describe 'multiple tasknames are duplicated' do
        it 'duplicated tasks are correct' do
          duplicated_task_name0 = 'shf:test:dup0'
          duplicated_task_name1 = 'shf:test:dup1'
          duplicated_task_name2 = 'shf:test:dup2'

          base_rakefile = File.absolute_path(File.join(subject.tasks_directory, 'test.rake'))


          expected_dup_tasks = [OneTimeTasker::EvaluatedRakeTask.new(duplicated_task_name0, @q1_rakefile),
                                OneTimeTasker::EvaluatedRakeTask.new(duplicated_task_name1, @q1_rakefile),
                                OneTimeTasker::EvaluatedRakeTask.new(duplicated_task_name2, @q1_rakefile),
                                OneTimeTasker::EvaluatedRakeTask.new(duplicated_task_name0, @q2_rakefile),
                                OneTimeTasker::EvaluatedRakeTask.new(duplicated_task_name0, @blorf_rakefile),
                                OneTimeTasker::EvaluatedRakeTask.new(duplicated_task_name1, @blorf_rakefile),
                                OneTimeTasker::EvaluatedRakeTask.new(duplicated_task_name2, base_rakefile),
          ]

          actual_dup_tasks = subject.set_and_log_duplicate_tasks([OneTimeTasker::EvaluatedRakeTask.new(duplicated_task_name0, @q1_rakefile),
                                                                  OneTimeTasker::EvaluatedRakeTask.new(duplicated_task_name1, @q1_rakefile),
                                                                  OneTimeTasker::EvaluatedRakeTask.new(duplicated_task_name2, @q1_rakefile),

                                                                  OneTimeTasker::EvaluatedRakeTask.new(duplicated_task_name0, @q2_rakefile),

                                                                  OneTimeTasker::EvaluatedRakeTask.new(duplicated_task_name0, @blorf_rakefile),
                                                                  OneTimeTasker::EvaluatedRakeTask.new('shf:test:blorf0', @blorf_rakefile),
                                                                  OneTimeTasker::EvaluatedRakeTask.new(duplicated_task_name1, @blorf_rakefile),
                                                                  OneTimeTasker::EvaluatedRakeTask.new('shf:test:blorf1', @blorf_rakefile),

                                                                  OneTimeTasker::EvaluatedRakeTask.new('shf:test:top_level0', base_rakefile),
                                                                  OneTimeTasker::EvaluatedRakeTask.new('shf:test:top_level1', base_rakefile),
                                                                  OneTimeTasker::EvaluatedRakeTask.new(duplicated_task_name2, base_rakefile),
                                                                  OneTimeTasker::EvaluatedRakeTask.new('shf:test:top_level2', base_rakefile)
                                                                 ])
          expect(actual_dup_tasks.map { |dup| [dup.name, dup.filename] }.flatten).to match_array(expected_dup_tasks.map { |dup| [dup.name, dup.filename] }.flatten)
        end
      end
    end

    # noinspection RubyQuotedStringsInspection
    it "default_tasks_directory is File.join(Rails.root, 'lib', 'tasks', 'one_time')" do
      new_finder = described_class.new
      expect(new_finder.tasks_directory).to eq File.join(Rails.root, 'lib', 'tasks', 'one_time')
    end

    it 'default_log_facility_tag is OneTimeTasker::TasksFinder (the class name)' do
      expect(subject.default_log_facility_tag).to eq described_class.name
    end
  end

  describe 'Acceptance tests' do
    describe 'Many task files - has duplicates and tasks already run' do
      include_context 'many task files'

      let(:base_dir) { subject.tasks_directory }

      before(:all) do
        # Use this same temp directory for all tests in this example group
        # instead of creating a new one for every test.  (IOW, override how
        # it's done in the before(:each) block for this entire RSpec.)
        #
        @all_tests_base_dir = Dir.mktmpdir('test-onetime_rake_files')
        #   described_class.tasks_directory = @all_tests_base_dir

        make_many_task_files(@all_tests_base_dir)
      end

      before(:each) do
        create_5_successful_task_attempts(@all_tests_base_dir)

        subject.tasks_directory = @all_tests_base_dir

        # Override the before(:each) block for the whole RSpec so that we can
        # reuse the .rake files created once in the before(:all) block for this example group.
        @tasks_directory = @all_tests_base_dir
        subject.tasks_directory = @tasks_directory
      end

      let(:expected_already_ran_log_entries) {
        [
            { task_name: GOODTASK_SCOPED,
              task_source: File.join(subject.tasks_directory, BLORF_DIR, GOOD_TASK2_RAKEFILE),
              orig_rakefile: File.join(@all_tests_base_dir, Q2_DIR, GOOD_TASK_RAKEFILE) },

            { task_name: SET_WHEN_APPROVED_SCOPED,
              task_source: File.join(subject.tasks_directory, BLORF_DIR, SET_WHEN_APPR2_RAKEFILE),
              orig_rakefile: File.join(@all_tests_base_dir, Q1_DIR, SET_WHEN_APPR_RAKEFILE) },

            { task_name: SET_WHEN_APPROVED_SCOPED,
              task_source: File.join(subject.tasks_directory, BLORF2_DIR, SET_WHEN_APPR_RAKEFILE),
              orig_rakefile: File.join(@all_tests_base_dir, Q1_DIR, SET_WHEN_APPR_RAKEFILE) },

            { task_name: SOMETASK2_SCOPED,
              task_source: File.join(subject.tasks_directory, Q1_DIR, SOME_TASKS_RAKEFILE),
              orig_rakefile: File.join(@all_tests_base_dir, Q1_DIR, SOME_TASKS_RAKEFILE) },

            { task_name: SOMETASK3_SCOPED,
              task_source: File.join(subject.tasks_directory, Q1_DIR, SOME_TASKS_RAKEFILE),
              orig_rakefile: File.join(@all_tests_base_dir, Q1_DIR, SOME_TASKS_RAKEFILE) },
        ]
      }

      let(:expected_duplicates_log_entries) {
        { scoped_task(SIMPLETASK) => [File.absolute_path(subject.tasks_directory),
                                      File.absolute_path(File.join(subject.tasks_directory, BLORF_DIR)),
                                      File.absolute_path(File.join(subject.tasks_directory, BLORF2_DIR))],
          scoped_task(SOMETASK5) => [File.absolute_path(File.join(subject.tasks_directory, Q1_DIR)),
                                     File.absolute_path(File.join(subject.tasks_directory, BLORF2_DIR))] }
      }

      let(:expected_tasks_list) {
        expected_tasks = all_evaluated_tasks_in_files(subject.tasks_directory)

        expected_rakefiles_as_hash = Hash.new { |hash, key| hash[key] = [] }

        expected_tasks.each do |evaluated_task|
          expected_rakefiles_as_hash[evaluated_task.filename] << evaluated_task.name
        end

        expected_rakefiles_as_hash
      }


      it 'tasks to run are correct' do
        sometasks_rakefile = File.absolute_path(File.join(subject.tasks_directory, Q1_DIR, SOME_TASKS_RAKEFILE))
        runthis_rakefile = File.absolute_path(File.join(subject.tasks_directory, RUN_THIS_RAKEFILE))

        ev_sometask1 = OneTimeTasker::EvaluatedRakeTask.new('shf:test:some_task_1', sometasks_rakefile)
        ev_sometask4 = OneTimeTasker::EvaluatedRakeTask.new('shf:test:some_task_4', sometasks_rakefile)

        ev_runthis_task = OneTimeTasker::EvaluatedRakeTask.new('shf:test:run_this_task', runthis_rakefile)

        expected_tasks =
            { sometasks_rakefile => [ev_sometask1, ev_sometask4],
              runthis_rakefile => [ev_runthis_task]
            }

        actual_rakefiles_with_tasks = subject.files_with_tasks_to_run

        expect(actual_rakefiles_with_tasks.keys).to match_array(expected_tasks.keys), "expected: \n #{expected_tasks.keys.pretty_inspect} actual: \n#{actual_rakefiles_with_tasks.keys.pretty_inspect}"

        q1_sometasks = actual_rakefiles_with_tasks[sometasks_rakefile].tasks_to_run
        expect(q1_sometasks).to match_array(expected_tasks[sometasks_rakefile])

        runthis_tasks = actual_rakefiles_with_tasks[runthis_rakefile].tasks_to_run
        expect(runthis_tasks).to match_array(expected_tasks[runthis_rakefile])

      end

    end


    describe 'is empty' do

      it 'all tasks have been successfully run' do

        allow(subject).to receive(:successful_task_attempts)
                              .and_return([build(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task0'),
                                           build(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task1'),
                                           build(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task2')
                                          ])

        # Create 3 .rake files in the 2019_Q2 directory
        make_simple_rakefiles_under_subdir(subject.tasks_directory, Q2_DIR, 3)

        subject.files_with_tasks_to_run
        expect(subject.all_tasks_to_run).to be_empty
      end


      it 'all tasks are duplicates' do
        make_simple_rakefile_under_subdir(subject.tasks_directory, Q1_DIR, 'task0')
        make_simple_rakefile_under_subdir(subject.tasks_directory, Q2_DIR, 'task0')
        make_simple_rakefile_under_subdir(subject.tasks_directory, BLORF_DIR, 'task0')

        subject.files_with_tasks_to_run
        expect(subject.all_tasks_to_run).to be_empty
      end


      it 'all tasks have been run or are duplicates' do
        allow(subject).to receive(:successful_task_attempts)
                              .and_return([build(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task0'),
                                           build(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task1'),
                                           build(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task2')
                                          ])

        # Create 3 .rake files in the 2019_Q2 directory
        make_simple_rakefiles_under_subdir(subject.tasks_directory, Q2_DIR, 3)

        # duplicate tasks
        make_simple_rakefile_under_subdir(subject.tasks_directory, Q1_DIR, 'task0')
        make_simple_rakefile_under_subdir(subject.tasks_directory, Q2_DIR, 'task0')
        make_simple_rakefile_under_subdir(subject.tasks_directory, BLORF_DIR, 'task0')

        subject.files_with_tasks_to_run
        expect(subject.all_tasks_to_run).to be_empty
      end

    end
  end

end
