Feature: As a non-swedish speaking potential member
  In order to understand the information
  the site must also offer at least English.

  This also makes tests less brittle because the wording will be able to
  change without affecting any code. (It will just change in the
  locale .yml files.)

  PT: https://www.pivotaltracker.com/story/show/133316647

  Background:
    Given the following users exists
      | email                |
      | emma@random.com      |


  Scenario: Devise new session view is translated
    Given I am on the "login" page
    Then I should see t("devise.sessions.new.title")
    And I should see t("activerecord.attributes.user.email")
    And I should see t("activerecord.attributes.user.password")
    And I should see t("devise.sessions.new.remember_me")
    And I should see button t("devise.sessions.new.submit_button_label")

  Scenario: Devise new password view is translated
    Given I am on the "new password" page
    Then I should see t("devise.passwords.new.title")
    And I should see t("activerecord.attributes.user.email")
    And I should see button t("devise.passwords.new.submit_button_label")

  Scenario: Devise new registration view is translated
    Given I am on the "register as a new user" page
    Then I should see t("devise.registrations.new.title")
    And I should see t("activerecord.attributes.user.email")
    And I should see t("activerecord.attributes.user.password")
    And I should see t("devise.registrations.new.confirm_password")
    And I should see button t("devise.registrations.new.submit_button_label")

  Scenario: Devise edit registration view is translated
    Given I am logged in as "emma@random.com"
    And I am on the "edit registration for a user" page
    Then I should see t("devise.registrations.edit.title")
    And I should see t("activerecord.attributes.user.password")
    And I should see t("activerecord.attributes.user.password")
    And I should see t("devise.registrations.edit.password_confirmation")
    And I should see t("devise.registrations.edit.current_password")
    And I should see t("devise.registrations.edit.leave_blank_if_no_change")
    And I should see t("devise.registrations.edit.required_to_save_changes")
    And I should see button t("devise.registrations.edit.delete_my_account")
    And I should see button t("devise.registrations.edit.submit_button_label")
