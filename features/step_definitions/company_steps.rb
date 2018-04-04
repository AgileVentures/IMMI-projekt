And(/^the following companies exist:$/) do |table|
  table.hashes.each do |company|
    region = company.delete('region') || 'Stockholm'
    kommun = company.delete('kommun') || 'Stockholm'
    visibility = company.delete('visibility') || 'street_address'

    cmpy = FactoryBot.create(:company, company)

    cmpy.addresses.first.update(region: Region.find_or_create_by(name: region),
                                kommun: Kommun.find_or_create_by(name: kommun),
                                visibility: visibility)

  end
end

And(/^the following regions exist:$/) do |table|
  table.hashes.each do |region|
    FactoryBot.create(:region, region)
  end
end

And(/^the following kommuns exist:$/) do |table|
  table.hashes.each do |kommun|
    FactoryBot.create(:kommun, kommun)
  end
end

And(/^the following company addresses exist:$/) do |table|
  table.hashes.each do |address|
    company_name = address.delete('company_name')
    company = Company.find_by_name(company_name)

    region = Region.find_by_name(address.delete('region') || 'Stockholm')
    kommun = Kommun.find_by_name(address.delete('kommun') || 'Stockholm')
    FactoryBot.create(:company_address, region: region, kommun: kommun, addressable: company)
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

When "I click the {ordinal} address for company {capture_string}" do |ordinal, company|
  cmpy = Company.find_by name: company

  addr = cmpy.addresses.send(ordinal.lstrip)
  addr_link = addr.entire_address(full_visibility: true)

  click_link(addr_link)
end
