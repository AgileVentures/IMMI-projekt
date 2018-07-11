require 'vcr'

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir     = 'features/vcr_cassettes'
  c.allow_http_connections_when_no_cassette = true
  c.ignore_localhost = true
  c.default_cassette_options = { allow_playback_repeats: true }
end

VCR.cucumber_tags do |t|
  t.tag '@dinkurs_fetch'
  t.tag '@dinkurs_invalid_key'
end
