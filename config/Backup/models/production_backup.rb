# encoding: utf-8

##
# Backup Generated: production_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t production_backup [-c <path_to_configuration_file>]
#

#-------
# Note that we have to explicitly load the .env file to get
# the database password information.  This backup is *not* running as part of Rails,
# so we need to use the dotenv gem to load the information manually:

require 'dotenv'
Dotenv.load('/var/www/shf/shared/.env')



Backup::Model.new(:production_backup, 'Description for production_backup') do
  ##
  # Split [Splitter]
  #
  # Split the backup file in to chunks of 250 megabytes
  # if the backup file size exceeds 250 megabytes
  #
  split_into_chunks_of 250



  compress_with Gzip


  ##
  # PostgreSQL [Database]
  #
  # backup the database
  database PostgreSQL do |db|

    db.name               = "shf_project_production"
    db.username           = "deploy"
    db.password           = ENV['SHF_PROJECT_DATABASE_PASSWORD']

    db.skip_tables        = []

    db.additional_options = []
  end


  ##
  # Archive the application itself (all code)
  #
  archive :rails_codebase_archive do |archive|
   # archive.use_sudo
    app_root = '/var/www/shf/'
    app_shared = "#{app_root}shared/"   # shared for all releases

    archive.add "#{app_shared}.env"
    archive.add "#{app_shared}bin/"
    archive.add "#{app_shared}config/"
    archive.add "#{app_shared}log/"
    archive.add "#{app_shared}public/"
    archive.add "#{app_root}Gemfile"
    archive.add "#{app_root}Gemfile.lock"

  end


  ##
  # store the backup as a local copy:
  #  Local (Copy) [Storage]
  #
  store_with Local do |local|
    local.path       = '~/BACKUPS/'
    local.keep       = 45
  end


 ##
 # TODO:  add a Notifier


end
