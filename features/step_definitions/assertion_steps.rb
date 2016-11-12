Then(/^I should be on the landing page$/) do
  expect(current_path).to eq root_path
end

And(/^I should see "([^"]*)"$/) do |content|
  expect(page).to have_content content
end


Then(/^I should be on "([^"]*)" page$/) do |page|
  case page.downcase
    when 'edit my application'
      path = edit_membership_path(@user.membership_applications.last)
  end

  expect(current_path).to eq path
end


Then(/^I should see:$/) do |table|
  table.hashes.each do |hash|
    expect(page).to have_content hash[:content]
  end
end


Then(/^I should be on the application page for "([^"]*)"$/) do |company_name|
  membership = MembershipApplication.find_by(company_name: company_name)
  expect(current_path).to eq membership_path(membership)
end

Then(/^I should see "([^"]*)" applications$/) do |number|
  expect(page).to have_selector('.companies', count: number)
end
