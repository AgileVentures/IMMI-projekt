And(/^the following companies exist:$/) do |table|
  table.hashes.each do |company|
    FactoryGirl.create(:company, company)
  end
end

And(/^the following regions exist:$/) do |table|
  table.hashes.each do |region|
    FactoryGirl.create(:region, name: region)
  end
end

And(/^I am the page for company number "([^"]*)"$/) do |company_number|
  company = Company.find_by_company_number(company_number)
  visit path_with_locale(company_path company)
end

When(/^I am on the edit company page for "([^"]*)"$/) do |company_number|
  company = Company.find_by_company_number(company_number)
  visit path_with_locale(edit_company_path company)
end

Then(/^I can go to the company page for "([^"]*)"$/) do |company_number|
  company = Company.find_by_company_number(company_number)
  visit path_with_locale(edit_company_path company)
end

And(/^the "([^"]*)" should go to "([^"]*)"$/) do |link, url|
  expect(page).to have_link(link, href: url)
end

Then(/^the "([^"]*)" should not go to "([^"]*)"$/) do |link, url|
  expect(page).not_to have_link(link, href: url)
end
