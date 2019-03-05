Given(/^I am on the search page with the map "([^"]*)"$/) do |page|
  #page = root_path
  visit page
end

Then("I should see the GeoTrust SSL certificate Image") do
  save_and_open_page page
  expect(page).to have_xpath("//img[contains(@src,'RapidSSL_SEAL-90x50.gif')]")
end
