require_relative 'tasks_finder'
require_relative 'log_creator'
require_relative 'activity_log_tags'

require 'rake'
require 'active_support/logger'


module OneTimeTasker

  #--------------------------
  #
  # @class TasksRunner
  #
  # @desc Responsibility: Run Rake tasks once.  Find them, invoke (run) them,
  #   record success or failure, and change the .rake file name if all of the
  #   tasks in it were run successfully.
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2019-06-04
  #
  #
  # To make into a gem:
  # TODO: I18n
  # TODO: generate initializer file, db:migrate
  #
  #--------------------------
  class TasksRunner

    extend LogCreator
    extend ActivityLogTags


    DEFAULT_ONE_TIME_TASKS_DIR = File.join(__dir__, '..', '..', 'lib', 'tasks', 'one_time') unless defined?(OneTimeTasker::TasksRunner::DEFAULT_ONE_TIME_TASKS_DIR)

    # This is the directory that the TasksFinder will look for .rake files.
    # It will search in this directory and any and all subdirectories.
    mattr_accessor :tasks_directory, instance_accessor: false
    @@tasks_directory = DEFAULT_ONE_TIME_TASKS_DIR


    RAKEFILE_SUCCESS_POSTFIX = '.ran' unless defined?(OneTimeTasker::TasksRunner::RAKEFILE_SUCCESS_POSTFIX)
    # If all of the tasks in a rakefile have run successfully,
    # this is appended to the rakefile name as a way to prevent the
    # rakefile from being run again.
    # Default is '.ran' so a rakefile becomes "some_name.rake.ran"
    mattr_accessor :successful_rakefile_extension, instance_accessor: false
    @@successful_rakefile_extension = RAKEFILE_SUCCESS_POSTFIX


    # These 2 constants are used in ActivityLogTags methods:
    DEFAULT_LOG_FACILITY_TAG = self.name unless defined?(OneTimeTasker::TasksRunner::DEFAULT_LOG_FACILITY_TAG)
    DEFAULT_LOG_ACTIVITY_TAG = 'Run onetime tasks' unless defined?(OneTimeTasker::TasksRunner::DEFAULT_LOG_ACTIVITY_TAG)


    # ==========================================================================


    # Load each Rake file that should be run and invoke the tasks in it.
    # Record a TaskAttempt for each invoked task.
    #
    # If all of the tasks in a rake file were successful,
    # then append RAKEFILE_SUCCESS_POSTFIX to the filename so that it cannot be
    # accidentally run again.
    #
    # @param log [nil | ActivityLogger] - a log that can respond to :info and :error
    #         if nil, this will create a log and write to it
    # @param logging [boolean] - write information to a log (default = true)
    #
    def self.run_onetime_tasks(given_log = nil, logging: true)

      set_or_create_log(given_log, logging: logging,
                        log_facility_tag: self.log_facility_tag,
                        log_activity_tag: self.log_activity_tag)

      @tasks_finder = TasksFinder.new(given_log, logging: logging)

      tasks_finder.tasks_directory = self.tasks_directory
      task_files_and_names = tasks_finder.files_with_tasks_to_run

      task_files_and_names.each do |_rakefile, ev_rakefile|
        invoke_tasks_in_rakefile(ev_rakefile, log)
      end

      close_log_if_this_created_it(log)

    rescue => error
      log.error("Error during #{self.class.name}  #{__method__}!  #{error}") unless log.nil?
      raise error
    end


    def self.task_invoked_successfully?(task_name, rakefile)

      # TODO: loading this multiple times: (once per task). Could be more efficient.
      Rake.load_rakefile(rakefile)

      Rake.application[task_name].invoke

      log.info(task_succeeded_log_entry(task_name))
      record_successful_task_attempt(task_name, rakefile)
      true

    rescue => error
      log.error(task_failed_log_entry(task_name, error))
      record_failed_task_attempt(task_name, rakefile, error)
      false
    end


    def self.record_successful_task_attempt(task_name, rake_file_source)
      OneTimeTasker::SuccessfulTaskAttempt.create(task_name: task_name,
                                                  task_source: rake_file_source)
    end


    def self.record_failed_task_attempt(task_name, rake_file_source, error)
      OneTimeTasker::FailedTaskAttempt.create(task_name: task_name,
                                              task_source: rake_file_source,
                                              notes: error.to_s)
    end


    # Change the rake filename so it cannot accidentally be run
    # If there is an error raised, write it to the log file
    # but do NOT raise it so processing can continue (other tasks can be invoked).
    def self.rename_rakefile(rakefile_fn, log)

      rakefile_abs = File.absolute_path(rakefile_fn)
      new_filename = new_rakefilename(rakefile_fn)
      File.rename(rakefile_abs, new_filename)
      log.info(rakefile_renamed_log_entry(rakefile_fn, new_filename))

    rescue => error
      log.error(error_renaming_rakefile_log_entry(rakefile_abs, error))
      # don't raise the error so that processing can continue
    end


    # New filename for the rakefile: append successful_rakefile_extension
    def self.new_rakefilename(rakefile_fn)
      rakefile_abs = File.absolute_path(rakefile_fn)
      "#{rakefile_abs}#{self.successful_rakefile_extension}"
    end


    def self.tasks_finder
      @tasks_finder ||= TasksFinder.new
    end


    # Configure the TasksRunner
    #
    # @example  This can be used in config/initializers/one_time_tasks_runner.rb
    #
    #   OneTimeTasker::TasksRunner.configure do | config |
    #     config.successful_rakefile_extension = '.ran'
    #     config.tasks_directory = File.join(Rails.root, 'lib', 'tasks', 'one_time')
    #     config.log_facility_tag = 'OneTimeTasker::TasksRunner'
    #     config.log_activity_tag = 'run one time tasks'
    #   end
    #
    def self.configure
      yield self
    end


    # for resetting to the original default
    def self.default_successful_rakefile_extension
      RAKEFILE_SUCCESS_POSTFIX
    end


    # for resetting to the original default
    def self.default_tasks_directory
      File.absolute_path(DEFAULT_ONE_TIME_TASKS_DIR)
    end


    # for resetting to the original default
    def self.default_log_facility_tag
      DEFAULT_LOG_FACILITY_TAG
    end


    # for resetting to the original default
    def self.default_log_activity_tag
      DEFAULT_LOG_ACTIVITY_TAG
    end


    # TODO - these should use I18n
    def self.task_succeeded_log_entry(task_name)
      "One-time task #{task_name} was run on #{Time.zone.now}"
    end


    def self.task_failed_log_entry(task_name, error)
      "Task #{task_name} did not run successfully: #{error}"
    end


    def self.rakefile_renamed_log_entry(rakefile_fn, new_filename)
      "Rakefile renamed from #{rakefile_fn} to #{new_filename}"
    end


    def self.error_renaming_rakefile_log_entry(rakefile_fn, error)
      "Could not append #{RAKEFILE_SUCCESS_POSTFIX} to the rakefile: #{rakefile_fn}. Error: #{error}"
    end



    # Invoke the tasks in an Evaluated rake file.  If _all_ of the tasks
    # invoked pass and these are all of the tasks in the rake file,
    # rename the rake file.
    def self.invoke_tasks_in_rakefile(ev_rakefile, log)
      num_passed = 0
      rakefilename = ev_rakefile.filename
      ev_rakefile.tasks_to_run.each do |ev_task|
        num_passed += 1 if task_invoked_successfully?(ev_task.name, rakefilename)
      end

      rename_rakefile(rakefilename, log) if num_passed == ev_rakefile.total_number_of_tasks
    end

  end

end
