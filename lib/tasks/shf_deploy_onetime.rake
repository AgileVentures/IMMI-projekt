# Tasks to run to deploy the application.  Tasks defined here can be called by capistrano.

require_relative '../one_time_tasker/tasks_runner'
require 'active_support/logger'


namespace :shf do

  namespace :one_time do

    DEFAULT_ONETIME_TASKS_DIR = File.join(Rails.root, 'lib', 'tasks', 'one_time') unless defined?(DEFAULT_ONETIME_TASKS_DIR)
    TASK_LOG_FN_START = 'Task_SHF_OneTime' unless defined?(TASK_LOG_FN_START)
    SET_PREV_ALREADY_RUN_FN = "#{TASK_LOG_FN_START}_PrevTasksMarkedAsRan.yml" unless defined?(SET_PREV_ALREADY_RUN_FN)


    desc 'Run any one time tasks not yet run. Rename rakefiles that run completely successfully. Argument = directory of rakefiles; default = Rails.root/lib/tasks/one_time'
    task :run_onetime_tasks, [:rakefiles_dir] => [:environment] do |task_name, args|

      Rake::Task["shf:one_time:set_prev_onetime_tasks_as_ran"].invoke(*args)

      if args_ok?(args, task_name)
        base_dir = set_basedir_from_args(args)

        OneTimeTasker::TasksRunner.tasks_directory = base_dir
        logfile_name = LogfileNamer.name_for(OneTimeTasker)

        ActivityLogger.open(logfile_name,
                            'SHF',
                            task_name, false
        ) do |log|
          OneTimeTasker::TasksRunner.run_onetime_tasks(log)
        end
      end
    end


    # Take all existing one_time rake files and tasks and record them as having been run.
    # OneTimeTasker will then know that they  have already been run.  (Doing
    # this initializes the info for them; it is like migrating their info into
    # the OneTimeTasker system.)
    #
    # Only run this if has _not_ been run before. And only run this ONCE.
    #
    # When this runs, create a file to record that this ran.  (This is what
    # is checked to see if it has been run before.)
    # This ensures that this task will only ever be run ONCE.
    #
    # When this does run:
    # 1. get all of the rake files and their tasks in the one-time directory
    # 2. set each rake file as successfully run:
    #      a) create and save a OneTimeTasker::SuccessfulTask for each task in the file
    #      b) rename the file with the OneTimeTasker::TasksRunner so that it will not be run again
    #
    desc 'Set all one-time task files to *.ran; add as SuccessfulTasks to db. Argument = directory of rakefiles; default = Rails.root/lib/tasks/one_time'
    task :set_prev_onetime_tasks_as_ran, [:rakefiles_dir] => [:environment] do |task, args|

      if set_prev_onetime_task_already_run?
        puts "#{task.name} has already been run so it will not be run this time. See #{full_filename_set_prev_run_task_has_run}"

      else
        logfile_name = LogfileNamer.name_for("#{TASK_LOG_FN_START}_#{ task.name.split(':').last }")

        if args_ok?(args, task.name)
          base_dir = set_basedir_from_args(args)

          ActivityLogger.open(logfile_name,
                              'SHF',
                              task.name, false) do |log|
            OneTimeTasker::TasksRunner.set_or_create_log(log,
                                                         log_facility_tag: OneTimeTasker::TasksRunner.log_facility_tag,
                                                         log_activity_tag: OneTimeTasker::TasksRunner.log_activity_tag)

            tasks_finder = OneTimeTasker::TasksFinder.new(log, logging: true)
            tasks_finder.tasks_directory = base_dir

            task_files_and_names = tasks_finder.files_with_tasks_to_run

            task_files_and_names.each do |_rakefile, ev_rakefile|
              rakefilename = ev_rakefile.filename
              ev_rakefile.tasks_to_run.each do |ev_task|
                OneTimeTasker::SuccessfulTaskAttempt.create(task_name: ev_task.name,
                                                            task_source: rakefilename)
                log.info("A SuccessfulTaskAttempt was recorded for the one-time task #{ev_task.name} (previously run).")
              end
              OneTimeTasker::TasksRunner.rename_rakefile(rakefilename, log) # this logs the files renamed AE CHANGED 20210704- added log param
            end
          end

          record_set_prev_onetime_task_as_ran(task.name)

        else
          ActivityLogger.open(logfile_name,
                              'SHF',
                              task.name, false) do |log|

            log.error("Bad/wrong arguments for #{task.name}")
            log.error(" Arguments given: #{args.to_hash.values}")
            log.error(" Args should be empty (to use the default directory #{DEFAULT_ONETIME_TASKS_DIR}")
            log.error(" or provide the directory that will have the .rake files to run.")
            log.error(" Ex: #{task.name}[some/dir/with/rake/files]")

          end
        end
      end

    end


    # ----------------------------------------------------------------------
    # supporting methods


    def args_ok?(args, task_name)
      args_are_ok = true

      if args.has_key? :rakefiles_dir
        given_dir = dir_with_pwd(args[:rakefiles_dir])

        unless Dir.exist?(given_dir)
          puts "\n#{task_name} ERROR: directory does not exist: #{File.absolute_path(given_dir)}\n   No rakefiles read.\n"
          args_are_ok = false
        end
      end
      args_are_ok
    end


    def dir_with_pwd(dir)
      File.join(FileUtils.pwd, dir)
    end


    def set_basedir_from_args(args)
      args.has_key?(:rakefiles_dir) ? dir_with_pwd(args[:rakefiles_dir]) : DEFAULT_ONETIME_TASKS_DIR
    end


    # TODO could use LogfileNamer if we could specify the file extension
    def full_filename_set_prev_run_task_has_run
      env_prefix = Rails.env.production? ? '' : "#{Rails.env}_"
      File.join(Rails.configuration.paths['log'].absolute_current, "#{env_prefix}#{SET_PREV_ALREADY_RUN_FN}")
    end


    # @return [Boolean] - has :set_prev_onetime_tasks_as_ran already been run?
    def set_prev_onetime_task_already_run?
      # check for the file
      File.exist?(full_filename_set_prev_run_task_has_run)
    end


    # Create a .yml file to record that the :set_prev_onetime_tasks_as_ran task has been run
    def record_set_prev_onetime_task_as_ran(task_name)

      File.open(full_filename_set_prev_run_task_has_run, 'w') do |f|
        f.puts '---'
        f.puts '# DO NOT DELETE THIS FILE.'
        f.puts "# This file is here to record that the task #{task_name} has been run."
        f.puts '#'
        f.puts '# Other rake tasks will check to see if this file exists or not and may run tasks accordingly.'
        f.puts 'tasks:'

        indent_amt = 2
        indent = indent_amt
        task_sections = task_name.split(':')
        task_sections.each do |s|
          f.puts "#{' ' * indent}#{s}:"
          indent += indent_amt
        end
        f.puts "#{' ' * indent}ran: true"
        f.puts "#{' ' * indent}date_ran: #{Time.zone.now}"
      end
    end

  end

end
