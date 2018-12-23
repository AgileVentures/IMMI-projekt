require 'rails_helper'
require 'email_spec/rspec'

require 'shared_context/activity_logger'

RSpec.describe Backup, type: :model do

  include_context 'create logger'

  let(:condition) { build(:condition, timing: Backup::TIMING_EVERY_DAY) }
  let(:today) { Time.now.strftime '%Y-%m-%d' }

  describe '.condition_response' do

    it 'raises exception and writes to log file unless timing is :every_day' do

      condition.timing = :not_every_day

      expect do
        described_class.condition_response(condition, log)
      end.to raise_exception ArgumentError, 'Cannot handle timing other than every_day'

      expect(File.read(filepath))
          .to include 'Cannot handle timing other than every_day'
    end

    context 'Backup code and DB' do

      before(:each) do
        allow(described_class).to receive(:get_s3_objects)
        allow(described_class).to receive(:upload_file_to_s3)
        allow(described_class).to receive(:delete_excess_backup_files)
        allow(described_class).to receive(:backup_code)
        allow(described_class).to receive(:backup_db)
      end

      it 'Creates backup file for code' do
        backup_file = Backup::DEFAULT_BACKUP_FILES_DIR +
                      Backup::CODE_BACKUP_FILEBASE + today + '.gz'

        expect(described_class).to receive(:backup_code)
          .with(backup_file, Backup::CODE_ROOT_DIRECTORY).exactly(1).times

        described_class.condition_response(condition, log)

        expect(File.read(filepath)).to include "Backing up to: #{backup_file}"
      end

      it 'Creates backup file for DB' do
        backup_file = Backup::DEFAULT_BACKUP_FILES_DIR +
                      Backup::DB_BACKUP_FILEBASE + today + '.gz'

        expect(described_class).to receive(:backup_db)
          .with(backup_file, Backup::DB_NAME).exactly(1).times

        described_class.condition_response(condition, log)

        expect(File.read(filepath)).to include "Backing up to: #{backup_file}"
      end

      it 'Derives S3 credentials' do
        expect(described_class).to receive(:get_s3_objects)
          .with(today).exactly(1).times

        described_class.condition_response(condition, log)
      end

      it 'Posts code and DB backup files to S3' do
        expect(described_class).to receive(:upload_file_to_s3).exactly(2).times

        described_class.condition_response(condition, log)

        expect(File.read(filepath)).to include 'Moving backup files to AWS S3'
      end

      it 'Prunes excess backup files on local storage' do
        expect(described_class).to receive(:delete_excess_backup_files).exactly(2).times

        described_class.condition_response(condition, log)

        expect(File.read(filepath)).to include 'Pruning older backups on local storage'
      end
    end
  end
end
