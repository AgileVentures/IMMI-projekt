Given(/^the following applications exist:$/) do |table|
  table.hashes.each do |application|
    FactoryGirl.create(:membership_application, application)
  end
end

Then(/^I should see "([^"]*)" applications$/) do |number|
  expect(page).to have_selector('.companies', count: number)
end
