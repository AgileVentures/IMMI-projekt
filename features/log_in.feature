Feature: As a registered user
  in order to access the functions of the site
  I need to be able to login

  Background:
    Given the following users exists
      | first_name | email                | password | admin | is_member |
      | Emma       | emma@random.com      | password | false | true      |
      | Lars       | lars-user@random.com | password | false | false     |
      | Anne       | anne@random.com      | password | false | false     |
      | Arne       | arne@random.com      | password | true  | true      |

    And the following applications exist:
      | user_email           | company_number | state    |
      | emma@random.com      | 5562252998     | accepted |
      | lars-user@random.com | 2120000142     | under_review |


  Scenario: Logging in
    Given I am on the "landing" page
    Then I should see t("devise.sessions.new.log_in")
    When I click on t("devise.sessions.new.log_in") link
    Then I should be on "login" page
    When I fill in t("activerecord.attributes.user.email") with "emma@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")

  Scenario: Not proper e-mail
    Given I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "emma@random"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.failure.invalid", authentication_keys: 'Email')

  Scenario: No input of email
    Given I am on the "login" page
    When I leave the t("activerecord.attributes.user.password") field empty
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.failure.invalid", authentication_keys: 'Email')

  Scenario: No input of password
    Given I am on the "login" page
    When I leave the t("activerecord.attributes.user.password") field empty
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.failure.invalid", authentication_keys: 'Email')

  Scenario: Not registered user
    Given I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "anna@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.failure.invalid", authentication_keys: 'Email')

  Scenario: Not accessing protected page
    Given I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "anna@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.failure.invalid", authentication_keys: 'Email')
    When I fail to visit the "applications index" page
    Then I should see t("errors.not_permitted")
    And I should be on "landing" page

  Scenario: Logging in as admin
    Given I am on the "landing" page
    Then I should see t("devise.sessions.new.log_in")
    When I click on t("devise.sessions.new.log_in") link
    Then I should be on "login" page
    When I fill in t("activerecord.attributes.user.email") with "arne@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")
    And I should see t("info.logged_in_as_admin")


  Scenario: Logging in as a member
    Given I am on the "landing" page
    Then I should see t("devise.sessions.new.log_in")
    When I click on t("devise.sessions.new.log_in") link
    Then I should be on "login" page
    When I fill in t("activerecord.attributes.user.email") with "emma@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    And I should be on "member instructions" page
    And I should not see t("info.logged_in_as_admin")


  Scenario: Logging in as a user
    Given I am on the "landing" page
    Then I should see t("devise.sessions.new.log_in")
    When I click on t("devise.sessions.new.log_in") link
    Then I should be on "login" page
    When I fill in t("activerecord.attributes.user.email") with "lars-user@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    And I should be on "user instructions" page
    And I should not see t("info.logged_in_as_admin")
