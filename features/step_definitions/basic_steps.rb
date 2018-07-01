When "I click on{optional_string} {capture_string}{optional_string}" do |ordinal, element, type|
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

When "I click on and accept{optional_string} {capture_string}{optional_string}" do |ordinal, element, type|
  page.driver.accept_modal(:confirm, wait: 4) do
    confirm_step = "I click on" + (ordinal ? "#{ordinal}" : '') +
        " \"#{element}\"" + (type ? " #{type}" : '')
    step confirm_step
  end
end

When /^I confirm popup$/ do

  if Capybara.current_driver == :poltergeist
    using_wait_time 3 do
      page.driver.accept_modal(:confirm)
    end
  elsif Capybara.current_driver == :selenium_browser
    page.driver.browser.switch_to.alert.accept
  else
    raise 'step not configured for current browser driver'
  end
end

When /^I confirm popup with message t\("([^"]*)"\)$/ do |modal_text|
  # requires poltergeist:
  using_wait_time 3 do
    page.driver.accept_modal(:confirm, { text: i18n_content("#{modal_text}") }) # will wait until it finds the text (or reaches Capybara max wait time)
  end
end

When /^I dismiss popup$/ do
  page.driver.dismiss_modal(:confirm)
end

When "I fill in {capture_string} with {capture_string}" do |field, value|
  fill_in field, with: value
end

When "I press enter in {capture_string}" do |field|
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

When "I select {capture_string} in select list {capture_string}" do |option, list|
  select option, from: list
end

When "I select radio button {capture_string}" do |label_text|
  find(:xpath, "//label[contains(.,'#{label_text}')]/input[@type='radio']").click
end

When "I click the {capture_string} action for the row with {capture_string}" do |action, row_content|
  find(:xpath, "//tr[contains(.,'#{row_content}')]/td/a", :text => "#{action}").click
end

When "I click and accept the {capture_string} action for the row with {capture_string}" do |action, row_content|
  page.driver.accept_modal(:confirm, wait: 4) do
    step %{I click the "#{action}" action for the row with "#{row_content}"}
  end
end

When "I {action} the checkbox with id {capture_string}" do |action, element_id|
  send action, id: element_id
rescue Capybara::ElementNotFound
  page.execute_script("document.getElementById(\"#{element_id}\").click()")
end

When "I click the radio button with id {capture_string}" do |element_id|
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

Given(/^the date is set to "([^"]*)"$/) do |date|
  Timecop.freeze(Time.zone.parse(date))
end

# Hide (or show) the search form by clicking on the button
#  This is frequently used to hide the search form on a page so that
#  items in the select lists are not included in counts.
#
#  assumes that the hide/show button has id = "toggle_search_form"
#
And(/^I (hide|show) the search form$/) do | _hide_or_show |
  click_link_or_button "toggle_search_form"  # click on "toggle_search_form"
end


And(/^I scroll to the top$/) do
  page.evaluate_script("scroll(0, 0)")
end
