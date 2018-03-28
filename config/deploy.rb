# config valid only for Capistrano 3.6
lock '3.6.1'

set :rbenv_type, :user
set :rbenv_ruby, '2.4.3'

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
set :linked_files, %w{config/database.yml config/secrets.yml .env}

# These directories are shared among all deployments.  Every deployment has a
# link to these directories.  They are not recreated (new) for each deployment.
# If any information or data for the system must remain the same from one
# deployment to the next, it should be listed here.
# These directories are in the 'shared' directory on the production system: /var/www/shf/shared/
# (That is the convention for Capistrano deployments.)
set :linked_dirs, %w{
  log tmp/pids tmp/cache tmp/sockets vendor/bundle
  public/system
  public/uploads
  public/.well-known
  public/storage
  public/ckeditor_assets
  app/views/pages
}

# public/.well-known  created by diffouo (raoul) when this was set up. used for ??? (not used?)
# public/system       created by diffouo (raoul) when this was set up. used for ??? (not used?)
# public/uploads      created by diffouo (raoul) when this was set up. used for ??? (not used?)
# public/storage  Files uploaded for  membership applications
# public/ckeditor_assets Files uploaded by members, admins when using the ckeditor (ex: company page custom infor, SHF member documents)
# app/views/pages  Member Documents are stored here.  (Eventually they should moved to a different directory)

# ensure the binstubs (files in /bin) are generated
set :bundle_binstubs, nil

set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end


  # Note: another way to accomplish this would be to put an entry in .gitattributes for every file to ignore.
  # However, I don't like mixing deployment information into git files.  (That couples the two systems and mixes responsibilities.)
  desc "Remove testing related files"
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


  def remove_file(full_fn_path)
    if test("[ -f #{full_fn_path} ]") # if the file exists on the remote server
      execute %{rm -f #{full_fn_path} }
    else
      warn "File doesn't exist, so it could not be removed: #{full_fn_path}" # log and puts
    end
  end


  def remove_dir(full_dir_path)
    if test("[ -f #{full_dir_path} ]") # if the file exists on the remote server
      execute %{rm -r #{full_dir_path} }
    else
      warn "Directory doesn't exist, so it could not be removed: #{full_dir_path}" # log and puts
    end
  end



  # Have to wait until all files are copied and symlinked before trying to remove
  # these files.  (They won't exist until then.)
  before :restart, :remove_test_files


  after  :publishing, :restart
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
    user = server.user
    port = server.port || 22

    exec "ssh -l #{user} #{host} -p #{port} -t 'cd #{deploy_to}/current && #{command}'"
  end
end
