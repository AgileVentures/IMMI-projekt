Given("I am on the search page with the map") do
  visit 'https://hitta.sverigeshundforetagare.se/'
end

Then("I should see the GeoTrust SSL certificate Image") do
  expect(page).to have_xpath("//img[contains(@src,'RapidSSL_SEAL-90x50.gif')]")
end
