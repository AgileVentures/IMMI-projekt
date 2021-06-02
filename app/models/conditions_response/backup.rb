#require_relative File.join(__dir__, 'shf_condition_error_backup_error')
require_relative 'shf_condition_error_backup_error'

# Errors
module ShfConditionError

  class BackupCommandNotSuccessfulError < BackupError; end


  class BackupConfigError < BackupError; end


  class BackupConfigFileSetBadFormatError < BackupConfigError; end


  class BackupConfigFileSetMissingNameError < BackupConfigError; end


  class BackupConfigFileSetMissingBaseNameError < BackupConfigError; end


  class BackupConfigFileSetMissingSourceFiles < BackupConfigError; end


  class BackupConfigFileSetEmptySourceFiles < BackupConfigError; end
end

# Backup files and DB data in production

# FIXME: some class methods require a class attribute to be set to work
#        correctly, @use_slack_notification. The only point where we
#        can set that attribute is in `::condition_response`, but the other
#        methods are public and can be called independently, causing them to
#        behave erratically depending on the last call of
#        `::condition_response` or lack thereof.
#        As a stopgap measure I added an extra optional parameter to every
#        method signature, but we should really consider if those methods
#        should be private or if we should make this class non-static.
#
# TODO: Do not back up user uploaded files with the SHF system/data.  Back those up separately if needed.
#
class Backup < ConditionResponder

  DEFAULT_BACKUP_FILES_DIR = '/home/deploy/SHF_BACKUPS/'
  DEFAULT_DB_BACKUPS_TO_KEEP = 15

  # YYYY-MM-DD-HHMM-SS<millisec)>-Z
  # provide minutes, seconds, etc. so that multiple backups per day can be kept
  FILENAME_SUFFIX_TIMESTAMP_FMT = '%F-%H%M-%S%L-Z'

  # -------------

  def self.condition_response(condition, log, use_slack_notification: true)

    @use_slack_notification = use_slack_notification

    validate_timing(get_timing(condition), [TIMING_EVERY_DAY], log)

    config = get_config(condition)
    backup_makers = create_backup_makers(config)


    # Backup each backup_maker to local storage
    backup_files = []
    backup_dir = backup_dir(config)

    aws_s3 = s3_backup_resource
    aws_s3_backup_bucket = s3_backup_bucket
    aws_backup_bucket_full_prefix = s3_backup_bucket_full_prefix

    iterate_and_log_notify_errors(backup_makers, 'while in the backup_makers.each loop', log) do |backup_maker|

      # Create a full file path that will be in the backup_directory,
      # and have the filename and extension provided by the backup_maker,
      # but with with date and '.gz' appended.
      backup_file = backup_target_fn(backup_dir, backup_maker[:backup_maker].base_filename)
      backup_files << backup_file

      log.record('info', "Backing up to: #{backup_file}")

      # this will use the default backup sources set when the backup_maker was created
      backup_maker[:backup_maker].backup(target: backup_file)
    end

    log.record('info', 'Moving backup files to AWS S3')

    iterate_and_log_notify_errors(backup_files, 'in backup_files loop, uploading_file_to_s3', log) do |backup_file|
      upload_file_to_s3(aws_s3, aws_s3_backup_bucket, aws_backup_bucket_full_prefix, backup_file)
    end

    log.record('info', 'Pruning older backups on local storage')

    iterate_and_log_notify_errors(backup_makers, 'while pruning in the backup_makers.each loop', log) do |backup_maker|
      file_pattern = get_backup_files_pattern(backup_dir, backup_maker[:backup_maker].base_filename)
      delete_excess_backup_files(file_pattern, backup_maker[:keep_num])
    end

  rescue Slack::Notifier::APIError => slack_error
    # Halt the backup if we cannot write to Slack; raise the error
    raise slack_error

  rescue => backup_error
    log_and_notify(backup_error, log)

  end


  def self.backup_dir(config)
    config.dig(:backup_directory) || DEFAULT_BACKUP_FILES_DIR
  end


  def self.backup_target_fn(backup_dir, backup_base_fn)
    File.join(backup_dir, backup_base_fn + '.' + backup_timestamp + '.gz')
  end


  def self.backup_timestamp
    Time.now.strftime FILENAME_SUFFIX_TIMESTAMP_FMT
  end


  # return the Aws::S3::Resource where we put the backups
  def self.s3_backup_resource
    Aws::S3::Resource.new(
      region: ENV['SHF_AWS_S3_BACKUP_REGION'],
      credentials: Aws::Credentials.new(ENV['SHF_AWS_S3_BACKUP_KEY_ID'],
                                        ENV['SHF_AWS_S3_BACKUP_SECRET_ACCESS_KEY']))
  end


  def self.s3_backup_bucket
    ENV['SHF_AWS_S3_BACKUP_BUCKET']
  end


  def self.s3_backup_bucket_full_prefix(today = Date.current)
    "#{ENV['SHF_AWS_S3_BACKUP_TOP_PREFIX']}/#{today.year}/#{today.strftime("%m")}/#{today.strftime("%d")}/"
  end


  # @see https://aws.amazon.com/blogs/developer/uploading-files-to-amazon-s3/
  def self.upload_file_to_s3(s3, bucket, bucket_folder, file)
    obj = s3.bucket(bucket).object(bucket_folder + File.basename(file))
    obj.upload_file(file, { tagging: aws_date_tags })
  end


  # @return [String] - tags about the current date, formatted as 1 long string of key=value pairs with '&' between each
  #    date-year=yyyy     (yyyy = year)
  #    date-month-num=mm  (mm = 2 digit month number, 0 padded)
  #    date-month-day=dd  (dd = 2 digit day of the month, 0 padded)
  #    date-weekday=wwww...w (weekday name [English])
  #   where mm = the 2 digit month number, dd = the 2 digit day of the month, wwww...w is the name of the weekday
  #   These tags can be used for keeping certain weekly copies (e.g. all on Monday, etc.), and
  #   certain copies on a particular day of the month (e.g. keep all backups on the 1st of the month)
  def self.aws_date_tags(today = Date.current)
    ["date-year=#{today.year}",
     "date-month-num=#{today.strftime("%m")}",
     "date-month-day=#{today.day}",
     "date-weekday=#{today.strftime("%A").downcase}"].join('&')
  end


  def self.get_backup_files_pattern(backup_dir, filename)
    File.join(backup_dir, filename) + '.*'
  end


  def self.delete_excess_backup_files(file_pattern, number_of_files_to_keep)

    backup_files = Dir.glob(file_pattern)

    number_of_backup_files = backup_files.length

    if number_of_backup_files > number_of_files_to_keep

      delete_files = backup_files.sort[0, number_of_backup_files - number_of_files_to_keep]

      delete_files.each { |file| File.delete(file) }
    end
  end


  def self.create_backup_makers(config)

    num_db_backups_to_keep = config.dig(:days_to_keep, :db_backup) || DEFAULT_DB_BACKUPS_TO_KEEP

    # :keep_num key defines how many daily backups to retain on _local_ storage (e.g. on the production machine)
    # AWS (S3) backup files are retained based on settings in AWS.
    backup_makers = [
      { backup_maker: ShfBackupMakers::DBBackupMaker.new, keep_num: num_db_backups_to_keep }
    ]

    fileset_backup_makers = create_fileset_backup_makers(config)
    fileset_backup_makers.each do |fileset_backup_maker|
      backup_makers << { backup_maker: fileset_backup_maker, keep_num: fileset_backup_maker.days_to_keep }
    end

    backup_makers
  end


  # Create a FileSetBackupMaker for each definition in the config
  #
  # @param [String] config - the configuration
  # @return [Array[FileSetBackupMakers]] - a list of FileSetBackupMakers
  #           instantiated based on entries in the config
  def self.create_fileset_backup_makers(config)

    return [] unless config.has_key?(:filesets)

    filesets = config.fetch(:filesets, false)
    raise ShfConditionError::BackupConfigFileSetBadFormatError.new("Backup Condition configuration error. fileset: must be an Array.") unless filesets.is_a?(Array)

    filesets.map(&method(:new_fileset_backup_maker)).compact
  end


  # Create a new FileSetBackupMaker from information in the fileset_config
  # Raise errors if information is missing or the format is bad.
  #
  # @return [ShfBackupMakers::FileSetBackupMaker] - the new FileSetBackupMaker
  #
  def self.new_fileset_backup_maker(fileset_config)

    raise ShfConditionError::BackupConfigFileSetMissingNameError unless fileset_config.has_key?(:name)
    fileset_name = fileset_config[:name]

    raise ShfConditionError::BackupConfigFileSetMissingSourceFiles unless fileset_config.has_key?(:files)
    sources = fileset_config_array_entry(fileset_config, :files, fileset_name)
    raise ShfConditionError::BackupConfigFileSetEmptySourceFiles if sources.empty?

    excludes = fileset_config_array_entry(fileset_config, :excludes, fileset_name)

    fsb = ShfBackupMakers::FileSetBackupMaker.new(name: fileset_name,
                                                  backup_sources: sources,
                                                  excludes: excludes)

    fsb.base_filename = fileset_config[:base_filename] if fileset_config.has_key?(:base_filename)
    fsb.days_to_keep = fileset_config[:days_to_keep] if fileset_config.has_key?(:days_to_keep)

    fsb
  end


  # Get the value for an entry in a hash and
  # validate that the value is an Array.
  # If it is not an Array, raise ShfConditionError::BackupConfigFileSetBadFormatError
  # with an error message, specifying the fileset name and the key that should
  # have had a value that was an array
  #
  # @return [Array] - the value from the array
  #
  def self.fileset_config_array_entry(hash, key, fileset_name)
    array_entry = hash.fetch(key, [])
    unless array_entry.is_a?(Array)
      raise ShfConditionError::BackupConfigFileSetBadFormatError.new("Backup Condition configuration for fileset '#{fileset_name}' error. #{key}: must be an Array.")
    end

    array_entry
  end


  # Iterate through the list, rescuing errors. If it's a Slack error,
  # log and raise the error (stop iterating).
  # For any other error, log  and send a notification
  # and continue iterating via the 'next' keyword.
  #
  # @param [Enumerable] list - items we are iterating through
  # @param [String] additional_error_info - additional information to include
  #                  when logging or notifying
  # @param [Log] log - the log to write to
  #
  def self.iterate_and_log_notify_errors(list, additional_error_info, log, use_slack_notification: @use_slack_notification)

    list.each do |item|
      yield(item)

    rescue Slack::Notifier::APIError => slack_error
      # Halt the backup if we cannot write to Slack; raise the error
      raise slack_error

    rescue => backup_error
      log_and_notify(backup_error, log, "#{additional_error_info}. Current item: #{item.inspect}", use_slack_notification: use_slack_notification)
      next
    end
  end


  # Record the error and additional_info to the given log
  # and send a Slack notification if we are using Slack notifications
  # TODO  this seems like a general-purpose method that we need in many places.  Refactor into a class/module to be available all places
  #
  # @param [Error] original_error - Error that needs to be recorded
  # @param [Log] log - the log to write to. Must respond to :error(message)
  # @param [String] additional_info - any additional information that should also be recorded. Default = ''
  #
  def self.log_and_notify(original_error, log, additional_info = '', use_slack_notification: @use_slack_notification)

    log_string = additional_info.blank? ? original_error.to_s : "#{original_error} #{additional_info}"

    log.error(log_string)
    SHFNotifySlack.failure_notification(self.name, text: log_string) if use_slack_notification

    # If the problem is because of Slack Notification, log it and raise it
    #  so the caller can deal with it as needed.
  rescue Slack::Notifier::APIError => slack_error

    log.error("Slack error during #{self.name}.#{__method__}: #{slack_error.inspect}")
    raise slack_error

    # ... Otherwise, an exception was raised during writing to the log.
    # Send a slack notification about that and continue (do _not_ raise it).
  rescue => not_a_slack_error
    if use_slack_notification
      # send a notification about the original error
      SHFNotifySlack.failure_notification(self.name, text: log_string)

      # send another notification about the error that happened in this method
      SHFNotifySlack.failure_notification(self.name, text: "Error: Could not write to the log in #{self.name}.#{__method__}: #{not_a_slack_error}")
    end

  end


  def self.slack_error_encountered_str(during_method = 'condition_response')
    "Slack Notification failure during #{self.name}.#{during_method}"
  end

end
