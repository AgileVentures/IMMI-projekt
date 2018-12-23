RSpec.shared_context 'create logger' do

  SPEC_LOGDIR_PREFIX = 'alspec'
  SPEC_LOGNAME       = 'testlog.log'

  let(:filepath) { File.join(Dir.mktmpdir(SPEC_LOGDIR_PREFIX), SPEC_LOGNAME) }
  let(:log) { ActivityLogger.open(filepath, 'TEST', 'open', false) }
end
