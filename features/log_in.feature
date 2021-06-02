Feature: Logging in and what page is shown after logging in successfully

  As a registered user
  in order to access the functions of the site
  I need to be able to login
  And after I log in I am shown the correct page


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists
    And the application file upload options exist

    Given the following users exist:
      | email                | password | admin | member |
      | emma@random.com      | password | false | true   |
      | lars-user@random.com | password | false | false  |
      | anne@random.com      | password | false | false  |
      | arne@random.com      | password | true  | true   |

    And the following applications exist:
      | user_email           | company_number | state        |
      | emma@random.com      | 5562252998     | accepted     |
      | lars-user@random.com | 2120000142     | under_review |

    And the following payments exist
      | user_email      | start_date | expire_date | payment_type | status | hips_id |
      | emma@random.com | 2020-02-02 | 2021-02-01  | member_fee   | betald | none    |

    And the date is set to "2020-06-20"
    And I am logged out

    # --------------------------------------------------------------------------


  Scenario: Logging in successfully shows the 'signed in' message
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
    Then I should be on the "login" page


  Scenario: No input of email
    Given I am on the "login" page
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.failure.invalid", authentication_keys: 'Email')
    Then I should be on the "login" page


  Scenario: No input of password
    Given I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "emma@random.com"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.failure.invalid", authentication_keys: 'Email')
    Then I should be on the "login" page


  Scenario: Not registered user
    Given I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "anna@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.failure.invalid", authentication_keys: 'Email')
    Then I should be on the "login" page

  Scenario: Not accessing protected page
    Given I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "anna@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.failure.invalid", authentication_keys: 'Email')
    When I fail to visit the "membership applications" page
    Then I should see a message telling me I am not allowed to see that page
    And I should see t("errors.try_login")
    And I should be on "login" page

  Scenario: Logging in as admin goes to the all memberships (= their landing page)
    Given I am on the "landing" page
    Then I should see t("devise.sessions.new.log_in")
    When I click on t("devise.sessions.new.log_in") link
    Then I should be on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "arne@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")
    And I should be on the "landing" page
    When I am on the "landing" page
    Then I should see t("shf_applications.index.title")


  Scenario: Logging in as a member goes to the member's account page
    Given I am on the "landing" page
    Then I should see t("devise.sessions.new.log_in")
    When I click on t("devise.sessions.new.log_in") link
    Then I should be on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "emma@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should be on the "user account" page for "emma@random.com"
    And I should not see t("info.logged_in_as_admin")


  Scenario: Logging in as a user goes to the user's account page
    Given I am on the "landing" page
    Then I should see t("devise.sessions.new.log_in")
    When I click on t("devise.sessions.new.log_in") link
    Then I should be on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "lars-user@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    And I should be on "user account" page for "lars-user@random.com"
    And I should not see t("info.logged_in_as_admin")
