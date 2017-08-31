And(/^the following companies exist:$/) do |table|
  table.hashes.each do |company|
    region = company.delete('region')
    kommun = company.delete('kommun')

    cmpy = FactoryGirl.create(:company, company)

    cmpy.addresses.first.update(region: Region.find_by_name(region),
                                kommun: Kommun.find_by_name(kommun))

  end
end

And(/^the following regions exist:$/) do |table|
  table.hashes.each do |region|
    FactoryGirl.create(:region, region)
  end
end

And(/^the following kommuns exist:$/) do |table|
  table.hashes.each do |kommun|
    FactoryGirl.create(:kommun, kommun)
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

And(/^the "([^"]*)" should( not)? go to "([^"]*)"$/) do |link, negate, url|
  expect(page).send (negate ? :not_to : :to), have_link(link, href: url)
end

And(/^the name for region "([^"]*)" is changed to "([^"]*)"$/) do | old_name, new_name |
  region = Region.find_by_name(old_name)
  region.name = new_name
  region.save!  # do not do validations in case we're putting this into a bad state on purpose
end

And(/^the region for company named "([^"]*)" is set to nil$/) do | company_name |
  co = Company.find_by_name(company_name)
  co.addresses.first.update(region: nil)
  co.save!  # do not do validations in case we're putting this into a bad state on purpose
end


Given(/^all addresses for the company named "([^"]*)" are not geocoded$/) do |company_name|
  co = Company.find_by_name(company_name)

  # Cannot do this through our Models, because it will be geocoded.
  # Have to use SQL to set up this situation

  addr_ids = co.addresses.map(&:id)

  query = "UPDATE addresses SET latitude=NULL, longitude=NULL WHERE id in (#{addr_ids.join(', ')})"
  Address.connection.exec_query(query)

end