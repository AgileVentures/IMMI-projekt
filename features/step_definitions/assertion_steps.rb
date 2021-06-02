World(PathHelpers)


# Generate the xpath text for an element that has a CSS class.
# It can be the only clas or one of a list of classes.
def xpath_for_element_with_class(class_name)
  "contains(concat(' ',normalize-space(@class),' '),' #{class_name} ')"
  # must include spaces around the class name, otherwise it will find elements with class names that include that as a substring
  # "contains(@class,' #{class_name} ') or contains(@class,'#{class_name} ') or contains(@class,' #{class_name}') or @class='#{class_name}'"
end



Then "I should{negate} see {capture_string}" do |negate, content|
  begin
    expect(page).send (negate ? :not_to : :to), have_content(/#{content}/i)
  rescue RSpec::Expectations::ExpectationNotMetError
    expect(page).send (negate ? :not_to : :to), have_content(content)
  end
end


# It's not currently possible to have an optional parameter in Gherkin, so have to have this explicit expression. 2021-04-05 cucumber-expressions v10.3.0
Then "I should{negate} see css class {capture_string}" do |negated, expected_text|
  options = {}
  options[:count] = 1
  expect(page).send (negated ? :not_to : :to ), have_css(".#{expected_text}", options)
end

# It's not currently possible to have an optional parameter in Gherkin, so have to have this explicit expression. 2021-04-05 cucumber-expressions v10.3.0
Then "I should{negate} see css class {capture_string} {digits} time(s)" do |negated, expected_text, num_times|
  options = {}
  options[:count] = num_times
  expect(page).send (negated ? :not_to : :to ), have_css(".#{expected_text}", options)
end


Then "I should see raw HTML {capture_string}" do |html|
  expect(page.body).to match html
end

Then "I should see {capture_string} or {capture_string} in the raw HTML" do |str1, str2|
  expect(page.body).to (match(str1).or match(str2))
end

Then "I should{negate} see {capture_string} image" do |negate, alt_text|
  expect(page).send (negate ? :not_to : :to), have_xpath("//img[contains(@alt,'#{alt_text}')]")
end

Then "I should{negate} see button {capture_string}" do |negate, button|
  expect(page).send (negate ? :not_to : :to), have_button(button)
end

Then "I should{negate} see {capture_string} link" do |negate, link_label|
  expect(page).send (negate ? :not_to : :to), have_link(link_label)
end


# Note that <a href> (links) that are styled as buttons are not really/always disabled if the disabled property is set. [2019-12-05]
# This has not yet been standardized.  Per Bootstrap (getbootstrap.com) you must add the 'disabled' class
# to the <a href>.  To check if a link button is disabled, check for that CSS class.
Then "the link button {capture_string} should{negate} be disabled" do | link_button_label, negated |
  expect(page).to have_link(link_button_label)
  link_button =find_link(link_button_label)

  expect(link_button['class']).send (negated ? :not_to : :to), include('disabled')
end


Then(/^I should( not)? see the (?:checkbox|radio button) with id "([^"]*)" checked$/) do |negate, checkbox_id|
  #  expect(page).send (negate ? :not_to : :to),  have_checked_field(checkbox_id)
  expect(page).to have_selector(:id, checkbox_id), "got: #{page.html}"
end

Then(/^I should( not)? see the (?:checkbox|radio button) with id "([^"]*)" unchecked$/) do |negate, checkbox_id|
  expect(page).send (negate ? :not_to : :to), have_unchecked_field(checkbox_id)
end

Then(/^I should( not)? see the (?:checkbox|radio button) with label "([^"]*)" checked$/) do |negate,  label_str|
  for_id = for_value_of_label(label_str)
  expect(page).send (negate ? :not_to : :to), have_checked_field(for_id)
end

Then(/^I should( not)? see the (?:checkbox|radio button) with label "([^"]*)" unchecked$/) do |negate,  label_str|
  for_id = for_value_of_label(label_str)
  expect(page).send (negate ? :not_to : :to), have_unchecked_field(for_id)
end


Then(/^I should be on (?:the )*"([^"]*)" page(?: for "([^"]*)")?$/) do |page, email|
  user = email == nil ? @user : User.find_by(email: email)
  expect(current_path_without_locale(current_path)).to eq get_path(page, user)
end

Then(/^I should see:$/) do |table|
  table.hashes.each do |hash|
    expect(page).to have_content hash[:content]
  end
end


And("I should see {capture_string} in the h1 title") do | title_text|
  expect(page).to have_xpath( "//h1[contains(text(), '#{title_text}')]")
end


Then "I should{negate} see {capture_string} in the row for {capture_string}" do |negate, text, row_identifier|
  row = find(:xpath, "//tr[td//text()[contains(.,'#{row_identifier}')]]")
  expect(row).send (negate ? :not_to : :to), have_content(text)
end

Then "I should{negate} see {capture_string} in the div with id {capture_string}" do |negate, expected_text, div_id|
  div = page.find(:id, div_id)
  expect(div).send (negate ? :not_to : :to), have_content(expected_text)
end

Then "I should{negate} see {capture_string} {digits} time(?:s) in the div with id {capture_string}" do |negate, expected_text, num_times, div_id|
  div = page.find(:id, div_id)
  expect(div).send (negate ? :not_to : :to), have_content(expected_text, count: num_times)
end

Then(/^I should see "([^"]*)" applications$/) do |number|
  expect(page).to have_selector('tr.applicant', count: number)
end

Then(/^I should see "([^"]*)" companies/) do |number|
  expect(page).to have_selector('tr.company', count: number)
end

Then(/^I should see "([^"]*)" business categories/) do |number|
  expect(page).to have_selector('tr.business_category', count: number)
end

Then(/^I should see "([^"]*)" address(?:es)?/) do |number|
  expect(page).to have_selector('tr.address', count: number)
end

Then(/^I should see "([^"]*)" event(?:s)?/) do |number|
  expect(page).to have_selector('tr.event', count: number)
end

Then "the field {capture_string} should{negate} have a required field indicator" do |label_text, negate|
  expect(page).send (negate ? :not_to : :to), have_xpath("//label[@class='required'][text()='#{label_text}']")
end


# Examples of what this will match:
#  I should see 3 a_css_class rows
#  I should see 1 some_css_class row
Then("I should see {digits} {capture_string} rows") do |n, css_class_name|
  n = n.to_i
  expect(page).to have_selector(".#{css_class_name}", count: n)
  expect(page).not_to have_selector(".#{css_class_name}", count: n+1)
end

Then(/^I should see at least one column with class "([^"]*)"/) do |css_class_name|
  expect(page).to have_xpath("//td[@class='#{css_class_name}']")
end

Then "I should see error {capture_string} {capture_string}" do |model_attribute, error|
  expect(page).to have_content("#{model_attribute} #{error}")
end

Then "I should see status line with status {capture_string} and date {capture_string}" do |status, date_string|
  expect(page).to have_content("#{status} - #{date_string}")
end

Then "I should{negate} see status line with status {capture_string}" do |negate, status|
  expect(page).send (negate ? :not_to : :to), have_content("#{status} - ")
end

Then "I should see {digits} {capture_string}" do |n, content|
  n = n.to_i
  expect(page).to have_text("#{content}", count: n)
  expect(page).not_to have_text("#{content}", count: n + 1)
end

Then "I should see {digits} visible {capture_string}" do |n, content|
  n = n.to_i
  assert_text :visible, content, count: n
  assert_no_text :visible, content, count: n + 1
  # expect(page).not_to have_text("#{content}", count: n + 1)
end


Then "{capture_string} should{negate} be visible" do |string, negate|
  expect(has_text?(:visible, "#{string}")).to be negate == nil
end

# Tests that an input has a given value
Then "the {capture_string} field should be set to {capture_string}" do |field, text_value|
  expect(find_field(field).value).to eq(text_value)
end

Then(/^I should see link "([^"]*)" with target = "([^"]*)"$/) do |link_identifier, target_value|
  expect(find_link(link_identifier)[:target]).to eq(target_value)
end

Then "I should see flash text {capture_string}" do |text|
  expect(page).to have_selector('#flashes', text: text )
end

Then "I should{negate} see {capture_string} in the row for user {capture_string}" do |negate, expected_text, user_email|
  td = page.find(:css, 'td', text: user_email) # find the td with text = user_email
  tr = td.find(:xpath, './parent::tr') # get the parent tr of the td
  expect(tr.text).send (negate ? :not_to : :to), match(Regexp.new(expected_text))
end

Then "I should{negate} see the checkbox with id {capture_string} {checked} in the row for user {capture_string}" do |negate_see_it, checkbox_id, checked, user_email|
  td = page.find(:css, 'td', text: user_email)  # find the td with text = user_email
  tr = td.find(:xpath, './parent::tr') # get the parent tr of the td

  expect(tr).send (negate_see_it ? :not_to : :to), have_selector(:id, checkbox_id)
  #checkbox = tr.find(:xpath, '//td[descendant::input[@id="date_membership_packet_sent"]]')

  unless negate_see_it
    case checked
    when 'checked'
      expect(tr).to have_checked_field(checkbox_id)
    when 'unchecked'
      expect(tr).to have_unchecked_field(checkbox_id)
    end
  end
end

Then "I should{negate} see {capture_string} for class {capture_string} in the row for user {capture_string}" do |negate, expected_text, css_class, user_email|
  td = page.find(:css, 'td', text: user_email) # find the td with text = user_email
  tr = td.find(:xpath, './parent::tr') # get the parent tr of the td
  expect(tr).send (negate ? :not_to : :to), have_css(".#{css_class}", text: expected_text)
end

Then(/^I should( not)? see xpath "([^"]*)"$/) do |negate, xp|
  expect(page).send (negate ? :not_to : :to), have_xpath(xp)
end

Then("I should{negate} see {capture_string} before {capture_string}") do |not_see, beforeItem, afterItem|
  assert_text beforeItem
  regex = /#{Regexp.quote("#{beforeItem}")}.*#{Regexp.quote("#{afterItem}")}/m

  if not_see
    assert_no_text :visible, regex
  else
    assert_text :visible, regex
  end
end


Then("I should{negate} see {capture_string} before {capture_string} in the div with id {capture_string}") do |not_see, before_item, after_item, withinElement|
  node_to_search = withinElement ? page.find(:id, withinElement) : page

  node_to_search.assert_text before_item
  node_to_search.assert_text after_item
  regex = /#{Regexp.quote("#{before_item}")}.*#{Regexp.quote("#{after_item}")}/m

  if not_see
    node_to_search.assert_no_text :visible, regex
  else
    node_to_search.assert_text :visible, regex
  end
end


Then(/^I should be on the SHF document page for "([^"]*)"$/) do |doc_title|
  shf_doc = ShfDocument.find_by_title(doc_title)
  expect(current_path_without_locale(current_path)).to eq shf_document_path(shf_doc)
end

Then(/^all addresses for the company named "([^"]*)" should( not)? be geocoded$/) do |company_name, no_geocode|
  co = Company.find_by_name(company_name)
  if no_geocode
    expect(co.addresses.reject(&:geocoded?).count).not_to be 0
  else
    expect(co.addresses.reject(&:geocoded?).count).to be 0
  end
end

# Checks that a certain option is selected for a text field (from https://github.com/makandra/spreewald)
Then "{capture_string} should{negate} have {capture_string} selected" do | select_list, negate, expected_string |

  try_again = true

  begin
    field = find_field(select_list)

    field_value = case field.tag_name
                    when 'select'
                      options = field.all('option')
                    selected_option = options.detect(&:selected?) || options.first
                    if selected_option && selected_option.text.present?
                      selected_option.text.strip
                    else
                        ''
                    end
                  else
                    field.value
                  end
  rescue Selenium::WebDriver::Error::StaleElementReferenceError
    if try_again
      try_again = false
      retry
    end
    raise
  end

  # https://www.seleniumhq.org/exceptions/stale_element_reference.jsp

  expect(field_value).send((negate ? :not_to : :to), eq(expected_string))
end

# Checks that a certain option does or does not exist in a select list
Then("{capture_string} should{negate} have {capture_string} as an option") do |select_list, negate, expected_string|
  field = find_field(select_list)

  select_options = case field.tag_name
                  when 'select'
                    field.all('option')
                   end
  expect(select_options.map(&:text)).send((negate ? :not_to : :to), include(expected_string))
end

And(/^the "([^"]*)" should( not)? go to "([^"]*)"$/) do |link, negate, url|
  expect(page).send (negate ? :not_to : :to), have_link(link, href: url)
end


And(/^the url "([^"]*)" should( not)? be a valid route$/) do |url, negate|
  if negate
    expect { visit url }.to raise_error(ActionController::RoutingError, "No route matches [GET] \"/#{url}\"")
  else
    visit url
  end
end

And(/^the page should( not)? be blank$/) do |negate|
  expect(page.body).send((negate ? :not_to : :to), be_empty)
end

Then(/^I should get a downloaded image with the filename "([^\"]*)"$/) do |filename|
  expect(page.driver.response_headers['Content-Disposition'])
    .to include("attachment; filename=\"#{filename}\"")
  expect(page.driver.response_headers['Content-Type'])
    .to eq 'image/jpg'
end

Then(/^I should see an inline image with the filename "([^\"]*)"$/) do |filename|
  expect(page.driver.response_headers['Content-Disposition'])
    .to include("inline; filename=\"#{filename}\"")
  expect(page.driver.response_headers['Content-Type'])
    .to eq 'image/jpg'
end

When "I cannot select {capture_string} in select list {capture_string}" do |option, list|
  expect(find_field(list).text.match(option)).to be_nil
end

# Icons
Then "I should{negate} see an icon with CSS class {capture_string}" do |negate, icon_css_class|
  expect(page).send (negate ? :not_to : :to), have_xpath("//a/i[contains(@class, '#{icon_css_class}')]")
end

Then "I should{negate} see an icon with CSS class {capture_string} that is linked to {capture_string}" do |negate, icon_css_class, linked_url|
  expect(page).send (negate ? :not_to : :to), have_xpath("//a[contains(@href, '#{linked_url}')]/i[contains(@class, '#{icon_css_class}')]")
end

Then "I should{negate} see the icon with CSS class {capture_string} for the row with {capture_string}" do |negate, icon_css_class, row_text|
  row_xpath = "//tr[contains(.,'#{row_text}')]"
  expect(page).to have_xpath(row_xpath)
  icon_xpath = "//i[contains(@class, '#{icon_css_class}')]"
  expect(page).send (negate ? :not_to : :to), have_xpath("#{row_xpath}#{icon_xpath}")
end

Then "I should{negate} see link {capture_string} on the row with {capture_string}" do | negate, link_text, row_text|
  row_xpath = "//tr[contains(.,'#{row_text}')]"
  expect(page).to have_xpath(row_xpath)
  link_xpath = "//a[contains(.,'#{link_text}')]"
  expect(page).send (negate ? :not_to : :to), have_xpath("#{row_xpath}#{link_xpath}")
end
