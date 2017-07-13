Before('@javascript, @poltergeist') do
  Capybara.current_driver = :poltergeist
end


After('@javascript, @poltergeist') do
  error = false
  Timeout.timeout(Capybara.default_max_wait_time) do
    while not page.evaluate_script('window.jQuery ? jQuery.active : 0').zero?
      error = true
    end
  end
  Capybara.reset_sessions!
  Capybara.current_driver = :rack_test
  raise "expected all ajax requests to be completed before finishing scenario, but they were not" if error
end
