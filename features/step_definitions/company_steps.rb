And(/^the following companies exist:$/) do |table|
  table.hashes.each do |company|
    region = company.delete('region')
    cmpy = FactoryGirl.create(:company, company)
    if cmpy.region
      cmpy.region = Region.find_by_name(region)
      cmpy.save
    end
  end
end

And(/^the following regions exist:$/) do |table|
  table.hashes.each do |region|
    FactoryGirl.create(:region, region)
  end
end

And(/^I am (on )*the page for company number "([^"]*)"$/) do |grammar_fix_on, company_number|
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

And(/^the name for region "([^"]*)" is changed to "([^"]*)"$/) do | old_name, new_name |
  region = Region.find_by_name(old_name)
  region.name = new_name
  region.save!  # do not do validations in case we're putting this into a bad state on purpose
end

And(/^the region for company named "([^"]*)" is set to nil$/) do | company_name |
  co = Company.find_by_name(company_name)
  co.update(region: nil)
  co.save!  # do not do validations in case we're putting this into a bad state on purpose
end
