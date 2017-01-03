Before('@javascript') do
  Capybara.current_driver = :poltergeist
end

After('@javascript') do
  Capybara.reset_sessions!
  Capybara.current_driver = :rack_test
end
