Feature: As an admin
  So that I can see the details for a user
  Show me all of the details about a user

  PT:  https://www.pivotaltracker.com/story/show/140358959

  Background:

    Given the following users exists
      | email                  | admin |
      | emma@happymutts.com    |       |
      | lars@happymutts.com    |       |
      | hannah@happymutts.com  |       |
      | nils@bowsers.se        |       |
      | anna@bowsers.se        |       |
      | sam@bowsers.se         |       |
      | admin@shf.se           | true  |
      | yesterday_admin@shf.se | true  |
      | lazy_admin@shf.se      | true  |


    And the following companies exist:
      | Happy Mutts | 5560360793 | woof@happymutts.com | Stockholm |


    And the following applications exist:
      | first_name | user_email            | company_number | state    |
      | Emma       | emma@happymutts.com   | 5560360793     | accepted |
      | Lars       | lars@happymutts.com   | 5560360793     | accepted |
      | Hannah     | hannah@happymutts.com | 5560360793     | accepted |



    And I am logged in as "admin@shf.se"


  @admin
  Scenario: Show an admin who has never logged in
    When I am on the "user details" page for "lazy_admin@shf.se"
    Then I should see t("users.show.is_an_admin")
    And I should see t("users.show.user_has_never_signed_in")
    And I should not see t("users.show.last_login")


  @admin
  Scenario: Show an admin that is currently logged in
    When I am on the "user details" page for "admin@shf.se"
    Then I should see t("users.show.is_an_admin")
    And I should not see t("users.show.user_has_never_signed_in")
    And I should see t("users.show.last_login")

  @admin
  Scenario: Show an admin that logged in 1 day ago
    Given The user "yesterday_admin@shf.se" last logged in 1 day ago
    When I am on the "user details" page for "yesterday_admin@shf.se"
    Then I should see t("users.show.is_an_admin")
    And I should not see t("users.show.user_has_never_signed_in")
    And I should see t("users.show.last_login")


  @member
  Scenario: Show a member who has never logged in
    When I am on the "user details" page for "hannah@happymutts.com"
    Then I should not see t("users.show.is_an_admin")
    And I should see t("users.show.user_has_never_signed_in")
    And I should not see t("users.show.last_login")

  @member
  Scenario: Show a member that is currently logged in
    Given The user "emma@happymutts.com" is currently signed in
    When I am on the "user details" page for "emma@happymutts.com"
    Then I should not see t("users.show.is_an_admin")
    And I should not see t("users.show.user_has_never_signed_in")
    And I should see t("users.show.last_login")

  @member
  Scenario: Show a member that logged 3 days ago
    Given The user "lars@happymutts.com" last logged in 3 days ago
    When I am on the "user details" page for "lars@happymutts.com"
    Then I should not see t("users.show.is_an_admin")
    And I should not see t("users.show.user_has_never_signed_in")
    And I should see t("users.show.last_login")

  @member
  Scenario: Show a member that has logged in 42 times
    Given The user "lars@happymutts.com" has logged in 42 times
    When I am on the "user details" page for "lars@happymutts.com"
    Then I should see t("users.show.logged_in_count")
    And I should see "42"
    And I should see t("users.show.last_login")


  @member
  Scenario: Show a member that has had her password reset
    Given The user "emma@happymutts.com" has had her password reset now
    When I am on the "user details" page for "emma@happymutts.com"
    Then I should see t("users.show.reset_password_sent_at")

  @member
  Scenario: Show a member that has never had her password reset
    When I am on the "user details" page for "emma@happymutts.com"
    Then I should see t("users.show.password_never_reset")


  @user
  Scenario: Show an user who has never logged in
    When I am on the "user details" page for "nils@bowsers.se"
    Then I should not see t("users.show.is_an_admin")
    And I should see t("users.show.user_has_never_signed_in")
    And I should not see t("users.show.last_login")

  @user
  Scenario: Show an user that is currently logged in
    Given The user "anna@bowsers.se" is currently signed in
    When I am on the "user details" page for "anna@bowsers.se"
    Then I should not see t("users.show.is_an_admin")
    And I should not see t("users.show.user_has_never_signed_in")
    And I should see t("users.show.last_login")

  @user
  Scenario: Show an user that logged in 100 days ago
    Given The user "sam@bowsers.se" last logged in 100 days ago
    When I am on the "user details" page for "sam@bowsers.se"
    Then I should not see t("users.show.is_an_admin")
    And I should not see t("users.show.user_has_never_signed_in")
    And I should see t("users.show.last_login")
