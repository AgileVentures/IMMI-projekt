Given(/^I am on the "([^"]*)" page$/) do |page|
  case page.downcase
    when 'landing'
      path = root_path
    when 'login'
      path = new_user_session_path
    when 'edit my application'
      user = User.find_by_email @user.email if @user
      path = edit_membership_application_path(user.membership_applications.last)
    when 'business categories'
      path = business_categories_path
    when 'membership applications'
      path = membership_applications_path
    when 'all companies'
      path = companies_path
    when 'create a new company'
      path = new_company_path
    when 'submit new membership application'
      path = new_membership_application_path
    when 'edit my company'
      if @user
        user = User.find_by_email @user.email
        if user.membership_applications.last &&
            user.membership_applications.last.company
          path = edit_company_path(user.membership_applications.last.company)
        end
      end
    when 'user instructions'
      path = information_path
    when 'member instructions'
      path = information_path
    when 'new password'
      path = new_user_password_path
    when 'register as a new user'
      path = new_user_registration_path
    when 'edit registration for a user'
      path = edit_user_registration_path
    when 'all users'
      path = users_path
    else
      path = 'no path set'
  end
  visit path_with_locale(path)
end


And(/^I am on the "([^"]*)" page for "([^"]*)"$/) do |page, user_email|
  user_from_email = User.find_by_email user_email

  case page.downcase
    when 'landing'
      path = root_path
    when 'login'
      path = new_user_session_path
    when 'edit my application'
      if user_from_email
        path = edit_membership_application_path(user_from_email.membership_applications.last)
      end
    when 'business categories'
      path = business_categories_path
    when 'all companies'
      path = companies_path
    when 'create a new company'
      path = new_company_path
    when 'submit new membership application'
      path = new_membership_application_path
    when 'edit my company'
      if user_from_email
        if user_from_email.membership_applications.last &&
            user_from_email.membership_applications.last.company
          path = edit_company_path(user_from_email.membership_applications.last.company)
        end
      end
    when 'user instructions'
      path = information_path
    when 'application' || 'show application'
      path = membership_application_path(user_from_email.membership_applications.last)
    when 'member instructions'
      path = information_path
    when 'user details'
      path = user_path(user_from_email)
    else
      path = 'no path set'
  end
  visit path_with_locale(path)

end

When(/^I fail to visit the "([^"]*)" page$/) do |page|
  case page.downcase
    when 'applications index'
      path = membership_applications_path
    else
      path = 'path not set'
  end
  visit path_with_locale(path)
  expect(current_path).not_to be path
end


When(/^I am on the application page for "([^"]*)"$/) do |first_name|
    membership_application = MembershipApplication.find_by(first_name: first_name)
    visit path_with_locale(membership_application_path(membership_application))
end


And(/^I am on the static workgroups page$/) do
  visit page_path('yrkesrad')
end
