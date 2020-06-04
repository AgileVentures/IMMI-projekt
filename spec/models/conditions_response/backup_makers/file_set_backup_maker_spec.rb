require 'rails_helper'
require_relative File.join(Rails.root, 'app/models/conditions_response/backup')
#require_relative File.join(Rails.root, 'app/models/conditions_response/shf_condition_error_backup_errors.rb')

require 'shared_examples/backup_maker_target_filename_with_default'
require 'shared_context/expect_tar_has_entries'


RSpec.describe ShfBackupMakers::FileSetBackupMaker do


  describe 'Unit tests' do

    include_context 'expect tar file has entries'

    let(:subject) { described_class.new(name: 'some set of files') }

    let(:backup_using_defaults) { described_class.new(name: 'backup using defaults') }


    it 'default base_filename is "name.tar" where the name has been cleaned up' do
      new_maker = described_class.new(name: 'replace spaces with _ and remove non 0-9 a-zA-Z!&@\#$:!ä(ひらがな) characters')
      expect(new_maker.base_filename).to eq 'replace_spaces_with___and_remove_non_0-9_a-zA-Z_characters.tar'
    end


    describe 'name' do

      it 'must have a name' do
        expect { described_class.new(target_filename: 'some_filename',
                                     backup_sources: ['source1.txt']) }.to raise_error(ShfConditionError::BackupFileSetMissingNameError)
      end

      it 'name cannot be blank' do
        expect { described_class.new(name: '',
                                     target_filename: 'some_filename',
                                     backup_sources: ['source1.txt']) }.to raise_error(ShfConditionError::BackupFileSetNameCantBeBlankError)
      end

    end


    describe 'excludes' do

      it 'creates a string with each one as an "--exclude=" option for the tar command' do
        files_backup = described_class.new(name: 'excludes test', excludes: ['this.txt', 'blorf.*'])

        exclude_opts_str = files_backup.send(:exclude_opts)
        expect(exclude_opts_str).to eq("--exclude='this.txt' --exclude='blorf.*'")
      end
    end


    it 'default days_to_keep is 3' do
      expect(described_class.new(name: 'files').days_to_keep).to eq 3
    end


    describe '#backup' do

      let(:tar_options) { '--create --gzip --dereference' }

      it 'uses #shell_cmd to create a tar with all entries in sources, excluding any given' do

        temp_backup_sourcedir = Dir.mktmpdir('faux-code-dir')
        temp_backup_sourcefn1 = File.open(File.join(temp_backup_sourcedir, 'faux-codefile.rb'), 'w').path
        temp_backup_sourcefn2 = File.open(File.join(temp_backup_sourcedir, 'faux-otherfile.rb'), 'w').path
        temp_subdir = File.join(temp_backup_sourcedir, 'subdir')
        FileUtils.mkdir_p(temp_subdir)
        temp_backup_in_subdir_fn = File.open(File.join(temp_backup_sourcedir, 'subdir', 'faux-codefile2.rb'), 'w').path

        temp_backup_sourcedir2 = Dir.mktmpdir('faux-code-dir2')
        temp_backup_source2fn1 = File.open(File.join(temp_backup_sourcedir2, 'dir2-faux-codefile.rb'), 'w').path

        temp_backup_target = File.join(Dir.mktmpdir('temp-files-dir'), 'files_backup_fn.zzkx')

        files_backup = described_class.new(name: 'test shell_cmd',
                                           target_filename: temp_backup_target,
                                           backup_sources: [temp_backup_sourcedir,
                                                            temp_backup_source2fn1])
        files_backup.backup

        expect(File.exist?(temp_backup_target)).to be_truthy

        expect_tar_has_these_entries(temp_backup_target, [temp_backup_sourcefn1,
                                                          temp_backup_sourcefn2,
                                                          temp_backup_in_subdir_fn,
                                                          temp_backup_source2fn1,
                                                          temp_backup_sourcedir,
                                                          temp_subdir])
      end

      it_behaves_like 'it takes a backup target filename, with default =',
                      described_class.new(name: 'target files test'),
                      'target_files_test.tar'


      describe 'source files for the backup' do

        it "default sources = [] (none)" do
          expect(subject).to receive(:shell_cmd)
                                 .with(/tar #{tar_options} (.*) #{[].join(' ')}/)
          subject.backup
        end


        it 'can provide the sources' do

          files_backup = described_class.new(name: 'testing sources')

          source_dir = Dir.mktmpdir('backup-sources-dir')
          source_files = []
          3.times do |i|
            fn = File.join(source_dir, "source-#{i}.txt")
            File.open(fn, 'w') { |f| f.puts "blorf" }
            source_files << fn
          end

          expect(files_backup).to receive(:shell_cmd)
                                      .with(/tar #{tar_options} (.*) #{source_files.join(' ')}/)
                                      .and_call_original
          backup_created = files_backup.backup(sources: source_files)

          expect(File.exist?(backup_created)).to be_truthy
          File.delete(backup_created)
        end

      end

      it 'will fail unless sources are provided (tar will fail with an empty list)' do
        expect { subject.backup }.to raise_error(ShfConditionError::BackupCommandNotSuccessfulError, /tar/)
      end

      it 'excludes provides a list of --exclude= patterns' do
        source_dir = Dir.mktmpdir('backup-sources-dir')
        subdir = File.join(source_dir, 'subdir')

        files_backup = described_class.new(name: 'testing sources',
                                           excludes: ['*-1.txt', 'subdir'])

        source_files = []
        3.times do |i|
          fn = File.join(source_dir, "source-#{i}.txt")
          File.open(fn, 'w') { |f| f.puts "blorf" }
          source_files << fn
        end
        Dir.mkdir(subdir)
        fn = File.join(subdir, "source.txt")
        File.open(fn, 'w') { |f| f.puts "blorf" }
        source_files << fn

        expect(files_backup).to receive(:shell_cmd)
                                    .with(/tar #{tar_options} (.*) #{source_files.join(' ')}/)
                                    .and_call_original

        backup_created = files_backup.backup(sources: source_files)

        expect(File.exist?(backup_created)).to be_truthy

        expect_tar_has_these_entries(backup_created, [File.join(source_dir, 'source-0.txt'),
                                                      File.join(source_dir, 'source-2.txt')])

        File.delete(backup_created)
      end
    end

  end
end
