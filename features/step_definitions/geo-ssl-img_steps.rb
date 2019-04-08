Then "I should{negate} see image with filename {capture_string}" do |negate, file_name|
  expect(page).send (negate ? :not_to : :to),  have_xpath("//
  img[contains(@src,'#{file_name}')]")
end

Then "I click on the image with filename {capture_string}" do |file_name|
  find(:xpath, "//a/img[contains(@src,'#{file_name}')]").click
  #expect(page).to have_xpath("//img[contains(@src,'#{file_name}')]")
end

Then("I should be on external page {capture_string}") do |url|
  visit url
end
