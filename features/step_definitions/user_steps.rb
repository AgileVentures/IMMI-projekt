# Steps for creating and working with users

def user_agrees_to_membership_guidelines(user)
  begin
    user_guidelines = if (found_guidelines = UserChecklistManager.membership_guidelines_list_for(user))
                        found_guidelines
                      else
                        AdminOnly::UserChecklistFactory.create_member_guidelines_checklist_for(user) unless UserChecklistManager.membership_guidelines_list_for(user)
                      end
    user_guidelines.set_complete_including_children

  rescue => e
    raise e, "Could not create the Member Guidelines UserChecklist or set it to completed for user #{user}\n #{e.inspect} "
  end
end


# This should match any of the following
#  the following users exist
#  the following users exist:
Given(/^the following users exist(?:[:])?$/) do |table|

  # Hash value "is_legacy" indicates a user account that was created before we
  # migrated the user's name attributes (first_name, last_name) from the
  # ShfApplication model to the User model.
  # If a "legacy" user, we create the user with nil values for those attributes.

  table.hashes.each do |user|

    user['membership_number'] = nil if user['membership_number'].blank?

    is_legacy = user.delete('is_legacy')

    user.delete('last_name') if user['last_name'].blank?
    user.delete('first_name') if user['first_name'].blank?
    user['sign_in_count'] = 0 if user['sign_in_count'].blank?

    user_agreed_to_membership_guidelines = user['agreed_to_membership_guidelines'].blank? ? false : user['agreed_to_membership_guidelines']
    user.delete('agreed_to_membership_guidelines') # this is not an attribute of User so we need to remove it

    new_user = (is_legacy == 'true' ? FactoryBot.create(:user_without_first_and_lastname, user) : FactoryBot.create(:user, user))

    AdminOnly::UserChecklistFactory.create_member_guidelines_checklist_for(new_user)
    user_agrees_to_membership_guidelines(new_user) if user_agreed_to_membership_guidelines
    new_user
  end
end


And("the following users have agreed to the Membership Ethical Guidelines:") do |table|
  table.hashes.each do |item|
    user_email = item.delete('email') || ''
    user = User.find_by(email: user_email)
    user_agrees_to_membership_guidelines(user)
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

When(/^I choose an application configuration "([^"]*)" file named "([^"]*)" to upload$/) do | fieldname, filename |
  page.attach_file(fieldname,
                   File.join(Rails.root, 'spec', 'fixtures',
                             'app_configuration', filename), visible: false)
  # ^^ selenium won't find the upload button without visible: false
end


Then("the user is paid through {capture_string}") do | expected_expire_date_str |
  expect(@user.membership_expire_date.to_s).to eq expected_expire_date_str
end


Then("user {capture_string} is paid through {capture_string}") do | user_email, expected_expire_datestr |
  user = User.find_by(email: user_email)
  expect_user_has_expire_date(user, expected_expire_datestr)
end

Then("user {capture_string} has no completed payments") do | user_email |
  user = User.find_by(email: user_email)
  expect(user.payments.completed).to be_empty
  #expect_user_has_expire_date(user, '')
end

def expect_user_has_expire_date(user, expected_expire_date_str)
  user.reload  # ensure the the object has the latest info from the db
  expect(user.membership_expire_date.to_s).to eq expected_expire_date_str
end


Then("I should{negate} see membership status is {capture_string}") do | negate, membership_status |

  status_xpath = "//div[contains(@class,'status')]/span[contains(@class,'value')]"
  expect(page).send (negate ? :not_to : :to), have_xpath(status_xpath)

  actual_status_element = page.find(:xpath, status_xpath)
  expect(actual_status_element).to have_text(membership_status)
end


And("my profile picture filename is {capture_string}") do | filename |
  @user.reload # ensure we have the latest from the db
  expect(@user.member_photo.original_filename).to eq(filename), "The profile picture filename was expected to be '#{filename}' but instead is '#{@user.member_photo.original_filename}'"
end


And("the profile picture filename is {capture_string} for {capture_string}") do | filename, user_email |
  user = User.find_by_email(user_email)
  expect(user).not_to be_nil, "The user #{user_email} could not be found."
  expect(user.member_photo.original_filename).to eq(filename), "The profile picture filename was expected to be '#{filename}' but instead is '#{user.member_photo.original_filename}'"
end
