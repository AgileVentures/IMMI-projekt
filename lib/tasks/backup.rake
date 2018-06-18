require 'active_support/logger'

LOG_FILE = 'log/backup'
BACKUP_FILES_DIR = '/home/deploy/SHF_BACKUPS/'

CODE_BACKUPS_TO_KEEP = 4
DB_BACKUPS_TO_KEEP = 15


# "keep" key defines how many backups (code or DB) to retain on _local_ storage.
# AWS (S3) backup files are retained based on settings in AWS.
BACKUP_TARGETS = [
  { location: '/var/www/shf/current/', filebase: 'current.tar.',
    type: 'file', keep: CODE_BACKUPS_TO_KEEP },
  { location: 'shf_project_production', filebase: 'db_backup.sql.',
    type: 'db', keep: DB_BACKUPS_TO_KEEP }
]

desc 'backup code and DB'
task :backup => [:environment] do

  ActivityLogger.open(LOG_FILE, 'SHF_TASK', 'Backup') do |log|

    today = Time.now.strftime '%Y-%m-%d'

    # Backup to local storage

    backup_files = []

    BACKUP_TARGETS.each do |backup_target|

      backup_file = BACKUP_FILES_DIR + backup_target[:filebase] + today + '.gz'
      backup_files << backup_file

      log.record('info', "Backing up to: #{backup_file}")

      case backup_target[:type]
      when 'file'
        %x<tar -chzf #{backup_file} #{backup_target[:location]}>

      when 'db'
        %x(pg_dump -d #{backup_target[:location]} | gzip > #{backup_file})

      end

    end

    # Copy backup files to S3

    log.record('info', 'Moving backup files to AWS S3')

    s3 = Aws::S3::Resource.new(
      region: ENV['SHF_AWS_S3_BACKUP_REGION'],
      credentials: Aws::Credentials.new(ENV['SHF_AWS_S3_BACKUP_KEY_ID'],
                                        ENV['SHF_AWS_S3_BACKUP_SECRET_ACCESS_KEY']))

    bucket = ENV['SHF_AWS_S3_BACKUP_BUCKET']

    bucket_folder = "production_backup/#{today}/" # S3 will show objects in folders

    backup_files.each do |file|
      obj = s3.bucket(bucket).object(bucket_folder + File.basename(file))

      obj.upload_file(file)
    end

    # Prune older backups beyond "keep" (days) limit

    log.record('info', 'Pruning older backups on local storage')

    BACKUP_TARGETS.each do |backup_target|
      file_pattern = BACKUP_FILES_DIR + backup_target[:filebase] + '*'
      backup_files = Dir.glob(file_pattern)

      if backup_files.length > backup_target[:keep]
        delete_files = backup_files.sort[0, backup_files.length - backup_target[:keep]]

        delete_files.each { |file| File.delete(file) }
      end
    end

  end
end
