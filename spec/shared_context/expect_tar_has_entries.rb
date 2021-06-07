RSpec.shared_context 'expect tar file has entries' do

# use 'tar --list' to verify that the tar_file has the expected files and directories
  def expect_tar_has_these_entries(tar_file, expected_entries)

    expect(File.exist?(tar_file)).to be_truthy

    backup_file_list = %x<tar --list --file=#{tar_file}>
    backup_file_list.gsub!(/\n/, ' ')
    backup_files = backup_file_list.split(' ')

    # tar will remove leading "/" from source file names, so remove the leading "/"
    expected = expected_entries.map { |exp_file| exp_file.gsub(/^\//, '') }

    # directories _should_ have a trailing '/', which is how tar will store directories
    expected.each do | exp_file |
      exp_file_base = File.basename(exp_file)
      if File.extname(exp_file_base).empty? && !(exp_file_base.match(/^\.(.*)/)) # if a directory name and it doesn't start with .
        exp_file.gsub!(/$/, '/') # append '/'
      end
    end

    expect(backup_files).to match_array(expected), "Expected this: #{expected}\n got this: #{backup_files}\n" +
      "  missing elements: #{expected - backup_files}\n" +
      "  extra   elements: #{backup_files - expected}\n"
  end

end
