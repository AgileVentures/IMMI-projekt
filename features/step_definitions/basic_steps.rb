When(/^I click on(?: the)?( \w*)? #{CAPTURE_STRING}[ ]?(link|button)?$/) do |ordinal, element, type|
# use 'ordinal' when selecting among links or buttons all of which
# have the same selector (e.g., same label)

  raise 'must specify link or button to use ordinal' if ordinal and !type

  index = ordinal ? [0, 1, 2, 3, 4].send(ordinal.lstrip) : 0

  case type
    when 'link'
      all(:link, element)[index].click
    when 'button'
      all(:button, element)[index].click
    else
      click_link_or_button element
  end
end

When /^I confirm popup$/ do
  # requires poltergeist:
  using_wait_time 3 do
    page.driver.accept_modal(:confirm)
  end
end

When /^I confirm popup with message t\("([^"]*)"\)$/ do | modal_text |
  # requires poltergeist:
  using_wait_time 3 do
    page.driver.accept_modal(:confirm, {text: i18n_content("#{modal_text}")}) # will wait until it finds the text (or reaches Capybara max wait time)
  end
end

When /^I dismiss popup$/ do
  page.driver.dismiss_modal(:confirm)
end

When(/^I fill in #{CAPTURE_STRING} with #{CAPTURE_STRING}$/) do |field, value|
  fill_in field, with: value
end

When(/^I press enter in #{CAPTURE_STRING}$/) do |field|
  find_field(field).send_keys :enter
end

When(/^I fill in the( translated)? form with data:$/) do |translated, table|
  data = table.hashes.first
  data.each do |label, value|
    if translated
      fill_in i18n_content("#{label}"), with: value
    else
      fill_in label, with: value
    end
  end
end

When(/^(?:I|they) select #{CAPTURE_STRING} in select list #{CAPTURE_STRING}$/) do |option, list|
  select option, from: list
end

When(/^(?:I|they) select radio button #{CAPTURE_STRING}/) do |label_text|
  find(:xpath, "//label[contains(.,'#{label_text}')]/input[@type='radio']").click
end

When(/^I click the #{CAPTURE_STRING} action for the row with #{CAPTURE_STRING}$/) do |action, row_content|
  find(:xpath, "//tr[contains(.,'#{row_content}')]/td/a", :text => "#{action}").click
end

When(/^I (check|uncheck) the checkbox with id #{CAPTURE_STRING}$/) do |action, element_id|
  send action, element_id
end

When(/^I click the radio button with id #{CAPTURE_STRING}$/) do |element_id|
  find("##{element_id}").click
end

When(/^I wait(?: for)? (\d+) second(?:s)?$/) do |seconds|
  sleep seconds.to_i.seconds
end

When /^I wait for all ajax requests to complete$/ do
  Timeout.timeout(Capybara.default_max_wait_time) do
    loop until page.evaluate_script('window.jQuery ? jQuery.active : 0').zero?
  end
end

And(/^show me the page$/) do
  save_and_open_page
end
