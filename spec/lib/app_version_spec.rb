require_relative('../../lib/app_version')

RSpec.describe AppVersion do

  describe '.get_version' do

    let(:revision_fn) { 'REVISION' }
    let(:default_rev_fullpath) { File.join('.', revision_fn)}


    describe 'path for the REVISION file' do

      it 'default is .' do
        expect(File).to receive(:exist?).with(default_rev_fullpath)
        described_class.get_version
      end

      it 'uses path given' do
        given_path = 'given_path'
        expect(File).to receive(:exist?).with(File.join(given_path, revision_fn))
        described_class.get_version(given_path)
      end
    end


    describe 'REVISION file' do

      it 'filename is REVISION' do
        expect(File).to receive(:exist?).with(default_rev_fullpath)
        described_class.get_version
      end

      context 'no REVISION file' do

        it 'returns the default hardcoded info' do
          allow(File).to receive(:exist?).with(default_rev_fullpath).and_return(false)

          expect(described_class.get_version).to eq('1.0.0 <revision unknown>')
        end
      end


      context 'REVISION file exists' do

        it "displays revision <content of the file>" do
          allow(File).to receive(:exist?).with(default_rev_fullpath).and_return(true)
          allow(File).to receive(:open).with(default_rev_fullpath, 'rb:bom|utf-8').and_return('revision-file-contents')

          expect(described_class.get_version).to eq('revision revision-file-contents')
        end
      end
    end
  end

end
