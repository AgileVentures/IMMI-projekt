require 'rails_helper'

require 'shared_examples/shared_conditions'
require 'shared_context/activity_logger'
require 'shared_context/expect_tar_has_entries'
require 'matchers/matcher_file_set_backup'

RSpec.describe Backup, type: :model do

  before(:each) do
    @logfilename = LogfileNamer.name_for(Condition)
    File.delete(@logfilename) if File.exist?(@logfilename)

    # stub actually sending Slack notifications
    allow(SHFNotifySlack).to receive(:notification)
  end

  after(:each) do
    File.delete(@logfilename) if File.exist?(@logfilename)
  end


  describe 'Acceptance tests' do

    include_context 'create logger'
    include_context 'expect tar file has entries'


    # Make the same directories as a Rails app under a temp dir and create
    # at 1 file in each dir: blorf.txt
    #
    # @return [String] - the temp dir path
    #
    def make_faux_app_dirs
      faux_app_dir = Dir.mktmpdir('faux-app-dir')

      app_dirs = %w(app bin config db features lib log node_modules public script spec tmp vendor .yardoc)
      app_dirs.each do |app_dir|
        subdir = File.join(faux_app_dir, app_dir)
        Dir.mkdir(subdir)
        File.open(File.join(subdir, 'blorf.txt'), 'w') do |f|
          f.puts 'blorf!'
        end
      end

      # Create some .yml files in /config
      File.open(File.join(faux_app_dir, 'config', 'secrets.yml'), 'w') do |f|
        f.puts 'not a secret'
      end
      File.open(File.join(faux_app_dir, 'config', 'db.yml'), 'w') do |f|
        f.puts 'not a secret'
      end
      File.open(File.join(faux_app_dir, '.env'), 'w') do |f|
        f.puts 'all your env belong to us'
      end

      faux_app_dir
    end


    # Run the Backup with the given backup_condition
    def run_backup_condition(backup_condition)
      class_name = backup_condition.class_name
      klass = class_name.constantize

      ActivityLogger.open(@logfilename, 'SHF_TASK', 'Conditions') do |log|
        klass.condition_response(backup_condition, log)
      end
    end


    # @return [Boolean] - true if a timestamped file exists matching file_basename
    #    with granularity down to only to the minute
    def timestamped_file_exists?(dir, matching_to_hour_name)
      files_in_dir = Dir.children(dir)
      files_in_dir.any? { |fname| fname =~ /#{matching_to_hour_name}\d\d-\d\d\d\d\d-Z\.gz/ }
    end


    def hourstamp
      Time.now.strftime '%F-%H'
    end


    def timestamped_file_in_dir(dir, matching_to_hour_name)
      files_in_dir = Dir.children(dir)
      files_in_dir.detect { |fname| fname =~ /#{matching_to_hour_name}\d\d-\d\d\d\d\d-Z\.gz/ }
    end


    before(:each) do
      @faux_app_dir = make_faux_app_dirs

      # set up files to be backed up: make 2 notes files:
      @notes_filenames = []
      2.times do |i|
        @notes_filenames[i] = File.join(@faux_app_dir, "notes-#{i}.txt")
        File.open(@notes_filenames[i], 'w') do |f|
          f.puts "notes #{i}"
        end
      end
      @notes_sources = [@notes_filenames]

      # create a faux code directory to be backed up
      @code_dir = Dir.mktmpdir('faux-code')
      @code_filenames = []
      3.times do |i|
        @code_filenames[i] = "faux_code#{i}.rb"
        File.open(File.join(@code_dir, @code_filenames[i]), 'w') do |f|
          f.puts "class FauxCode-#{i};  end"
        end
      end
      @code_sources = [@code_dir]

      # db to be backed up
      @db_to_backup = 'shf_project_test'
      @db_sources = [@db_to_backup]
      allow_any_instance_of(ShfBackupMakers::DBBackupMaker).to receive(:default_sources)
                                                                   .and_return(@db_sources)

      allow_any_instance_of(ShfBackupMakers::FileSetBackupMaker).to receive(:default_sources)
                                                                        .and_return(@notes_sources)
      # destination for the backup files
      @backup_dir = Dir.mktmpdir('backup-dir')
    end


    let(:backup_condition_all_dirs) do
      condition_info = { class_name: 'Backup',
                         timing: :every_day,
                         config: { days_to_keep: { db_backup: 5 },
                                   backup_directory: @backup_dir,

                                   filesets: [
                                       { name: 'logs',
                                         days_to_keep: 8,
                                         files: [File.join(@faux_app_dir, 'log')]
                                       },
                                       { name: 'code',
                                         days_to_keep: 3,
                                         files: [@faux_app_dir],
                                         excludes: ['public', 'docs', 'features', 'spec', 'tmp', '.yardoc'].map { |ex_dir| File.join(@faux_app_dir, ex_dir) }
                                       },
                                       { name: 'app-public',
                                         days_to_keep: 3,
                                         files: [File.join(@faux_app_dir, 'public')]
                                       },
                                       { name: 'config env secrets',
                                         days_to_keep: 32,
                                         files: [File.join(@faux_app_dir, 'config', '*.yml'),
                                                 File.join(@faux_app_dir, '.env')]
                                       }
                                   ]
                         } }

      Condition.new(condition_info)
    end


    let(:backup_condition) do
      condition_info = { class_name: 'Backup',
                         timing: :every_day,
                         config: { days_to_keep: { db_backup: 5 },
                                   backup_directory: @backup_dir,
                                   filesets: [
                                       { name: 'misc files',
                                         days_to_keep: 99,
                                         files: @notes_sources
                                       },
                                       { name: 'faux code',
                                         days_to_keep: 3,
                                         files: [@code_dir]
                                       }
                                   ] } }

      Condition.new(condition_info)
    end

    # match timestamped filenames just down to the hour
    let(:fn_timestamp) { Time.now.strftime '%F-%H' }
    let(:today_timestamp) { Time.now.strftime '%F' }

    let(:expected_aws_bucketname) { "production_backup/#{today_timestamp}/" }

    let(:db_backup_basefn) { 'db_backup.sql' }
    let(:fileset_misc_files_backup_basefn) { 'misc_files.tar' }
    let(:fileset_code_backup_basefn) { 'faux_code.tar' }

    # expected filenames
    let(:expected_db_backup_base_fn) { File.join(@backup_dir, db_backup_basefn) }
    let(:expected_db_backup_fname) { /#{File.join(@backup_dir, db_backup_basefn)}\.#{fn_timestamp}\d\d-\d\d\d\d\d-Z\.gz/ }
    let(:expected_fset_misc_files_base_fname) { File.join(@backup_dir, fileset_misc_files_backup_basefn) }
    let(:expected_fset_misc_files_backup_fname) { /#{File.join(@backup_dir, fileset_misc_files_backup_basefn)}\.#{fn_timestamp}\d\d-\d\d\d\d\d-Z\.gz/ }
    let(:expected_fset_code_backup_base_fname) { File.join(@backup_dir, fileset_code_backup_basefn) }
    let(:expected_fset_code_backup_fname) { /#{File.join(@backup_dir, fileset_code_backup_basefn)}\.#{fn_timestamp}\d\d-\d\d\d\d\d-Z\.gz/ }


    # --------------------------------------------------------------------------


    it 'does the backup - everything works (HAPPY PATH)' do
      expect(described_class).to receive(:upload_file_to_s3)
                                     .with(anything, anything,
                                           expected_aws_bucketname, expected_db_backup_fname)
      expect(described_class).to receive(:upload_file_to_s3)
                                     .with(anything, anything,
                                           expected_aws_bucketname, expected_fset_misc_files_backup_fname)
      expect(described_class).to receive(:upload_file_to_s3)
                                     .with(anything, anything,
                                           expected_aws_bucketname, expected_fset_code_backup_fname)

      expect(described_class).to receive(:delete_excess_backup_files)
                                     .with("#{expected_db_backup_base_fn}.*", 5)
      expect(described_class).to receive(:delete_excess_backup_files)
                                     .with("#{expected_fset_misc_files_base_fname}.*", 99)
      expect(described_class).to receive(:delete_excess_backup_files)
                                     .with("#{expected_fset_code_backup_base_fname}.*", 3)

      # Run the backup
      timestamp = hourstamp
      run_backup_condition(backup_condition)


      # no errors in the log file
      logfile_contents = File.read(@logfilename)
      expect(logfile_contents).not_to match(/error/),
                                      "expected Logfile not to include 'error' but it does:\n#{logfile_contents}"

      # expect the backup files to be in the backup directory
      expect(timestamped_file_exists?(@backup_dir,
                                      "#{db_backup_basefn}.#{timestamp}")).to be_truthy
      expect(timestamped_file_exists?(@backup_dir,
                                      "#{fileset_misc_files_backup_basefn}.#{timestamp}")).to be_truthy
      expect(timestamped_file_exists?(@backup_dir,
                                      "#{fileset_code_backup_basefn}.#{timestamp}")).to be_truthy
    end


    it 'works with no Slack Notification' do

      expect(described_class).to receive(:upload_file_to_s3)
                                     .with(anything, anything,
                                           expected_aws_bucketname, expected_db_backup_fname)
      expect(described_class).to receive(:upload_file_to_s3)
                                     .with(anything, anything,
                                           expected_aws_bucketname, expected_fset_misc_files_backup_fname)
      expect(described_class).to receive(:upload_file_to_s3)
                                     .with(anything, anything,
                                           expected_aws_bucketname, expected_fset_code_backup_fname)

      expect(described_class).to receive(:delete_excess_backup_files)
                                     .with("#{expected_db_backup_base_fn}.*", 5)
      expect(described_class).to receive(:delete_excess_backup_files)
                                     .with("#{expected_fset_misc_files_base_fname}.*", 99)
      expect(described_class).to receive(:delete_excess_backup_files)
                                     .with("#{expected_fset_code_backup_base_fname}.*", 3)

      expect(SHFNotifySlack).not_to receive(:new)
      expect(SHFNotifySlack).not_to receive(:notification)

      # Run the backup
      timestamp = hourstamp
      run_backup_condition(backup_condition)


      # no errors in the log file
      logfile_contents = File.read(@logfilename)
      expect(logfile_contents).not_to match(/error/),
                                      "expected Logfile not to include 'error' but it does:\n#{logfile_contents}"

      # expect the backup files to be in the backup directory
      expect(timestamped_file_exists?(@backup_dir,
                                      "#{db_backup_basefn}.#{timestamp}")).to be_truthy
      expect(timestamped_file_exists?(@backup_dir,
                                      "#{fileset_misc_files_backup_basefn}.#{timestamp}")).to be_truthy
      expect(timestamped_file_exists?(@backup_dir,
                                      "#{fileset_code_backup_basefn}.#{timestamp}")).to be_truthy
    end


    it 'backup with realistic fileset dirs and exclusions' do
      logs_basefn = 'logs.tar'
      expected_logs_basefn = File.join(@backup_dir, logs_basefn)

      code_basefn = 'code.tar'
      expected_code_basefn = File.join(@backup_dir, code_basefn)

      public_basefn = 'app-public.tar'
      expected_public_basefn = File.join(@backup_dir, public_basefn)

      config_basefn = 'config_env_secrets.tar'
      expected_config_basefn = File.join(@backup_dir, config_basefn)


      allow(described_class).to receive(:upload_file_to_s3)

      expect(described_class).to receive(:delete_excess_backup_files)
                                     .with("#{expected_logs_basefn}.*", 8)
      expect(described_class).to receive(:delete_excess_backup_files)
                                     .with("#{expected_code_basefn}.*", 3)
      expect(described_class).to receive(:delete_excess_backup_files)
                                     .with("#{expected_public_basefn}.*", 3)
      expect(described_class).to receive(:delete_excess_backup_files)
                                     .with("#{expected_config_basefn}.*", 32)
      expect(described_class).to receive(:delete_excess_backup_files)
                                     .with("#{expected_db_backup_base_fn}.*", 5)

      # Run the backup
      timestamp = hourstamp
      run_backup_condition(backup_condition_all_dirs)


      # no errors in the log file
      logfile_contents = File.read(@logfilename)
      expect(logfile_contents).not_to match(/error/),
                                      "expected Logfile not to include 'error' but it does:\n#{logfile_contents}"

      # Expect the db backup file to be in the backup directory
      # (It's the only backup file that is _not_ a FileSet.)
      db_backup_ts_fn = "#{db_backup_basefn}.#{timestamp}"
      expect(timestamped_file_exists?(@backup_dir, db_backup_ts_fn)).to be_truthy


      # Expect the FileSet backup files to exist
      # and to have exactly what we specified in the configuration:

      logs_backup_ts_fn = "#{logs_basefn}.#{timestamp}"
      actual_log_backup_file = timestamped_file_in_dir(@backup_dir, logs_backup_ts_fn)
      expected_entries = [File.join(@faux_app_dir, 'log'), File.join(@faux_app_dir, 'log', 'blorf.txt')]
      expect_tar_has_these_entries(File.join(@backup_dir, actual_log_backup_file), expected_entries)

      code_backup_ts_fn = "#{code_basefn}.#{timestamp}"
      expected_dirs = %w(app bin config db lib log node_modules  script vendor )
      actual_code_env_secrets_backup_file = timestamped_file_in_dir(@backup_dir, code_backup_ts_fn)

      expected_entries = expected_dirs.map do |dir|
        [File.join(@faux_app_dir, dir), File.join(@faux_app_dir, dir, 'blorf.txt')]
      end

      expected_entries << @faux_app_dir
      expected_entries << File.join(@faux_app_dir, 'config', 'secrets.yml')
      expected_entries << File.join(@faux_app_dir, 'config', 'db.yml')
      expected_entries << File.join(@faux_app_dir, '.env')
      expected_entries << File.join(@faux_app_dir, 'notes-0.txt')
      expected_entries << File.join(@faux_app_dir, 'notes-1.txt')
      expect_tar_has_these_entries(File.join(@backup_dir, actual_code_env_secrets_backup_file), expected_entries.flatten)

      public_backup_ts_fn = "#{public_basefn}.#{timestamp}"
      actual_app_public_backup_file = timestamped_file_in_dir(@backup_dir, public_backup_ts_fn)
      expected_entries = [File.join(@faux_app_dir, 'public'), File.join(@faux_app_dir, 'public', 'blorf.txt')]
      expect_tar_has_these_entries(File.join(@backup_dir, actual_app_public_backup_file), expected_entries)

      config_backup_ts_fn = "#{config_basefn}.#{timestamp}"
      actual_config_env_secrets_backup_file = timestamped_file_in_dir(@backup_dir, config_backup_ts_fn)
      config_dir = File.join(@faux_app_dir, 'config')
      expected_entries = [File.join(config_dir, 'db.yml'), File.join(config_dir, 'secrets.yml'), File.join(@faux_app_dir, '.env')]
      expect_tar_has_these_entries(File.join(@backup_dir, actual_config_env_secrets_backup_file), expected_entries)
    end


    describe 'Errors: logged, Slack notification sent, does not stop entire backup' do

      it 'DBBackupMaker fails, no db backup is created' do

        allow(described_class).to receive(:upload_file_to_s3)
        allow(described_class).to receive(:delete_excess_backup_files)

        # Raise an error:
        expected_error_text = /No such file or directory - blorfo while in the backup_makers.each loop. Current item:/
        allow_any_instance_of(ShfBackupMakers::DBBackupMaker).to receive(:shell_cmd)
                                                                     .with(/touch/)
                                                                     .and_raise(Errno::ENOENT, 'blorfo')
        # Slack notification should be sent
        expect(SHFNotifySlack).to receive(:failure_notification)
                                      .with('Backup', text: expected_error_text)

        # Run the backup
        timestamp = hourstamp
        run_backup_condition(backup_condition)

        # There will be errors in the log file
        expect(File.read(@logfilename)).to match(expected_error_text)

        # expect only the successful backup files to be in the backup directory
        expect(timestamped_file_exists?(@backup_dir,
                                        "#{fileset_misc_files_backup_basefn}.#{timestamp}")).to be_truthy
        expect(timestamped_file_exists?(@backup_dir,
                                        "#{fileset_code_backup_basefn}.#{timestamp}")).to be_truthy
        # no db backup was created:
        expect(timestamped_file_exists?(@backup_dir,
                                        "#{db_backup_basefn}.#{timestamp}")).to be_falsey
      end


      it 'writing to AWS fails for the FileSet code backup file' do
        expect(described_class).to receive(:upload_file_to_s3)
                                       .with(anything, anything,
                                             expected_aws_bucketname, expected_db_backup_fname)
        expect(described_class).to receive(:upload_file_to_s3)
                                       .with(anything, anything,
                                             expected_aws_bucketname, expected_fset_misc_files_backup_fname)
        allow(described_class).to receive(:delete_excess_backup_files)

        # Raise an error:
        @error_raised = NoMethodError.new('flurb')
        expected_error_text = /#{@error_raised} in backup_files loop, uploading_file_to_s3. Current item:/

        allow(described_class).to receive(:upload_file_to_s3)
                                      .with(anything, anything,
                                            expected_aws_bucketname, expected_fset_code_backup_fname)
                                      .and_raise(@error_raised)

        # Slack notification should be sent
        expect(SHFNotifySlack).to receive(:failure_notification).with(anything, text: expected_error_text)


        # Run the backup
        timestamp = hourstamp
        run_backup_condition(backup_condition)


        # There will be errors in the log file
        expect(File.read(@logfilename)).to match(expected_error_text)

        # expect the backup files to be in the backup directory
        expect(timestamped_file_exists?(@backup_dir,
                                        "#{fileset_misc_files_backup_basefn}.#{timestamp}")).to be_truthy
        expect(timestamped_file_exists?(@backup_dir,
                                        "#{fileset_code_backup_basefn}.#{timestamp}")).to be_truthy
        expect(timestamped_file_exists?(@backup_dir,
                                        "#{db_backup_basefn}.#{timestamp}")).to be_truthy
      end


      it 'pruning the backup files fails' do
        allow(described_class).to receive(:validate_timing)
        allow_any_instance_of(ShfBackupMakers::AbstractBackupMaker).to receive(:backup).and_call_original

        allow(described_class).to receive(:upload_file_to_s3)

        expect(described_class).to receive(:delete_excess_backup_files)
                                       .with("#{File.join(@backup_dir, db_backup_basefn)}.*", anything)
        expect(described_class).to receive(:delete_excess_backup_files)
                                       .with("#{expected_fset_code_backup_base_fname}.*", 3)

        # Raise an error:
        @error_raised = NoMethodError
        expected_error_text = /#{@error_raised} while pruning in the backup_makers.each loop. Current item:/

        expect(described_class).to receive(:delete_excess_backup_files)
                                       .with("#{expected_fset_misc_files_base_fname}.*", 99)
                                       .and_raise(NoMethodError)

        # Slack notification should be sent
        expect(SHFNotifySlack).to receive(:failure_notification).with(anything, text: expected_error_text)

        # Run the backup
        timestamp = hourstamp
        run_backup_condition(backup_condition)

        # The error was recorded in the log
        expect(File.read(@logfilename)).to match(expected_error_text)

        # expect the backup files to be in the backup directory
        expect(timestamped_file_exists?(@backup_dir,
                                        "#{fileset_misc_files_backup_basefn}.#{timestamp}")).to be_truthy
        expect(timestamped_file_exists?(@backup_dir,
                                        "#{fileset_code_backup_basefn}.#{timestamp}")).to be_truthy
        expect(timestamped_file_exists?(@backup_dir,
                                        "#{db_backup_basefn}.#{timestamp}")).to be_truthy
      end
    end


    describe 'Slack notification error' do

      let(:slack_error) { Slack::Notifier::APIError.new }
      let(:start_of_error_text) { 'Slack Notification failure during Backup\.condition_response' }


      describe 'use_slack_notification is false; backup is not halted due to a Slack error' do

        it 'not within a loop' do
          allow(described_class).to receive(:validate_timing)
          allow_any_instance_of(ShfBackupMakers::AbstractBackupMaker).to receive(:backup)
          allow(described_class).to receive(:upload_file_to_s3)
          allow(described_class).to receive(:delete_excess_backup_files)

          # Raise a Slack notification error
          allow(described_class).to receive(:backup_dir).and_raise(slack_error)
          expect(SHFNotifySlack).not_to receive(:notification)


          class_name = backup_condition.class_name
          klass = class_name.constantize
          ActivityLogger.open(@logfilename, 'SHF_TASK', 'Conditions') do |log|
            expect { klass.condition_response(backup_condition, log, use_slack_notification: false) }.to raise_error(slack_error)
          end
        end

      end


      describe 'use_slack_notification is true; backup IS halted if we cannot send a Slack notification for an error' do

        it 'not within a loop' do
          allow(described_class).to receive(:validate_timing)
          allow_any_instance_of(ShfBackupMakers::AbstractBackupMaker).to receive(:backup)
          allow(described_class).to receive(:upload_file_to_s3)
          allow(described_class).to receive(:delete_excess_backup_files)

          # Raise a Slack notification error
          allow(described_class).to receive(:backup_dir).and_raise(slack_error)


          class_name = backup_condition.class_name
          klass = class_name.constantize
          ActivityLogger.open(@logfilename, 'SHF_TASK', 'Conditions') do |log|
            expect { klass.condition_response(backup_condition, log) }.to raise_error(slack_error)
          end
        end


        it 'in backup_makers .backup loop' do
          allow(described_class).to receive(:validate_timing)
          allow_any_instance_of(ShfBackupMakers::FileSetBackupMaker).to receive(:backup)
          allow(described_class).to receive(:upload_file_to_s3)
          allow(described_class).to receive(:delete_excess_backup_files)


          # Raise a Slack notification error
          allow_any_instance_of(ShfBackupMakers::DBBackupMaker).to receive(:backup).and_raise(slack_error)

          class_name = backup_condition.class_name
          klass = class_name.constantize
          ActivityLogger.open(@logfilename, 'SHF_TASK', 'Conditions') do |log|
            expect { klass.condition_response(backup_condition, log) }.to raise_error(slack_error)
          end
        end


        it 'in AWS loop' do
          allow(described_class).to receive(:validate_timing)
          allow_any_instance_of(ShfBackupMakers::AbstractBackupMaker).to receive(:backup)
          allow(described_class).to receive(:delete_excess_backup_files)

          # Raise a Slack notification error
          allow(described_class).to receive(:upload_file_to_s3).and_raise(slack_error)


          class_name = backup_condition.class_name
          klass = class_name.constantize
          ActivityLogger.open(@logfilename, 'SHF_TASK', 'Conditions') do |log|
            expect { klass.condition_response(backup_condition, log) }.to raise_error(slack_error)
          end
        end


        it 'in pruning backups loop' do
          allow(described_class).to receive(:validate_timing)
          allow_any_instance_of(ShfBackupMakers::AbstractBackupMaker).to receive(:backup)
          allow(described_class).to receive(:upload_file_to_s3)


          # Raise a Slack notification error
          allow(described_class).to receive(:delete_excess_backup_files).and_raise(slack_error)

          class_name = backup_condition.class_name
          klass = class_name.constantize
          ActivityLogger.open(@logfilename, 'SHF_TASK', 'Conditions') do |log|
            expect { klass.condition_response(backup_condition, log) }.to raise_error(slack_error)
          end
        end

      end

    end

  end

  # =======================================================================


  describe 'Unit tests' do


    let(:condition) { build(:condition, timing: Backup::TIMING_EVERY_DAY) }
    let(:today) { Time.now.strftime '%Y-%m-%d' }


    let(:today_timestamp) { Backup.today_timestamp }
    let(:expected_bucket) { ENV['SHF_AWS_S3_BACKUP_BUCKET'] }
    let(:expected_bucket_folder) { "production_backup/#{today_timestamp}/" }


    def create_faux_backup_file(backups_dir, file_prefix)
      File.open(File.join(backups_dir, "#{file_prefix}-faux-backup.bak"), 'w').path
    end


    describe '.backup_dir' do

      it 'uses the backup_directory in the config' do
        backup = build(:condition, :every_day, config: { backup_directory: 'blorf-dir' })
        expect(described_class.backup_dir(backup.config)).to eq 'blorf-dir'
      end

      it 'if the dir in the config is not found, uses /home/deploy/SHF_BACKUPS/' do
        backup = build(:condition, :every_day)
        expect(described_class.backup_dir(backup.config)).to eq '/home/deploy/SHF_BACKUPS/'
      end

    end


    describe '.backup_target_fn' do

      it 'joins the given directory with the given filename, appends "." + a timestamp and .gz to the base filename' do
        timestamp = Time.now.strftime Backup::TIMESTAMP_FMT
        time_to_mins_str = Time.now.strftime '%F-%H%M' # we can only check it to the minute
        expect(described_class.backup_target_fn('blorf-dir', 'blorf')).to match(/blorf-dir\/blorf\.#{time_to_mins_str}-\d\d\d\d\d-Z\.gz/)
      end

    end


    describe '.get_s3_objects' do

      it 'requires ENV variables for the AWS credentials and region' do
        expect(ENV.fetch('SHF_AWS_S3_BACKUP_BUCKET', nil)).not_to be_nil
        expect(ENV.fetch('SHF_AWS_S3_BACKUP_REGION', nil)).not_to be_nil
        expect(ENV.fetch('SHF_AWS_S3_BACKUP_KEY_ID', nil)).not_to be_nil
        expect(ENV.fetch('SHF_AWS_S3_BACKUP_SECRET_ACCESS_KEY', nil)).not_to be_nil
      end

      it 'uses the argument as part of the bucket folder name' do
        result = Backup.get_s3_objects('blorfo')
        expect(result[2]).to eq "production_backup/blorfo/"
      end

      it 'uses Bucket.today_timestamp is no argument is given' do
        result = Backup.get_s3_objects
        expect(result[1]).to eq expected_bucket
        expect(result[2]).to eq expected_bucket_folder
      end

      it 'returns array of [AWS S3 credentials, bucket, bucket_folder' do
        result = Backup.get_s3_objects(today_timestamp)
        expect(result[1]).to eq expected_bucket
        expect(result[2]).to eq expected_bucket_folder
      end

    end


    it '.upload_file_to_s3 calls .upload_file for the bucket, folder, and file to upload' do

      temp_backups_dir = Dir.mktmpdir('faux-backups-dir')
      faux_backup_fn = create_faux_backup_file(temp_backups_dir, 'faux_backup.bak')

      expect_any_instance_of(Aws::S3::Object).to receive(:upload_file).with(faux_backup_fn).and_return(true)

      aws_s3_resource, bucket, bucket_folder = Backup.get_s3_objects(today_timestamp)

      Backup.upload_file_to_s3(aws_s3_resource, bucket, bucket_folder, faux_backup_fn)

      FileUtils.remove_entry(temp_backups_dir, true)
    end


    it '.delete_excess_backup_files sorts based on filename, deleting those that come first' do

      # create some faux backup files
      temp_backups_dir = Dir.mktmpdir('faux-backups-dir')
      backup_a0 = create_faux_backup_file(temp_backups_dir, 'a0')
      backup_a1 = create_faux_backup_file(temp_backups_dir, 'a1')
      backup_a2 = create_faux_backup_file(temp_backups_dir, 'a2')
      backup_a3 = create_faux_backup_file(temp_backups_dir, 'a3')

      expect(File.exist?(backup_a0)).to be_truthy
      expect(File.exist?(backup_a1)).to be_truthy
      expect(File.exist?(backup_a2)).to be_truthy
      expect(File.exist?(backup_a3)).to be_truthy

      Backup.delete_excess_backup_files("#{temp_backups_dir}/*.bak", 2)

      expect(File.exist?(backup_a0)).to be_falsey
      expect(File.exist?(backup_a1)).to be_falsey
      expect(File.exist?(backup_a2)).to be_truthy
      expect(File.exist?(backup_a3)).to be_truthy

      FileUtils.remove_entry(temp_backups_dir, true)
    end


    describe '.condition_response' do

      class FakeLogger
        def self.record(*args)
        end


        def self.error(*args)
        end
      end

      let(:backup_config) { { class_name: 'Backup',
                              timing: Backup::TIMING_EVERY_DAY,
                              days_to_keep: { code_backup: 4,
                                              db_backup: 15 },
                              backup_directory: nil,
                              filesets: [
                                  { name: 'files',
                                    files: ['file1.txt', '/some/dir']
                                  },
                              ]
      } }

      let(:backup_condition) { build(:condition, config: backup_config, timing: Backup::TIMING_EVERY_DAY) }


      before(:each) do
        @db_backup_maker1 = ShfBackupMakers::DBBackupMaker.new(target_filename: 'db_backup_maker_target_file.sql')
        @db_backup_maker2 = ShfBackupMakers::DBBackupMaker.new(target_filename: 'another_db_backup_maker_target_file.flurb')
        @files_backup_maker = ShfBackupMakers::FileSetBackupMaker.new(name: 'files',
                                                                      target_filename: 'files.tar',
                                                                      backup_sources: ['file1.txt', 'file2.zip'])
        @created_backup_makers = [
            { backup_maker: @db_backup_maker1, keep_num: 2 },
            { backup_maker: @db_backup_maker2, keep_num: 1 },
            { backup_maker: @files_backup_maker, keep_num: 99 }
        ]

        # Individual tests below might change or set an expectation
        allow_any_instance_of(ShfBackupMakers::AbstractBackupMaker).to receive(:shell_cmd)

        allow(described_class).to receive(:backup_dir)
                                      .and_return('BACKUP_DIR')
        allow(described_class).to receive(:create_backup_makers)
                                      .and_return(@created_backup_makers)

        allow(described_class).to receive(:get_s3_objects)
        allow(described_class).to receive(:upload_file_to_s3)
        allow(described_class).to receive(:get_backup_files_pattern).and_call_original
        allow(described_class).to receive(:delete_excess_backup_files)
      end

      let(:expected_num_makers) { @created_backup_makers.size }


      describe '.validate_timing errors are logged and notification sent' do

        valid_timing_list = [:every_day]
        expected_list = valid_timing_list.is_a?(Enumerable) ? valid_timing_list : [valid_timing_list]

        unexpected_timings = ConditionResponder.all_timings - expected_list

        unexpected_timings.each do |unexpected_timing|

          it "logs and notififies that #{unexpected_timing} is not a valid timing but does not raise the error" do

            backup_condition.timing = unexpected_timing
            err_str = "Received timing :#{unexpected_timing} which is not in list of expected timings: #{expected_list}"

            expect(described_class).to receive(:validate_timing).and_call_original

            # will log twice: once by ConditionResponder class, once by the Backup class. not ideal
            expect(FakeLogger).to receive(:error).with(err_str)

            expect(SHFNotifySlack).to receive(:failure_notification)
                                          .with(described_class.name, text: err_str)

            orig_on_false_positives_setting = RSpec::Expectations.configuration.on_potential_false_positives
            RSpec::Expectations.configuration.on_potential_false_positives = :nothing

            expect { described_class.condition_response(backup_condition, FakeLogger) }
                .not_to raise_exception TimingNotValidError, err_str

            RSpec::Expectations.configuration.on_potential_false_positives = orig_on_false_positives_setting
          end
        end
      end


      it 'gets the backup_dir from the configuration' do
        expect(described_class).to receive(:backup_dir).with(backup_config).and_call_original
        described_class.condition_response(backup_condition, FakeLogger)
      end

      it 'creates backup makers given a configuration' do
        expect(described_class).to receive(:create_backup_makers)
                                       .with(backup_config).and_call_original
        described_class.condition_response(backup_condition, FakeLogger)
      end

      describe 'with each backup maker, it:' do

        it 'creates the target backup filename based on the "base_name" of the backup maker' do
          expect(described_class).to receive(:backup_target_fn)
                                         .with('BACKUP_DIR', 'db_backup.sql')
          expect(described_class).to receive(:backup_target_fn)
                                         .with('BACKUP_DIR', 'db_backup.sql')
          expect(described_class).to receive(:backup_target_fn)
                                         .with('BACKUP_DIR', 'files.tar')

          described_class.condition_response(backup_condition, FakeLogger)
        end

        it "logs a message that it is 'Backing up to: <the backup file>.<YYYY-mm-dd-HHMM-SSLLL-Z>.gz'" do
          allow(FakeLogger).to receive(:record).with('info', /Moving (.*)/)
          allow(FakeLogger).to receive(:record).with('info', /Pruning (.*)/)

          time_to_mins_str = Time.now.strftime '%F-%H%M'

          # we created 2 DB backup makers
          expect(FakeLogger).to receive(:record).twice
                                    .with('info', /Backing up to: BACKUP_DIR\/db_backup\.sql\.#{time_to_mins_str}-(.*)-Z\.gz/)
          expect(FakeLogger).to receive(:record)
                                    .with('info', /Backing up to: BACKUP_DIR\/files\.tar\.#{time_to_mins_str}-(.*)-Z\.gz/)

          described_class.condition_response(backup_condition, FakeLogger)
        end

        it 'sends the backup method to each backup maker, which returns the name of the backup file created' do
          expect(@db_backup_maker1).to receive(:backup)
          expect(@db_backup_maker2).to receive(:backup)
          expect(@files_backup_maker).to receive(:backup)

          described_class.condition_response(backup_condition, FakeLogger)

        end
      end

      it "logs a message that it is 'Moving backup files to AWS S3'" do
        allow(FakeLogger).to receive(:record).with('info', /Backing up to: (.*)/)
        allow(FakeLogger).to receive(:record).with('info', /Pruning (.*)/)

        expect(FakeLogger).to receive(:record).with('info', /Moving (.*)/)
        described_class.condition_response(backup_condition, FakeLogger)
      end

      it 'calls S3 credentials once' do
        expect(described_class).to receive(:get_s3_objects)
                                       .with(today).exactly(1).times

        described_class.condition_response(condition, FakeLogger)
      end

      it 'calls upload to S3 once for each Backup maker ' do
        # if no files are in the config, there are only 2 backup makers
        expect(described_class).to receive(:upload_file_to_s3).exactly(expected_num_makers).times

        described_class.condition_response(condition, FakeLogger)
      end


      describe 'finally it prunes older backups on local storage' do

        it "logs a message that it is 'Pruning older backups on local storage'" do
          allow(FakeLogger).to receive(:record).with('info', /Backing up to: (.*)/)
          allow(FakeLogger).to receive(:record).with('info', /Moving (.*)/)

          expect(FakeLogger).to receive(:record).with('info', /Pruning (.*)/)
          described_class.condition_response(backup_condition, FakeLogger)
        end


        describe 'for each backup_maker it:' do

          it 'gets the file pattern to use to prune older backup files, based on the base_file from the backup_maker' do
            expect(described_class).to receive(:get_backup_files_pattern)
                                           .with('BACKUP_DIR', 'db_backup.sql')
            expect(described_class).to receive(:get_backup_files_pattern)
                                           .with('BACKUP_DIR', 'db_backup.sql')
            expect(described_class).to receive(:get_backup_files_pattern)
                                           .with('BACKUP_DIR', 'files.tar')

            described_class.condition_response(backup_condition, FakeLogger)
          end

          it 'deletes excess backup files that were created by this backup_maker, keeping the number given in the configuration' do
            expect(described_class).to receive(:delete_excess_backup_files)
                                           .with('BACKUP_DIR/db_backup.sql.*', 2)
            expect(described_class).to receive(:delete_excess_backup_files)
                                           .with('BACKUP_DIR/db_backup.sql.*', 1)
            expect(described_class).to receive(:delete_excess_backup_files)
                                           .with('BACKUP_DIR/files.tar.*', 99)

            described_class.condition_response(backup_condition, FakeLogger)
          end

        end

      end

    end


    describe '.create_backup_makers' do

      describe 'number of database backups to keep' do

        it 'ShfBackupMakers::DBBackupMaker number to keep is from config if days_to_keep: {db_backup: N} exists' do
          makers = described_class.create_backup_makers({ days_to_keep: { db_backup: 12 } })
          db_backupmaker = makers.find { |maker_entry| maker_entry[:backup_maker].is_a? ShfBackupMakers::DBBackupMaker }
          expect(db_backupmaker[:keep_num]).to eq 12
        end

        it 'ShfBackupMakers::DBBackupMaker number to keep is 15 (default) if not in config' do
          makers = described_class.create_backup_makers({})
          db_backupmaker = makers.find { |maker_entry| maker_entry[:backup_maker].is_a? ShfBackupMakers::DBBackupMaker }
          expect(db_backupmaker[:keep_num]).to eq 15
        end
      end


      describe 'only adds a FileSetBackupMaker if needed' do

        it 'no FileSetBackupMaker created after reading the config' do
          allow(described_class).to receive(:create_fileset_backup_makers).and_return([])

          makers = described_class.create_backup_makers({ files: ['thisfile'], days_to_keep: { files_backup: 12 } })
          files_backupmaker = makers.select { |maker_entry| maker_entry[:backup_maker].class.name == 'ShfBackupMakers::FileSetBackupMaker' }

          expect(files_backupmaker).to be_empty
        end
      end

    end


    describe '.create_fileset_backup_makers' do

      it 'empty if there is no filesets: entry in config' do
        expect(described_class.create_fileset_backup_makers({})).to be_empty
      end

      it 'raises ShfConditionError::BackupConfigFileSetBadFormatError if not an array' do
        expect { described_class.create_fileset_backup_makers({ filesets: 'blorf' }) }.to raise_exception(ShfConditionError::BackupConfigFileSetBadFormatError)
      end

      it 'an empty list if the list is empty: []' do
        expect(described_class.create_fileset_backup_makers({ filesets: [] })).to be_empty
      end

      it 'creates a list of FileSetBackupMakers' do
        config = {
            filesets: [
                {
                    name: 'set 1',
                    files: ['hund.rb', 'hammerhead.rb', 'hamster.rb']
                },
                {
                    name: 'set 2',
                    files: ['hund.rb', 'hammerhead.rb', 'hamster.rb']
                }
            ]

        }

        expect(described_class).to receive(:new_fileset_backup_maker)
                                       .with({ name: 'set 1',
                                               files: ['hund.rb', 'hammerhead.rb', 'hamster.rb']
                                             })
                                       .and_call_original
        expect(described_class).to receive(:new_fileset_backup_maker)
                                       .with({ name: 'set 2',
                                               files: ['hund.rb', 'hammerhead.rb', 'hamster.rb']
                                             })
                                       .and_call_original
        created_makers = described_class.create_fileset_backup_makers(config)
        expect(created_makers.size).to eq 2
      end

    end


    describe 'new_fileset_backup_maker' do

      it 'minimum information is name and a list of backup sources' do
        fileset_config = {
            name: 'files starting with H',
            files: ['hund.rb', 'hammerhead.rb', 'hamster.rb']
        }

        expected_fsbm = ShfBackupMakers::FileSetBackupMaker.new(name: 'files starting with H',
                                                                backup_sources: ['hund.rb', 'hammerhead.rb', 'hamster.rb'],
                                                                excludes: [])
        expect(described_class.new_fileset_backup_maker(fileset_config)).to eq_the_fileset_backup_maker expected_fsbm
      end

      it 'specifies the base filename' do
        fileset_config = {
            name: 'files starting with H',
            base_filename: 'h-files.gz',
            files: ['hund.rb', 'hammerhead.rb', 'hamster.rb']
        }

        expected_fsbm = ShfBackupMakers::FileSetBackupMaker.new(name: 'files starting with H',
                                                                base_filename: 'h-files.gz',
                                                                backup_sources: ['hund.rb', 'hammerhead.rb', 'hamster.rb'],
                                                                excludes: [],
                                                                target_filename: 'files_starting_with_H.tar')
        expect(described_class.new_fileset_backup_maker(fileset_config)).to eq_the_fileset_backup_maker expected_fsbm
      end

      it 'specifies list of patterns to exclude' do
        fileset_config = {
            name: 'files starting with H',
            base_filename: 'h-files.gz',
            files: ['hund.rb', 'hammerhead.rb', 'hamster.rb'],
            excludes: ['ham*.rb', 'blorf/dir']
        }

        expected_fsbm = ShfBackupMakers::FileSetBackupMaker.new(name: 'files starting with H',
                                                                base_filename: 'h-files.gz',
                                                                backup_sources: ['hund.rb', 'hammerhead.rb', 'hamster.rb'],
                                                                excludes: ['ham*.rb', 'blorf/dir'],
                                                                target_filename: 'files_starting_with_H.tar')
        expect(described_class.new_fileset_backup_maker(fileset_config)).to eq_the_fileset_backup_maker expected_fsbm
      end

      it 'specifies days to keep' do
        fileset_config = {
            name: 'files starting with H',
            base_filename: 'h-files.gz',
            files: ['hund.rb', 'hammerhead.rb', 'hamster.rb'],
            excludes: ['ham*.rb', 'blorf/dir'],
            days_to_keep: 99
        }

        expected_fsbm = ShfBackupMakers::FileSetBackupMaker.new(name: 'files starting with H',
                                                                base_filename: 'h-files.gz',
                                                                backup_sources: ['hund.rb', 'hammerhead.rb', 'hamster.rb'],
                                                                excludes: ['ham*.rb', 'blorf/dir'],
                                                                target_filename: 'files_starting_with_H.tar',
                                                                days_to_keep: 99)
        expect(described_class.new_fileset_backup_maker(fileset_config)).to eq_the_fileset_backup_maker expected_fsbm
      end


      describe 'errors encountered' do

        it 'missing the name raises BackupConfigFileSetMissingNameError' do
          fileset_config = {
              files: ['hund.rb', 'hammerhead.rb', 'hamster.rb']
          }

          expect { described_class.new_fileset_backup_maker(fileset_config) }.to raise_error ShfConditionError::BackupConfigFileSetMissingNameError
        end

        it 'name is blank raises BackupFileSetNameCantBeBlankError' do
          fileset_config = {
              name: '',
              files: ['hund.rb', 'hammerhead.rb', 'hamster.rb']
          }

          expect { described_class.new_fileset_backup_maker(fileset_config) }.to raise_error ShfConditionError::BackupFileSetNameCantBeBlankError
        end

        it 'missing the list of sources raises BackupConfigFileSetMissingSourceFiles' do
          fileset_config = {
              name: 'missing sources'
          }

          expect { described_class.new_fileset_backup_maker(fileset_config) }.to raise_error ShfConditionError::BackupConfigFileSetMissingSourceFiles
        end

        it 'sources is not an Array raises BackupConfigFileSetBadFormatError and the error message specifies the fileset name' do
          fileset_config = {
              name: 'sources not an array',
              files: 'hund.rb'
          }

          expect { described_class.new_fileset_backup_maker(fileset_config) }.to raise_error ShfConditionError::BackupConfigFileSetBadFormatError,
                                                                                             "Backup Condition configuration for fileset 'sources not an array' error. files: must be an Array."
        end

        it 'list of sources is empty raises BackupConfigFileSetEmptySourceFiles' do
          fileset_config = {
              name: 'sources is empty',
              files: []
          }

          expect { described_class.new_fileset_backup_maker(fileset_config) }.to raise_error ShfConditionError::BackupConfigFileSetEmptySourceFiles
        end

        it 'excludes is not an Array raises BackupConfigFileSetBadFormatError' do
          fileset_config = {
              name: 'sources not an array',
              files: ['hund.rb'],
              excludes: 'hammer*.*'
          }

          expect { described_class.new_fileset_backup_maker(fileset_config) }.to raise_error ShfConditionError::BackupConfigFileSetBadFormatError,
                                                                                             "Backup Condition configuration for fileset 'sources not an array' error. excludes: must be an Array."
        end
      end
    end


    describe 'get_backup_files_pattern' do

      it 'appends ".*" to the end of the File.join(backup directory, backup file)' do
        expect(described_class.get_backup_files_pattern('dir', 'filename.zzk')).to eq('dir/filename.zzk.*')
      end

      it 'uses File.join so redundant/repeated slashes are not a problem' do
        expect(described_class.get_backup_files_pattern('dir/with/ending/slash/', 'filename.zzk')).to eq('dir/with/ending/slash/filename.zzk.*')
      end
    end


    describe 'log_and_notify' do

      before(:each) do
        @more_info = 'this is additional info'
        @some_error = NameError.new('blorf')
      end


      describe 'writes the error and additional info to the log' do

        before(:each) do
          allow(SHFNotifySlack).to receive(:failure_notification)
                                       .with(anything, anything)
        end

        it 'the error message followed the additional info is sent to the log' do
          expect(FakeLogger).to receive(:error).with("#{@some_error} #{@more_info}")
          described_class.log_and_notify(@some_error, FakeLogger, @more_info)
        end

        describe 'if it cannot write to the log' do

          before(:each) do
            @logging_error = IOError
            allow(FakeLogger).to receive(:error)
                                     .and_raise(@logging_error)
          end


          it 'logging error not raised and will also send a Slack notification about the logging error' do
            expect(SHFNotifySlack).to receive(:failure_notification)
                                          .with(anything, text: 'original error')

            expect(SHFNotifySlack).to receive(:failure_notification)
                                          .with(anything, text: "Error: Could not write to the log in #{described_class.name}.log_and_notify: #{@logging_error}")

            orig_on_false_positives_setting = RSpec::Expectations.configuration.on_potential_false_positives
            RSpec::Expectations.configuration.on_potential_false_positives = :nothing
            expect { described_class.log_and_notify('original error', FakeLogger, use_slack_notification: true) }.not_to raise_error(@logging_error)
            RSpec::Expectations.configuration.on_potential_false_positives = orig_on_false_positives_setting
          end
        end

      end


      describe 'sends a Slack failure notification' do

        before(:each) do
          allow(FakeLogger).to receive(:error)
        end

        it 'text is the error followed by the additional info' do
          expect(SHFNotifySlack).to receive(:failure_notification)
                                        .with(described_class.name, text: "#{@some_error} #{@more_info}")

          described_class.log_and_notify(@some_error, FakeLogger, @more_info, use_slack_notification: true)
        end

        describe 'if it cannot send a notification' do

          before(:each) do
            @slack_error = Slack::Notifier::APIError.new
            allow(SHFNotifySlack).to receive(:failure_notification)
                                         .and_raise(@slack_error)
          end

          it 'will also write the Slack notification error to the log' do
            expect(FakeLogger).to receive(:error)
                                      .with('original error')
            expect(FakeLogger).to receive(:error)
                                      .with("Slack error during #{described_class.name}.log_and_notify: #{@slack_error.inspect}")

            expect { described_class.log_and_notify('original error', FakeLogger, use_slack_notification: true) }.to raise_error(@slack_error)
          end

          it 'will raise the Slack error so the caller can handle it as needed' do
            expect { described_class.log_and_notify('original error', FakeLogger, use_slack_notification: true) }.to raise_error(@slack_error)
          end
        end
      end
    end


    describe 'iterate_and_log_notify_errors(list, slack_error_details, log)' do

      before(:each) do
        allow(SHFNotifySlack).to receive(:failure_notification)
                                     .with(anything, anything)

        @strings = %w(a b c) # this is the list of items we'll iterate through
        @result_str = ''
      end


      it 'iterates through each item in the list with the yield' do

        described_class.iterate_and_log_notify_errors(@strings, 'error during iteration test', FakeLogger, use_slack_notification: true) do |s|
          @result_str << s
        end

        expect(@result_str).to eq 'abc'
      end


      it 'Slack error is raised so caller can do whatever is needed; iteration stops' do

        # We do not log the Slack error; caller can do that if appropriate
        expect(FakeLogger).not_to receive(:error)

        expect {
          described_class.iterate_and_log_notify_errors(@strings, 'during iteration test', FakeLogger) do |s|
            raise Slack::Notifier::APIError if s == 'b'
            @result_str << s
          end }.to raise_error(Slack::Notifier::APIError)

        expect(@result_str).to eq 'a'
      end


      it 'non-Slack error is logged, notification sent, iteration continues' do

        some_error = NameError

        expected_error_str = "#{some_error} error during iteration test. Current item: \"b\""

        expect(SHFNotifySlack).to receive(:failure_notification).with(anything, text: expected_error_str)
        expect(FakeLogger).to receive(:error).with(expected_error_str)

        described_class.iterate_and_log_notify_errors(@strings, 'error during iteration test', FakeLogger, use_slack_notification: true) do |s|
          raise some_error if s == 'b'
          @result_str << s
        end

        expect(@result_str).to eq 'ac'
      end

    end
  end

end

