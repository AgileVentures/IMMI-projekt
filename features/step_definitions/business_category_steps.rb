And(/^the following business categories exist$/) do |table|
  table.hashes.each do |business_category|
    FactoryBot.create(:business_category, business_category)
  end
end


And(/^I navigate to the business category edit page for "([^"]*)"$/) do |name|
  business_category = BusinessCategory.find_by(name: name)
  visit path_with_locale(edit_business_category_path(business_category))
end

And(/^I select "([^"]*)" Category/) do |element|
  page.check(element)
end

Given(/^I am on the business category "([^"]*)"$/) do |name|
  business_category = BusinessCategory.find_by(name: name)
  visit path_with_locale(business_category_path(business_category))
end

And(/I should( not)? see "([^"]*)" in the business categories table$/) do | negate, cmpy |
  step %{I should#{negate} see xpath "tr[td//text()[contains(., '#{cmpy}')]]"}
end
