require 'rails_helper'
require_relative File.join(Rails.root, 'app/models/conditions_response/backup')

require 'shared_examples/backup_maker_target_filename_with_default'


RSpec.describe ShfBackupMakers::DBBackupMaker do

  describe 'Unit tests' do

    let(:backup_using_defaults) { DBBackupMaker.new }

    it 'base_filename = db_backup.sql' do
      expect(subject.base_filename).to eq 'db_backup.sql'
    end

    it 'default sources = [DB_NAME]' do
      expect(subject.backup_sources).to eq ['shf_project_production']
    end

    describe '#backup' do

      describe 'dumps the dbs in sources and creates 1 backup gzipped file' do

        before(:each) { @temp_dir = Dir.mktmpdir('db-backup-source-dir') }

        it 'using default target' do

          new_db_backup = described_class.new(backup_sources: ['this1', 'that2'])

          expected_backup_fname = 'db_backup.sql'
          expect(new_db_backup).to receive(:shell_cmd).with("touch #{expected_backup_fname}").and_call_original
          expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d this1 | gzip > #{expected_backup_fname}")
          expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d that2 | gzip > #{expected_backup_fname}")

          new_db_backup.backup()

          expect(File.exist?(expected_backup_fname)).to be_truthy
          File.delete(expected_backup_fname)
        end

        it 'given a filename to use as the target' do

          temp_backup_target = File.join(@temp_dir, 'db_dumped.sql')

          new_db_backup = described_class.new(target_filename: temp_backup_target,
                                              backup_sources: ['this1', 'that2'])

          expected_backup_fname = temp_backup_target
          expect(new_db_backup).to receive(:shell_cmd).with("touch #{expected_backup_fname}").and_call_original
          expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d this1 | gzip > #{expected_backup_fname}")
          expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d that2 | gzip > #{expected_backup_fname}")

          new_db_backup.backup
          expect(File.exist?(expected_backup_fname)).to be_truthy
        end
      end

      it_behaves_like 'it takes a backup target filename, with default =',
                      described_class.new,
                      'db_backup.sql'

      describe 'source files for the backup' do

        before(:each) { allow(subject).to receive(:shell_cmd).with(/touch (.*)/) }

        it 'default sources = [shf_project_production]' do
          expect(subject).to receive(:shell_cmd)
                                 .with(/pg_dump (.*) shf_project_production/)
          subject.backup
        end


        it 'can provide the sources' do

          source_files = ['some.db', 'some-other.db', 'a-production.db']

          expect(subject).to receive(:shell_cmd).with(/pg_dump (.*) some.db/)
          expect(subject).to receive(:shell_cmd).with(/pg_dump (.*) some-other.db/)
          expect(subject).to receive(:shell_cmd).with(/pg_dump (.*) a-production.db/)

          subject.backup(sources: source_files)
        end

      end

      it 'will not fail if no sources are specified since default is not empty' do
        expect(subject).to receive(:shell_cmd).with(/touch (.*)/)
        expect(subject).to receive(:shell_cmd)
                               .with(/pg_dump (.*) shf_project_production/)
        subject.backup
      end

    end

  end
end
