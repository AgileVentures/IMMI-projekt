Given(/^the following users exist(?:s|)$/) do |table|
  table.hashes.each do |user|

    is_member = user.delete('is_member')

    if user['admin'] == 'true'
      FactoryGirl.create(:user, user)
    else
      if is_member == 'true'
        FactoryGirl.create(:member_with_membership_app, user)
      else
        if ! user['company_number'].nil?
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


Given(/^The user "([^"]*)" is currently signed in$/) do |email|
  @user = User.find_by(email: email)
  @user.update(current_sign_in_at: Time.now)
end

Given(/^The user "([^"]*)" last logged in (\d+) days? ago$/) do |email, num_days|
  @user = User.find_by(email: email)
  @user.update(last_sign_in_at: (Time.now - 1.day * num_days.to_i))
end

Given(/^The user "([^"]*)" has logged in (\d+) times?$/) do |email, num_logins|
  @user = User.find_by(email: email)
  @user.update(last_sign_in_at: Time.now, sign_in_count: num_logins)
end

Given(/^The user "([^"]*)" has had her password reset now$/) do |email|
  @user = User.find_by(email: email)
  @user.update(reset_password_sent_at: Time.now)
end