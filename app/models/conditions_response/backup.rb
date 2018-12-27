# Backup code and DB data in production

class Backup < ConditionResponder

  CODE_ROOT_DIRECTORY = '/var/www/shf/current/'
  DB_NAME = 'shf_project_production'

  CODE_BACKUP_FILEBASE = 'current.tar.'
  DB_BACKUP_FILEBASE   = 'db_backup.sql.'

  DEFAULT_BACKUP_FILES_DIR     = '/home/deploy/SHF_BACKUPS/'
  DEFAULT_CODE_BACKUPS_TO_KEEP = 4
  DEFAULT_DB_BACKUPS_TO_KEEP   = 15

  def self.condition_response(condition, log)

    unless timing_is_every_day?(get_timing(condition))
      msg = "Cannot handle timing other than #{TIMING_EVERY_DAY}"
      log.record('error', msg)
      raise ArgumentError, msg
    end

    config = get_config(condition)

    # "keep" key defines how many daily backups to retain on _local_ storage.
    # AWS (S3) backup files are retained based on settings in AWS.

    code_backups_to_keep = config.dig(:days_to_keep, :code_backup) || DEFAULT_CODE_BACKUPS_TO_KEEP
    db_backups_to_keep =   config.dig(:days_to_keep, :db_backup) || DEFAULT_DB_BACKUPS_TO_KEEP

    backup_targets = [
        { filebase: CODE_BACKUP_FILEBASE, type: :file, keep: code_backups_to_keep },
        { filebase: DB_BACKUP_FILEBASE,   type: :db,   keep: db_backups_to_keep }
    ]

    backup_dir = config.dig(:backup_directory) || DEFAULT_BACKUP_FILES_DIR

    today = Time.now.strftime '%Y-%m-%d'

    # Backup to local storage

    backup_files = []

    backup_targets.each do |backup_target|

      backup_file = backup_dir + backup_target[:filebase] + today + '.gz'
      backup_files << backup_file

      log.record('info', "Backing up to: #{backup_file}")

      case backup_target[:type]
      when :file
        backup_code(backup_file, CODE_ROOT_DIRECTORY)
      when :db
        backup_db(backup_file, DB_NAME)
      end
    end


    # Copy backup files to S3

    log.record('info', 'Moving backup files to AWS S3')

    s3, bucket, bucket_folder = get_s3_objects(today)

    backup_files.each { |file| upload_file_to_s3(s3, bucket, bucket_folder, file) }


    # Prune older backups beyond "keep" (days) limit

    log.record('info', 'Pruning older backups on local storage')

    backup_targets.each do |backup_target|

      file_pattern = get_backup_files_pattern(backup_dir, backup_target[:filebase])

      delete_excess_backup_files(file_pattern, backup_target[:keep])

    end
  end


  def self.backup_code(backup_file, code_root_directory)
    %x<tar -chzf #{backup_file} #{code_root_directory}>
  end


  def self.backup_db(backup_file, db_name)
    %x(pg_dump -d #{db_name} | gzip > #{backup_file})
  end


  def self.get_s3_objects(today)
    s3 = Aws::S3::Resource.new(
        region:      ENV['SHF_AWS_S3_BACKUP_REGION'],
        credentials: Aws::Credentials.new(ENV['SHF_AWS_S3_BACKUP_KEY_ID'],
                                          ENV['SHF_AWS_S3_BACKUP_SECRET_ACCESS_KEY']))

    bucket = ENV['SHF_AWS_S3_BACKUP_BUCKET']

    bucket_folder = "production_backup/#{today}/" # S3 will show objects in folders

    [s3, bucket, bucket_folder]
  end


  def self.upload_file_to_s3(s3, bucket, bucket_folder, file)
    obj = s3.bucket(bucket).object(bucket_folder + File.basename(file))

    obj.upload_file(file)
  end


  def self.get_backup_files_pattern(backup_dir, beginning_of_file_name)
    backup_dir + beginning_of_file_name + '*'
  end


  def self.delete_excess_backup_files(file_pattern, number_of_files_to_keep)

    backup_files = Dir.glob(file_pattern)

    number_of_backup_files = backup_files.length

    if number_of_backup_files > number_of_files_to_keep

      delete_files = backup_files.sort[0, number_of_backup_files - number_of_files_to_keep]

      delete_files.each { |file| File.delete(file) }
    end
  end
end
