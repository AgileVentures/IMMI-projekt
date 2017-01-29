And(/^I click on "([^"]*)"$/) do |element|
  click_link_or_button element
end

And(/^I click on t\("([^"]*)"\)$/) do |element|
  click_link_or_button i18n_content("#{element}")
end

When /^I confirm popup$/ do
  # requires poltergeist:
  page.driver.accept_modal(:confirm)
end

When /^I dismiss popup$/ do
  page.driver.dismiss_modal(:confirm)
end

And(/^I fill in "([^"]*)" with "([^"]*)"$/) do |field, value|
  fill_in field, with: value
end

And(/^I fill in t\("([^"]*)"\) with "([^"]*)"$/) do |field, value|
  fill_in i18n_content(field), with: value
end

When(/^I fill in the form with data :$/) do |table|
  data = table.hashes.first
  data.each do |label, value|
    unless value.empty?
      fill_in label, with: value
    end
  end
end

When(/^I fill in the translated form with data:$/) do |table|
  data = table.hashes.first
  data.each do |label, value|
    unless value.empty?
      fill_in i18n_content("#{label}"), with: value
    end
  end
end


When(/^I set "([^"]*)" to "([^"]*)"$/) do |list, option|
  select option, from: list
end

When(/^I set "([^"]*)" to t\("([^"]*)"\)$/) do |list, option|
  select i18n_content(option), from: list
end


Then(/^show me the page$/) do
  save_and_open_page
end

When(/^I leave the "([^"]*)" field empty$/) do |field|
  fill_in field, with: nil
end

When(/^I leave the t\("([^"]*)"\) field empty$/) do |field|
  fill_in i18n_content(field), with: nil
end

And(/^I click the "([^"]*)" action for the row with "([^"]*)"$/) do |action, row_content|
  find(:xpath, "//tr[contains(.,'#{row_content}')]/td/a", :text => "#{action}").click
end

And(/^I click the t\("([^"]*)"\) action for the row with "([^"]*)"$/) do |action, row_content|
  find(:xpath, "//tr[contains(.,'#{row_content}')]/td/a", :text => "#{i18n_content(action)}").click
end

When(/^I click on "([^"]*)" link$/) do |element|
  click_link element
end

And(/^I click on t\("([^"]*)"\) link$/) do |element|
  click_link i18n_content("#{element}")
end

And(/^I click on "([^"]*)" button$/) do |element|
  click_button element
end

And(/^I click on t\("([^"]*)"\) button$/) do |element|
  click_button i18n_content("#{element}")
end

And(/^I check the checkbox with id "([^"]*)"$/) do |element_id|
  check element_id
end

And(/^I uncheck the checkbox with id"([^"]*)"$/) do |element_id|
  uncheck element_id
end

When(/^(?:I|they) select "([^"]*)" in select list t\("([^"]*)"\)$/) do |item, lst|
  lst = i18n_content("#{lst}")
  find(:select, lst).find(:option, item).select_option
end

Then(/^I wait(?: for)? (\d+) second(?:s)?$/) do |seconds|
  sleep seconds.to_i.seconds
end
