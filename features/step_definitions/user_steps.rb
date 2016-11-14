Given(/^the following users exists$/) do |table|
  table.hashes.each do |user|
    FactoryGirl.create(:user, user)
  end
end

Given(/^I am logged in as "([^"]*)"$/) do |email|
  @user = User.find_by(email: email)
  login_as @user, scope: :user
end

Given(/^I am Logged out$/) do
  logout
end