When(/^I choose a file named "([^"]*)" to upload$/) do | filename |
  page.attach_file "uploaded_file[actual_files][]", File.join(Rails.root, 'spec', 'fixtures','uploaded_files', filename)
end

And(/^I should( not)? see "([^"]*)" uploaded for this membership application$/) do |negate, filename|
  expect(page).send (negate ? :not_to : :to), have_selector('.uploaded-file', text: filename)
end

And(/^I should see (\d+) uploaded files listed$/) do |number|
  expect(page).to have_selector('.uploaded-file', count: number)
end

When(/^I choose the files named \["([^"]*)", "([^"]*)", "([^"]*)"\] to upload$/) do |file1, file2, file3|
  files = [File.join(Rails.root, 'spec', 'fixtures','uploaded_files', file1),
           File.join(Rails.root, 'spec', 'fixtures','uploaded_files', file2),
           File.join(Rails.root, 'spec', 'fixtures','uploaded_files', file3)]
  page.attach_file "uploaded_file[actual_files][]", files
end

And(/^I click on trash icon for "([^"]*)"$/) do |filename|
  find(:xpath, "//tr[contains(.,'#{filename}')]/td/a[@class='action-delete']").click
end

Then(/^I should( not)? see the file delete action$/) do | negate |
  expect(page).send (negate ? :not_to : :to), have_xpath("//th[contains(., #{I18n.t('delete')})][@class='action']")
end