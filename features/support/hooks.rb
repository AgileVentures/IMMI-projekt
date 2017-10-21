Before('@selenium, @selenium') do
  Capybara.current_driver = :poltergeist
end

Before('@selenium') do
  # Use this hook for running headless tests using Chrome
  Capybara.current_driver = :selenium
end

Before('@selenium_browser') do
  # Use this hook for running tests with visible browser
 Capybara.current_driver = :selenium_browser
end

After('@selenium, @selenium, @selenium, @selenium_browser') do
  ajax_active = !page.evaluate_script('window.jQuery ? jQuery.active : 0').zero?
  Capybara.reset_sessions!
  Capybara.current_driver = :rack_test
  raise "expected all ajax requests to be completed after scenario, but some ajax requests were still running." if ajax_active
end
