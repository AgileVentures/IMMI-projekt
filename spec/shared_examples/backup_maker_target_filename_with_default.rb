# Shared example for Backup


RSpec.shared_examples 'it takes a backup target filename, with default =' do |backup_maker, default_filename|

  before(:each) do
    @temp_backup_sourcedir = Dir.mktmpdir('faux-code-dir')
    @temp_backup_sourcefn1 = File.open(File.join(@temp_backup_sourcedir, 'some-sourcefile.txt'), 'w').path
  end

  describe 'target filename (the name of the backup file created)' do

    it "default target backup file is '#{default_filename}'" do
      backup_created_fn = backup_maker.backup(sources: [@temp_backup_sourcefn1])

      expect(backup_created_fn).to eq default_filename
      expect(File.exist?(default_filename)).to be_truthy
      File.delete(default_filename)
    end

    it 'can provide the name of the file' do
      target_dir = Dir.mktmpdir('backup-target-dir')
      given_backup_target_fn = File.join(target_dir, 'some_filename.tar.zzzx')

      backup_maker.backup(target: given_backup_target_fn,
                          sources: [@temp_backup_sourcefn1])

      expect(File.exist?(given_backup_target_fn)).to be_truthy
      File.delete(given_backup_target_fn)
    end
  end

end
