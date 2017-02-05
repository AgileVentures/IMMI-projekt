Before('@javascript, @poltergeist') do
  Capybara.current_driver = :poltergeist
end

After('@javascript, @poltergeist') do
  Capybara.reset_sessions!
  Capybara.current_driver = :rack_test
end


Before('@poltergeist') do
  Capybara.current_driver = :poltergeist
end

After('@poltergeist') do
  Capybara.reset_sessions!
  Capybara.current_driver = :rack_test
end
