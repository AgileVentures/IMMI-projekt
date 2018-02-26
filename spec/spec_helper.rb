require 'simplecov'
# ^^ https://github.com/colszowka/simplecov#using-simplecov-for-centralized-config

require 'pundit/rspec'
require 'paperclip/matchers'

require 'vcr'


# Coveralls.wear_merged!('rails')

# CodeClimate::TestReporter.start

# helper to be used in specs for services
SERVICES_PATH = File.absolute_path(File.join(__dir__, '..', 'app','services'))

# location of our testing fixtures
FIXTURES_PATH = File.join(__dir__, 'fixtures')


VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end


RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include Paperclip::Shoulda::Matchers

  config.after(:suite) do
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/test_paperclip_files/"]) if Object.const_defined?('Rails')
  end
end
