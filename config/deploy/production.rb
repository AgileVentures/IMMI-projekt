server ENV['SHF_PRODUCTION_SERVER'], user: ENV['DEPLOY_USER'], roles: %w{web db app}
set :ssh_options, forward_agent: true
