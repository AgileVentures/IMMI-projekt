Feature: As an admin
  So that I can help users that forgot their password (who can't reset it themselves via email)
  I need to be able to reset passwords for users


  Background:

    Given the following users exists
      | first_name | email               | admin |
      | Emma       | emma@happymutts.com |       |
      | Bob        | bob@snarkybarky.se  |       |
      | admin      | admin@shf.se        | true  |

    And the following companies exist:
      | name        | company_number | email               |
      | Happy Mutts | 2120000142     | bowwow@bowsersy.com |

    And the following applications exist:
      | user_email          | company_number | state    |
      | emma@happymutts.com | 2120000142     | accepted |

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
    Then I should see flash text t("users.update.success")



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
    #And I confirm popup
    Then I should see flash text t("users.update.success")
    And I should see t("users.update.success")



  @poltergeist @user
  Scenario: New password and confirmation don't match [SAD PATH]
    Given I am on the "user details" page for "bob@snarkybarky.se"
    When I click on t("toggle.set_new_password_form.show") button
    Then I should see t("users.show.new_password")
    When I fill in t("users.show.new_password") with "snarkywoofwoof"
    And I fill in t("users.show.re_enter_new_password") with "not-a-match"
    And I should see t("users.show.please_note_new_password")
    And I click on t("users.show.submit_new_password") button
    #And I confirm popup
    Then I should see t("users.update.error")
    And I should see t("activerecord.errors.models.user.attributes.password_confirmation.confirmation")


  @poltergeist @user
  Scenario: New password is too short (not valid) [SAD PATH]
    Given I am on the "user details" page for "bob@snarkybarky.se"
    When I click on t("toggle.set_new_password_form.show") button
    Then I should see t("users.show.new_password")
    When I fill in t("users.show.new_password") with "woof"
    And I fill in t("users.show.re_enter_new_password") with "woof"
    And I should see t("users.show.please_note_new_password")
    And I click on t("users.show.submit_new_password") button
    #And I confirm popup
    Then I should see t("users.update.error")
    And I should see t("errors.messages.too_short", count: 6)
    And I should not see t("activerecord.errors.models.user.attributes.password_confirmation.confirmation")


  @poltergeist @user
  Scenario: New password and confirmation don't match AND new one is too short [SAD PATH]
    Given I am on the "user details" page for "bob@snarkybarky.se"
    When I click on t("toggle.set_new_password_form.show") button
    Then I should see t("users.show.new_password")
    When I fill in t("users.show.new_password") with "woof"
    And I fill in t("users.show.re_enter_new_password") with "nomatch"
    And I should see t("users.show.please_note_new_password")
    And I click on t("users.show.submit_new_password") button
    #And I confirm popup
    Then I should see t("users.update.error")
    And I should see t("activerecord.errors.models.user.attributes.password_confirmation.confirmation")
    And I should see t("errors.messages.too_short", count: 6)
