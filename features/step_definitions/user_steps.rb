Given(/^the following users exists$/) do |table|
  table.hashes.each do |user|

    if user.has_key?('admin') && user['admin'] == 'true'
      FactoryGirl.create(:user, user)
    else

      if user.has_key?('is_member') && user['is_member'] == 'true'
        FactoryGirl.create(:member_with_membership_app, user)
      else
        if user.has_key?('company_number') && !(user['company_number'].nil?)
          FactoryGirl.create(:user_with_membership_app, user, company_number: user['company_number'])
        else
          FactoryGirl.create(:user, user)
        end

      end
    end
  end
end

Given(/^I am logged in as "([^"]*)"$/) do |email|
  @user = User.find_by(email: email)
  login_as @user, scope: :user
end

Given(/^I am Logged out$/) do
  logout
end