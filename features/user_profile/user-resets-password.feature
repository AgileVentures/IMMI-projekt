Feature: As a user
  If I forget my password
  I need to be able to reset my password


  Background:

    Given the following users exists
      | email               |
      | emma@happymutts.com |

  @user
  Scenario: User resets password
    Given I am on the "login" page
    And I click on t("devise.registrations.new.forgot_password") link
    And I should see t("devise.passwords.new.title")
    And I fill in t("activerecord.attributes.user.email") with "emma@happymutts.com"
    And I click on t("devise.passwords.new.submit_button_label")
    Then I should see t("devise.passwords.send_instructions")
    Then "emma@happymutts.com" should receive an email
    And I open the email
    And I should see t("devise.mailer.reset_password_instructions.subject") in the email subject
    And I should see t("devise.mailer.reset_password_instructions.reset_requested") in the email body
    And I follow t("devise.mailer.reset_password_instructions.change_password") in the email
    Then I should see t("devise.passwords.edit.new_password")
    And I should see t("devise.passwords.edit.confirm_password")
    Then I fill in t("devise.passwords.edit.new_password") with "new_password"
    And I fill in t("devise.passwords.edit.confirm_password") with "new_password"
    And I click on t("devise.passwords.edit.submit_button_label")
    And I should see t("devise.passwords.updated")

  @user
  Scenario: User attempts password reset with unknown email address
    Given I am on the "login" page
    And I click on t("devise.registrations.new.forgot_password") link
    And I should see t("devise.passwords.new.title")
    And I fill in t("activerecord.attributes.user.email") with "nonesuch@gmail.com"
    And I click on t("devise.passwords.new.submit_button_label")
    Then I should see t("errors.messages.not_found")
    And "emma@happymutts.com" should receive no email
