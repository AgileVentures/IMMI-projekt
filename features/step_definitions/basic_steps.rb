Given(/^I am on the application page$/) do
  visit new_user_registration_path
end

When(/^I fill in "([^"]*)" with "([^"]*)"$/) do |element, text|
  fill_in element, with: text
end

When(/^I press the "([^"]*)" button$/) do |button|
  click_button(button)
end

Then(/^I should see "([^"]*)"$/) do |content|
  expect(page).to have_content(content)
end

Then(/^show me the page$/) do
  save_and_open_page
end
