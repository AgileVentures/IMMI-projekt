RSpec.shared_context 'simple rake task files maker' do

  SIMPLE_RAKE_TASK_LOGFILE = 'SimpleRakeTask-test'

  # Create a subdirectory <subdir> under <directory if it doesn't already exist,
  # and then create <num> simple rake files in <subdir>
  #
  # @return [Array[String]] - list of file names created
  def make_simple_rakefiles_under_subdir(directory, subdir, num = 1, start_num: 0)
    new_sub_dir = File.join(directory, subdir)
    Dir.mkdir(new_sub_dir) unless Dir.exist?(new_sub_dir)

    make_simple_rakefiles(new_sub_dir, num, start_num: start_num)
  end


  # Make <num> .rake files in the directory; each rake file contains 1 simple task
  # The name of the rake file is test<task number>.rake ("test" with the task number appended)
  # start_num = the first task number
  # @return [Array[String]] - list of file names created
  #
  def make_simple_rakefiles(directory, num = 1, start_num: 0)
    files_created = []
    num.times do |i|
      task_num = i + start_num
      fname = File.join(directory, "test#{task_num}.rake")
      files_created << fname
      File.open(fname, 'w') do |f|
        f.puts simple_rake_task("task#{task_num}")
      end
    end
    files_created
  end


  # Make a simple rakefile in the subdirectory under directory.
  # @return [String] - name of file created (full path)
  def make_simple_rakefile_under_subdir(directory, subdir, task_name = 'test-task', task_body = "\n")
    new_sub_dir = File.join(File.absolute_path(directory), subdir)
    Dir.mkdir(new_sub_dir) unless Dir.exist?(new_sub_dir)

    filepath_created = File.join(File.absolute_path(new_sub_dir), "#{task_name}.rake")
    File.open(filepath_created, 'w') do |f|
      f.puts simple_rake_task(task_name, task_body)
    end

    filepath_created
  end


  # Code for a simple task that logs when it is invoked.
  # The body of the task is given :task_body
  # Logs to a logfile named with SIMPLE_RAKE_TASK_LOGFILE
  #
  # @param task_name [String] - the task name
  # @param task_body [String] - the code for task. This is what will be run.
  #
  def simple_rake_task(task_name = 'test-task', task_body = "\n")

    "require 'active_support/logger'\n" +
        "namespace :shf do\n" +
        "  namespace :test do\n" +
        "    desc 'task named #{task_name}'\n" +
        "    task #{task_name}: :environment do\n" +
        "       logfile_name = LogfileNamer.name_for(SIMPLE_RAKE_TASK_LOGFILE)\n" +
        "       ActivityLogger.open(logfile_name, 'SimpleRakeTask', 'Load Dinkurs Events') do |log|\n" +
        task_body +
        "         log.record('info', 'Task #{__FILE__} #{task_name} has been invoked.')\n" +
        "       end\n" +
        "     end\n" +
        "  end\n " +
        "end\n"
  end

end
