# Tasks to run to deploy the application.  Tasks defined here will be called by capistrano.

# If you are not familiar with Capistrano, you should read the documentation:
#   https://capistranorb.com/
#   https://github.com/capistrano/rails
#
# In addition, here are a few helpful links:
#   Good basic example of entire process using capistrano to deploy a Ruby on Rails application: https://semaphoreci.com/community/tutorials/how-to-use-capistrano-to-deploy-a-rails-application-to-a-puma-server
#   Good write-up explaining some about capistrano: https://piotrmurach.com/articles/working-with-capistrano-tasks-roles-and-variables/

# ============================================
# Capistrano configuration settings
#

# config valid only for Capistrano 3.11
lock '~> 3.11'

set :rbenv_type, :user
set :rbenv_ruby, '2.5.1'

set :application, 'shf'
set :repo_url, 'git@github.com:AgileVentures/shf-project.git'
set :branch, ENV['BRANCH']

set :deploy_to, ENV['APP_PATH']

# These files are shared among all deployments.  Every deployment has a
# link to these files.  They are not recreated (new) for each deployment.
# If any specific file for the system must remain the same from one
# deployment to the next, it should be listed here.
# These individual files are in the 'shared' directory on the production system: /var/www/shf/shared/
# (That is the convention for Capistrano deployments.)
#
# The public/google......html files are files that Google Webmaster tools looks
#   for to verify ownership and access to this site.
#   These files verify that  Google webmasters (e.g. Susanna & Ashley as of 2020/02/02)
#   are verified as to access this site with Google webmaster tools.
#   Do not remove these files!
#
# See the note below in the :linked_directories section for information about all of the map-markers files
append :linked_files, 'config/database.yml',
       'config/secrets.yml',
       '.env',
       'public/google052aa706351efdce.html',
       'public/google979ebbe196e9bd30.html',
       'public/favicon.ico',
       'public/apple-touch-icon.png',
       'public/apple-touch-icon-precomposed.png',
       'public/map-markers/m1.png',
       'public/map-markers/m2.png',
       'public/map-markers/m3.png',
       'public/map-markers/m4.png',
       'public/map-markers/m5.png',
       'public/map-markers/sv/m1.png',
       'public/map-markers/sv/m2.png',
       'public/map-markers/sv/m3.png',
       'public/map-markers/sv/m4.png',
       'public/map-markers/sv/m5.png',
       'public/map-markers/en/m1.png',
       'public/map-markers/en/m2.png',
       'public/map-markers/en/m3.png',
       'public/map-markers/en/m4.png',
       'public/map-markers/en/m5.png',
       'public/map-markers/sv/hundforetag/m1.png',
       'public/map-markers/sv/hundforetag/m2.png',
       'public/map-markers/sv/hundforetag/m3.png',
       'public/map-markers/sv/hundforetag/m4.png',
       'public/map-markers/sv/hundforetag/m5.png',
       'public/map-markers/en/hundforetag/m1.png',
       'public/map-markers/en/hundforetag/m2.png',
       'public/map-markers/en/hundforetag/m3.png',
       'public/map-markers/en/hundforetag/m4.png',
       'public/map-markers/en/hundforetag/m5.png',

# These directories are shared among all deployments.  Every deployment has a
# link to these directories.  They are not recreated (new) for each deployment.
# If any information or data for the system must remain the same from one
# deployment to the next, it should be listed here.
# These directories are in the 'shared' directory on the production system: /var/www/shf/shared/
# (That is the convention for Capistrano deployments.)
#
# We require 6 (!) directories for the map markers:
#  public/map-markers,
       #  public/en/map-markers,
       #  public/sv/map-markers,
       #  public/hundforetag,
       #  public/en/hundforetag/map-markers,
       #  public/sv/hundforetag/map-markers
#
# The application will create paths with the locale [sv|en] prepended, and then google-maps.js will
# use those in the relative path that it constructs to get the map-marker image files (m*.png files).
# The application creates the locale  paths because of the locale filter gem (used in the routes.rb) file.
# The root route (for non-logged in visitors) will look for the map markers in /public[][/sv|en]/map-markers.
# But often the path is specific to companies and so is /public[/sv|en]/hundforetag
# /sv/[hundforetag/]map-markers and /en/[hundforetag/]map-markers just have symbolic markers to the public/map-markers directory.
#   (This all seems a bit too complex, but it's what is needed to get this working.)
#
append  :linked_dirs, 'log',
        'tmp/pids',
        'tmp/cache',
        'tmp/sockets',
        'vendor/bundle',
        'public/system',
        'public/uploads',
        'public/storage',
        'public/ckeditor_assets',
        'app/views/pages',
        'public/map-markers',
        'public/sv/map-markers',
        'public/en/map-markers',
        'public/hundforetag/map-markers',
        'public/sv/hundforetag/map-markers',
        'public/en/hundforetag/map-markers'



# public/.well-known  created by diffouo (raoul) when this was set up. used for ??? (not used?)
# public/system       created by diffouo (raoul) when this was set up. used for ??? (not used?)
# public/uploads      created by diffouo (raoul) when this was set up. used for ??? (not used?)
# public/storage  Files uploaded for  membership applications
# public/ckeditor_assets Files uploaded by members, admins when using the ckeditor (ex: company page custom infor, SHF member documents)
# app/views/pages  Member Documents are stored here.  (Eventually they should moved to a different directory)

# ensure the binstubs (files in /bin) are generated
set :bundle_binstubs, nil

set :keep_releases, 5

set :migration_role, :app

# ============================================
# Tasks
#   See Task sequencing below, after the code for the tasks

namespace :deploy do


  # this ensures that the description (a.k.a. comment) for each task will be recorded
  Rake::TaskManager.record_task_metadata = true

  # ----------------------------------------------------
  # Tasks
  #

  desc 'run load_conditions task to put conditions into the DB'
  task run_load_conditions: [:set_rails_env] do | this_task |
    info_if_not_found = "The Conditions will NOT be loaded into the database. (task #{this_task} in #{__FILE__ })"
    run_task_from(this_task, 'shf:load_conditions', info_if_not_found)
  end


  desc 'run any one-time tasks that have not yet been run successfully'
  task run_one_time_tasks: [:set_rails_env] do | this_task |
    info_if_not_found = "No 'one_time' tasks will be run! (task #{this_task} in #{__FILE__ })"
    run_task_from(this_task, 'shf:one_time:run_onetime_tasks', info_if_not_found)
  end


  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      info 'Restarting...'
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end


  # Note: another way to accomplish this would be to put an entry in .gitattributes for every file to ignore.
  # However, I don't like mixing deployment information into git files.  (That couples the two systems and mixes responsibilities.)
  desc 'Remove testing related files'
  task :remove_test_files do

    on release_roles :all do

      # Because gems for these are not deployed,
      # Rake cannot load these files,
      # which then causes problems when trying to run any rake tasks on the deployment server.
      remove_files = ["#{current_path}/lib/tasks/ci.rake",
                      "#{current_path}/lib/tasks/cucumber.rake",
                      "#{current_path}/script/cucumber"].freeze

      remove_files.each { |remove_f| remove_file remove_f }


      # Remove testing directories since the gems for using them are not deployed.
      remove_dirs = ["#{current_path}/spec",
                     "#{current_path}/features"].freeze
      remove_dirs.each { |remove_d| remove_dir remove_d }

    end

  end


  # ----------------------------------------------------
  # Task sequencing:
  #

  before :publishing, :run_load_conditions
  after :run_load_conditions, :run_one_time_tasks

  # Have to wait until all files are copied and symlinked before trying to remove
  # these files.  (They won't exist until then.)
  before :restart, :remove_test_files

  after :publishing, :restart


  # ----------------------------------------------------
  # supporting methods
  #


  # execute a task and show an info line
  # If the task is not defined, print out the warning with info_if_missing appended.
  def run_task_from(_calling_task, task_name_to_run, info_if_missing = '')

    on release_roles :all do
      within release_path do
        with rails_env: fetch(:rails_env) do

          if task_is_defined?(task_name_to_run)
            #info task_invoking_info(calling_task.name, task_name_to_run)
            execute :rake, task_name_to_run
          else
            puts "\n>> WARNING! No task named #{task_name_to_run}. #{info_if_missing}\n\n"
          end
        end
      end
    end
  end


  # information string about a task that invoked another one
  def task_invoking_info(task_name, task_invoked_name)
    "[#{task_name}] invoking #{task_invoked_name}"
  end


  def remove_file(full_fn_path)
    if test("[ -f #{full_fn_path} ]") # if the file exists on the remote server
      execute %{rm -f #{full_fn_path} }
    else
      warn "File doesn't exist, so it could not be removed: #{full_fn_path}" # log and puts
    end
  end


  def remove_dir(full_dir_path)
    if test("[ -d #{full_dir_path} ]") # if the directory exists on the remote server
      execute %{rm -r #{full_dir_path} }
    else
      warn "Directory doesn't exist, so it could not be removed: #{full_dir_path}" # log and puts
    end
  end


  def task_is_defined?(task_name)
    puts "( checking to see if #{task_name} is defined )"
    result =  %x{bundle exec rake --tasks #{task_name} }
    result.include?(task_name) ? true : false
  end

end


# Run a rails console or a rails dbconsole
# @url https://gist.github.com/toobulkeh/8214198
#
# Note: this assumes that there is a /bin/rails  file that is capable of
# running a rails console.
#
# Usage:
#  bundle exec cap production rails:console
#  bundle exec cap production rails:dbconsole
namespace :rails do
  desc "Open the rails console"
  task :console do
    on roles(:app) do
      rails_env = fetch(:rails_env, 'production')
      execute_interactively "$HOME/.rbenv/bin/rbenv exec bundle exec rails console #{rails_env}"
    end
  end

  desc "Open the rails dbconsole"
  task :dbconsole do
    on roles(:app) do
      rails_env = fetch(:rails_env, 'production')
      execute_interactively "$HOME/.rbenv/bin/rbenv exec bundle exec rails dbconsole #{rails_env}"
    end
  end


  # ssh to the server
  def execute_interactively(command)
    server = fetch(:bundle_servers).first
    user   = server.user
    port   = server.port || 22

    exec "ssh -l #{user} #{host} -p #{port} -t 'cd #{deploy_to}/current && #{command}'"
  end
end
