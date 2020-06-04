require 'rails_helper'
require_relative File.join(Rails.root, 'app/models/conditions_response/backup')

RSpec.describe ShfBackupMakers::AbstractBackupMaker do

  describe 'Unit tests' do

    it 'default sources = []' do
      expect(subject.backup_sources).to eq []
    end

    it 'base_filename = backup-<class name>-<DateTime.current>.tar' do
      expect(subject.base_filename).to match(/backup-AbstractBackupMaker\.tar/)
    end


    describe 'shell_cmd' do

      it 'raises an error if one was encountered' do
        allow(Open3).to receive(:capture3).and_raise(Errno::ENOENT, 'blorfo')
        expect { subject.shell_cmd('blorfo') }.to raise_error(Errno::ENOENT, 'No such file or directory - blorfo')
      end

      it 'raises BackupCommandNotSuccessfulError and shows the command, status, stdout, and stderr if it was not successful' do
        allow(Open3).to receive(:capture3).and_return(['output string', 'error string', nil])
        expect { subject.shell_cmd('blorfo') }.to raise_error(ShfConditionError::BackupCommandNotSuccessfulError,
                                                              "Backup Command Failed: blorfo. return status:   Error: error string  Output: output string")
      end

    end

    it 'backup raises NoMethodError Subclasses must define' do
      expect { subject.backup }.to raise_error(NoMethodError, 'Subclass must define the backup method')
    end

  end
end
