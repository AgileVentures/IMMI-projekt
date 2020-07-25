Feature: Admin edits user profile

  As an admin
  I want to be able to edit all of the user's profile information
  Including photo, name, emails, membership number, password, and all other info

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist
      | email                | password       | admin | member | first_name | last_name |
      | admin@shf.se         | admin_password | true  | false  | emma       | admin     |
      | member@shf.com       | password       | false | true   | mary       | member    |
      | lars-member2@shf.com | password       | false | true   | Lars       | Member2   |


  Scenario: Admin should see the current password field because the admin must enter the admin's current password to make changes
    Given I am logged in as "admin@shf.se"
    And I am on the "all users" page
    And I should see "member@shf.com"
    Then I click the icon with CSS class "edit" for the row with "member@shf.com"
    And I should see t("devise.registrations.edit.edit_profile_for_title", user: 'mary member')
    And I should see t("devise.registrations.edit.current_password")


  Scenario: Admin sees "Delete this account" instead of "Delete My Account" button since it isn't their account
    Given I am logged in as "admin@shf.se"
    And I am on the "all users" page
    And I should see "member@shf.com"
    Then I click the icon with CSS class "edit" for the row with "member@shf.com"
    And I should see t("devise.registrations.edit.edit_profile_for_title", user: 'mary member')
    And I should not see t("devise.registrations.edit.delete_your_account")
    And I should see t("admin_only.user_profile.edit.delete_this_user", user: "mary member")


  @selenium
  Scenario: Admin edits first and last names.
    Given I am logged in as "admin@shf.se"
    And I am on the "all users" page
    And I should see "member@shf.com"
    Then I click the icon with CSS class "edit" for the row with "member@shf.com"
    And I should see t("devise.registrations.edit.edit_profile_for_title", user: 'mary member')

    And I fill in t("activerecord.attributes.user.first_name") with "Mary"
    And I fill in t("activerecord.attributes.user.last_name") with "Member"

    And I fill in t("devise.registrations.edit.current_password") with "admin_password"
    Then I click on t("devise.registrations.edit.submit_button_label") button

    And I should see t("admin_only.user_profile.update.success")

    And I should see t("devise.registrations.edit.edit_profile_for_title", user: 'Mary Member')
    And the t("activerecord.attributes.user.first_name") field should be set to "Mary"
    And the t("activerecord.attributes.user.last_name") field should be set to "Member"


  Scenario: Admin edits user profile - cannot make names blank; sees error message.
    Given I am logged in as "admin@shf.se"
    And I am on the "all users" page
    And I should see "member@shf.com"
    Then I click the icon with CSS class "edit" for the row with "member@shf.com"
    And I should see t("devise.registrations.edit.edit_profile_for_title", user: 'mary member')

    And I fill in t("activerecord.attributes.user.last_name") with ""

    And I fill in t("devise.registrations.edit.current_password") with "admin_password"
    Then I click on t("devise.registrations.edit.submit_button_label") button
    And I should see t("admin_only.user_profile.update.error")


  Scenario: Admin edits login email for user.
    Given I am logged in as "admin@shf.se"
    And I am on the "all users" page
    And I should see "member@shf.com"
    Then I click the icon with CSS class "edit" for the row with "member@shf.com"
    And I should see t("devise.registrations.edit.edit_profile_for_title", user: 'mary member')


    And I fill in t("activerecord.attributes.user.email") with "mary@newmail.com"

    And I fill in t("devise.registrations.edit.current_password") with "admin_password"
    Then I click on t("devise.registrations.edit.submit_button_label") button

    And I should see t("admin_only.user_profile.update.success")

    And I should see t("devise.registrations.edit.edit_profile_for_title", user: 'Mary Member')
    And the t("activerecord.attributes.user.email") field should be set to "mary@newmail.com"


  Scenario: Admin edits password for user
    Given I am logged in as "admin@shf.se"
    And I am on the "all users" page
    And I should see "member@shf.com"
    Then I click the icon with CSS class "edit" for the row with "member@shf.com"
    And I should see t("devise.registrations.edit.edit_profile_for_title", user: 'mary member')

    And I fill in t("activerecord.attributes.user.password") with "newpassword"
    And I fill in t("activerecord.attributes.user.password_confirmation") with "newpassword"

    And I fill in t("devise.registrations.edit.current_password") with "admin_password"
    Then I click on t("devise.registrations.edit.submit_button_label") button

    And I should see t("admin_only.user_profile.update.success")

    And I should see t("devise.registrations.edit.edit_profile_for_title", user: 'Mary Member')

    # Mary member can log in with the new password
    When I am logged out
    And I am logged in as "member@shf.com"


  Scenario: Admin edits membership number for a user
    Given I am logged in as "admin@shf.se"
    And I am on the "all users" page
    And I should see "member@shf.com"
    Then I click the icon with CSS class "edit" for the row with "member@shf.com"
    And I should see t("devise.registrations.edit.edit_profile_for_title", user: 'mary member')

    And I fill in t("activerecord.attributes.user.membership_number") with "123"

    And I fill in t("devise.registrations.edit.current_password") with "admin_password"
    Then I click on t("devise.registrations.edit.submit_button_label") button

    And I should see t("admin_only.user_profile.update.success")

    And the t("activerecord.attributes.user.membership_number") field should be set to "123"


  Scenario: Admin uploads a photo for the user profile
    Given I am logged in as "admin@shf.se"
    And I am on the "all users" page
    And I should see "lars-member2@shf.com"

    When I click the icon with CSS class "fa-edit" for the row with "lars-member2@shf.com"
    Then I should see t("devise.registrations.edit.edit_profile_for_title", user: 'Lars Member2')

    When I choose a "user_member_photo" file named "member_with_dog.png" to upload

    And I fill in t("devise.registrations.edit.current_password") with "admin_password"
    And I click on t("devise.registrations.edit.submit_button_label") button

    Then I should see t("admin_only.user_profile.update.success")
    And I should see t("devise.registrations.edit.edit_profile_for_title", user: 'Lars Member2')
    And the profile picture filename is "member_with_dog.png" for "lars-member2@shf.com"
