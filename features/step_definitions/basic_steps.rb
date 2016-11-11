And(/^I click on "([^"]*)"$/) do |element|
  click_link_or_button element
end

And(/^I fill in "([^"]*)" with "([^"]*)"$/) do |field, value|
  fill_in field, with: value
end

When(/^I fill in the form with data :$/) do |table|
  data = table.hashes.first
  data.each do |label, value|
    unless value.empty?
      fill_in label, with: value
    end
  end
end
