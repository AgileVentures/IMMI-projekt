Given(/^the following users exists$/) do |table|
  table.hashes.each do |user|
    FactoryGirl.create(:user, email: user[:email])
  end
end

Given(/^I am logged in as "([^"]*)"$/) do |email|
  @user = User.find_by(email: email)
  login_as @user, scope: :user
end