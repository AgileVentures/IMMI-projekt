Before do
  load_default_data
end

Before('@selenium') do
  # Use this hook for running headless tests using Chrome
  Capybara.current_driver = :selenium
end

Before('@selenium_browser') do
  # Use this hook for running tests with visible browser
 Capybara.current_driver = :selenium_browser
end

Before('@dinkurs_fetch or @dinkurs_invalid_key') do
  VCR.configure do |c|
    c.hook_into :webmock
    c.cassette_library_dir     = 'features/vcr_cassettes'
    c.allow_http_connections_when_no_cassette = true
    c.ignore_localhost = true
    c.default_cassette_options = { allow_playback_repeats: true }
  end
end

After('@selenium or @selenium_browser') do
  ajax_active = !page.evaluate_script('window.jQuery ? jQuery.active : 0').zero?
  Capybara.reset_sessions!
  Capybara.current_driver = :rack_test
  raise "expected all ajax requests to be completed after scenario, but some ajax requests were still running." if ajax_active
end

After('@time_adjust') do
  Timecop.return
end

def load_default_data
  FactoryBot.create(:app_configuration)
end
