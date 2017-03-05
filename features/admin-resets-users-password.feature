Feature: As an admin
  So that I can help users that forgot their password (who can't reset it themselves via email)
  I need to be able to reset passwords for users


  Background:

    Given the following users exists
      | email               | admin |
      | emma@happymutts.com |       |
      | bob@snarkybarky.se  |       |
      | admin@shf.se        | true  |

    And the following companies exist:
      | name        | company_number | email               |
      | Happy Mutts | 2120000142     | bowwow@bowsersy.com |

    And the following applications exist:
      | first_name | user_email          | company_number | state    |
      | Emma       | emma@happymutts.com | 2120000142     | accepted |


    And I am logged in as "admin@shf.se"

  @poltergeist @member
  Scenario: A member needs their password reset
    Given I am on the "user details" page for "emma@happymutts.com"
    Then I should not see t("users.show.new_password")
    And I should not see t("users.show.re_enter_new_password")
    And I should not see t("users.show.submit_new_password")
    And I should not see t("users.show.submit_new_password")
    When I click on t("toggle.set_new_password_form.show") button
    Then I should see t("users.show.new_password")
    And I should see t("users.show.re_enter_new_password")
    When I fill in t("users.show.new_password") with "newpassword"
    And I fill in t("users.show.re_enter_new_password") with "newpassword"
    And I should see t("users.show.please_note_new_password")
    And I click on t("users.show.submit_new_password") button
    #And I confirm popup
    Then I should see t("users.update.success")
    And I am Logged out
    And I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "emma@happymutts.com"
    And I fill in t("activerecord.attributes.user.password") with "newpassword"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")


  @poltergeist @user
  Scenario: A user needs their password reset
    Given I am on the "user details" page for "bob@snarkybarky.se"
    Then I should not see t("users.show.new_password")
    And I should not see t("users.show.re_enter_new_password")
    And I should not see t("users.show.submit_new_password")
    And I should not see t("users.show.submit_new_password")
    When I click on t("toggle.set_new_password_form.show") button
    Then I should see t("users.show.new_password")
    And I should see t("users.show.re_enter_new_password")
    When I fill in t("users.show.new_password") with "snarkywoofwoof"
    And I fill in t("users.show.re_enter_new_password") with "snarkywoofwoof"
    And I should see t("users.show.please_note_new_password")
    And I click on t("users.show.submit_new_password") button
    # And I confirm popup with message t("users.show.confirm_reset_password")
    Then I should see t("users.update.success")
    And I am Logged out
    And I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "bob@snarkybarky.se"
    And I fill in t("activerecord.attributes.user.password") with "snarkywoofwoof"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")


  @poltergeist @user
  Scenario: New password and confirmation don't match (sad path)
    Given I am on the "user details" page for "bob@snarkybarky.se"
    When I click on t("toggle.set_new_password_form.show") button
    Then I should see t("users.show.new_password")
    When I fill in t("users.show.new_password") with "snarkywoofwoof"
    And I fill in t("users.show.re_enter_new_password") with "not-a-match"
    And I should see t("users.show.please_note_new_password")
    And I click on t("users.show.submit_new_password") button
    And I confirm popup with message t("users.show.confirm_reset_password")
    Then I should see t("users.update.error")
    And I should see t("users.update.passwords_dont_match")
