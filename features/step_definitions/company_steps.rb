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



And(/^the name for company number "([^"]*)" is set to an empty string$/) do | company_number |
  co = Company.find_by_company_number(company_number)
  co.update(name: '')
  co.save!  # do not do validations in case we're putting this into a bad state on purpose
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

Then(/^all events for the company named "([^"]*)" are deleted from the database$/) do |company_name|
  co = Company.find_by_name(company_name)
  co.events.clear
end

When "I click the {ordinal} address for company {capture_string}" do |ordinal, company|
  cmpy = Company.find_by name: company

  addr = cmpy.addresses.send(ordinal.lstrip)
  addr_link = addr.entire_address(full_visibility: true)

  click_link(addr_link)
end

And(/I scroll so the top of the list of companies is visible/) do
  step %{I scroll so element with id "shf_applications_list" is visible}
end
