# config valid only for Capistrano 3.6
lock '3.6.1'

set :rbenv_type, :user
set :rbenv_ruby, '2.3.1'

set :application, 'shf'
set :repo_url, 'git@github.com:AgileVentures/shf-project.git'
set :branch, ENV['BRANCH']

set :deploy_to, ENV['APP_PATH']

set :linked_files, %w{config/database.yml config/secrets.yml .env}

set :linked_dirs, %w{
  bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system
  public/uploads public/.well-known
}

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
