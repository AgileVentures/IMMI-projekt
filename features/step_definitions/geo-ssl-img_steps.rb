# Then("I should see image {capture_string}") do |file_name|
# # Then("I should see image {string}") do |string|
#   expect(page).to have_xpath("//img[contains(@src,'#{file_name}')]")
# end

# Then("I should be on page {capture_string}") do |capture_string|
# # Then("I should be on page {string}") do |string|
#   pending # Write code here that turns the phrase above into concrete actions
# end
#
# Then("I click on the image with filename {capture_string}") do |capture_string|
# # Then("I click on the image with filename {string}") do |string|
#   pending # Write code here that turns the phrase above into concrete actions
# end





### below not working

# why is the test below not working when running member_pays_membership_fee.feature:85
Then "I should{negate} see {capture_string} image" do |negate, file_name|
  expect(page).send (negate ? :not_to : :to),  have_xpath("//
  img[contains(@src,'#{file_name}')]")
end

# Then(/^I should( not)? see image with filename "([^"]*)"$/) do |negate, file_name|
#   find(:xpath, "//a/img[contains(@src,'#{file_name}')]/..").click
#   expect(page).to have_xpath("//img[contains(@src,'#{file_name}')]")
# end
