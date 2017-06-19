# config valid only for Capistrano 3.6
lock '3.6.1'

set :rbenv_type, :user
set :rbenv_ruby, '2.4.1'

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
  bin log tmp/pids tmp/cache tmp/sockets vendor/bundle
  public/system
  public/uploads
  public/.well-known
  public/storage
  public/ckeditor_assets
}

# public/.well-known  created by diffouo (raoul) when this was set up. used for ??? (not used?)
# public/system       created by diffouo (raoul) when this was set up. used for ??? (not used?)
# public/uploads      created by diffouo (raoul) when this was set up. used for ??? (not used?)
# public/storage  Files uploaded for  membership applications
# public/ckeditor_assets Files uploaded by members, admins when using the ckeditor (ex: company page custom infor, SHF member documents)


set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart
end
