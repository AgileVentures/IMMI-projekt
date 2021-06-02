# General steps for viewing and working with tables


# Look for {digits} rows (tr) that have a specific CSS class in the table body (tbody)
# the table is identified by an id or caption; @see the have_table method in capybara-3.16.1/lib/capybara/node/matchers.rb
# Example:
#   I should see 5 "a-user" rows in the table "all-users"
#     verifies that there are 5 rows, each having the CSS class "a-user" (tr.a-user)
#
And("I should see {digits} {capture_string} rows in the table {capture_string}") do |num_rows, tr_css_class, table_locator|
  expect(page).to have_table(table_locator)
  table = page.find_by_id(table_locator)
  expect(table).to have_xpath("tbody/tr[@class='#{tr_css_class}']", count: num_rows)
end


# the table is identified by an id or caption; @see the have_table method in capybara-3.16.1/lib/capybara/node/matchers.rb
And("I should see {digits} rows in the table {capture_string}") do |num_rows, table_locator|
  expect(page).to have_table(table_locator)
  table = page.find_by_id(table_locator)
  expect(table).to have_selector('tr', count: num_rows)
end


And("I should{negate} see {capture_string} in the {capture_string} table") do |negate, entry_text, table_locator|
  expect(page).to have_table(table_locator)
  expect(page).send (negate ? :not_to : :to), have_table(table_locator, text: entry_text)
end


And("I should{negate} see CSS class {capture_string} with text {capture_string} in the table with id {capture_string}") do | negatation, css_class, text, table_id|
  table =  page.find_by_id(table_id)
  expect(page).to have_table(table)
  expect(table).send (negatation ? :not_to : :to), have_xpath("tbody/tr/td[ (#{xpath_for_element_with_class(css_class)}) and (descendant::text()[contains(.,'#{text}')]) ]")
end

Then('css class {capture_string} should{negate} appear {digits} times in the table with the {capture_string} css class') do |expected_css_class, negated, num_times, table_class|
  # table_class = 'users'
  options = {}
  options[:count] = num_times
  table =  page.find('table', class: [table_class])
  expect(table).not_to be_nil
  expect(table).send (negated ? :not_to : :to), have_css(".#{expected_css_class}", count: num_times)
end
