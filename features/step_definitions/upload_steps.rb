When(/^I choose (?:a file|files) named "([^"]*)" to upload for the application$/) do | filename |
  filenames = filename.split(/\s*,\s*/)
  filepaths = []
  filenames.each do |file|
    filepaths << File.join(Rails.root, 'spec', 'fixtures','uploaded_files', file)
  end
  page.attach_file "uploaded_file[actual_files][]", filepaths, visible: false
  # ^^ selenium won't find the upload button without visible: false
end

When(/^I choose a file named "([^"]*)" to upload$/) do | filename |
  filepath = File.join(Rails.root, 'spec', 'fixtures','uploaded_files', filename)

  page.attach_file "upload-button", filepath, visible: false
  # ^^ selenium won't find the upload button without visible: false
end

And(/^I should( not)? see "([^"]*)" uploaded for this membership application$/) do |negate, filename|
  expect(page).send (negate ? :not_to : :to), have_selector('.uploaded-file', text: filename)
end

And(/^I should see (\d+) uploaded files listed$/) do |number|
  expect(page).to have_selector('.uploaded-file', count: number)
end

# When(/^I choose the files named \["([^"]*)", "([^"]*)", "([^"]*)"\] to upload$/) do |file1, file2, file3|
#   files = [File.join(Rails.root, 'spec', 'fixtures','uploaded_files', file1),
#            File.join(Rails.root, 'spec', 'fixtures','uploaded_files', file2),
#            File.join(Rails.root, 'spec', 'fixtures','uploaded_files', file3)]
#   page.attach_file "uploaded_file[actual_files][]", files, visible: false  #selenium won't find the upload button without visible: false
# end

And(/^I click on trash icon for "([^"]*)"$/) do |text|
  delete_link = find(:xpath, "//tr[contains(.,'#{text}')]/td/a[@class='action-delete']")
  page.driver.accept_modal(:confirm, wait: 4) do
    delete_link.click
  end
end

And("I click on the delete icon for {capture_string}") do |text|
  step "I click on trash icon for \"#{text}\""
end

Then(/^I should( not)? see the file delete action$/) do | negate |
  expect(page).send (negate ? :not_to : :to), have_xpath("//th[contains(., #{I18n.t('delete')})][@class='action']")
end

When "I delete the{optional_string} uploaded file" do |ordinal|
  index = ordinal ? [0, 1, 2, 3, 4].send(ordinal.lstrip) : 0

  page.driver.accept_modal(:confirm, wait: 4) do
    all("a[class='action-delete']")[index].click
  end
end

