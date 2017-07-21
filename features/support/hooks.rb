Before('@javascript, @poltergeist') do
  Capybara.current_driver = :poltergeist
end

After('@javascript, @poltergeist') do
  ajax_active = !page.evaluate_script('window.jQuery ? jQuery.active : 0').zero?
  Capybara.reset_sessions!
  Capybara.current_driver = :rack_test
  raise "expected all ajax requests to be completed after scenario, but some ajax requests were still running." if ajax_active
end

