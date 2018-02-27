Given(/^the following users exist(?:s|)$/) do |table|
  table.hashes.each do |user|

    user['membership_number'] = nil if user['membership_number'].blank?

    is_legacy = user.delete('is_legacy')

    is_legacy == 'true' ? FactoryBot.create(:user_without_first_and_lastname, user) : FactoryBot.create(:user, user)

  end
end

Given(/^I am logged in as "([^"]*)"$/) do |email|
  @user = User.find_by(email: email)
  login_as @user, scope: :user
end

Given(/^I am [L|l]ogged out$/) do
  logout
end


Given(/^The user "([^"]*)" is currently signed in$/) do |email|
  @user = User.find_by(email: email)
  @user.update(current_sign_in_at: Time.zone.now)
end

Given(/^The user "([^"]*)" last logged in (\d+) days? ago$/) do |email, num_days|
  @user = User.find_by(email: email)
  @user.update(last_sign_in_at: (Time.zone.now - 1.day * num_days.to_i))
  @user.update(sign_in_count: (@user.sign_in_count + 1))
end

Given(/^The user "([^"]*)" was created (\d+) days? ago$/) do |email, num_days|
  @user = User.find_by(email: email)
  @user.update(created_at: (Time.zone.now - 1.day * num_days.to_i))
  @user.update(sign_in_count: (@user.sign_in_count + 1))
end

Given(/^The user "([^"]*)" has logged in (\d+) times?$/) do |email, num_logins|
  @user = User.find_by(email: email)
  @user.update(last_sign_in_at: Time.zone.now, sign_in_count: num_logins)
end

Given(/^The user "([^"]*)" has had her password reset now$/) do |email|
  @user = User.find_by(email: email)
  @user.update(reset_password_sent_at: Time.zone.now)
end

When(/^I choose a "([^"]*)" file named "([^"]*)" to upload$/) do | fieldname, filename |
  page.attach_file(fieldname,
                   File.join(Rails.root, 'spec', 'fixtures',
                             'member_photos', filename), visible: false)
  # ^^ selenium won't find the upload button without visible: false
end

When(/^I choose an SHF "([^"]*)" file named "([^"]*)" to upload$/) do | fieldname, filename |
  page.attach_file(fieldname,
                   File.join(Rails.root, 'spec', 'fixtures',
                             'app_configuration', filename), visible: false)
  # ^^ selenium won't find the upload button without visible: false
end
