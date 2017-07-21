Feature: As an admin
  So that I can see the details for a user
  Show me all of the details about a user

  PT:  https://www.pivotaltracker.com/story/show/140358959

  Background:

    Given the following users exists
      | first_name | email                   | admin |
      | Emma       | emma@personal.com       |       |
      | Lars       | lars@personal.com       |       |
      | Hannah     | hannah@personal.com     |       |
      | Nils       | nils@personal.se        |       |
      | Anna       | anna@personal.se        |       |
      | Sam        | sam@personal.se         |       |
      | admin      | admin@shf.se            | true  |
      | admin      | yesterday_admin@shf.se  | true  |
      | admin      | lazy_admin@shf.se       | true  |

    And the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    And the following companies exist:
      | name        | company_number | email               | region       |
      | Happy Mutts | 5560360793     | woof@happymutts.com | Stockholm    |
      | Bowsers     | 2120000142     | bark@bowsers.com    | Västerbotten |


    And the following applications exist:
      | user_email          | contact_email         | company_number | state    |
      | emma@personal.com   | emma@happymutts.com   | 5560360793     | accepted |
      | lars@personal.com   | lars@happymutts.com   | 5560360793     | accepted |
      | hannah@personal.com | hannah@happymutts.com | 5560360793     | accepted |
      | emma@personal.com   | emma@bowsers.com      | 2120000142     | new      |



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
    When I am on the "user details" page for "hannah@personal.com"
    Then I should not see t("users.show.is_an_admin")
    And I should see t("users.show.user_has_never_signed_in")
    And I should not see t("users.show.last_login")

  @member
  Scenario: Show a member that is currently logged in
    Given The user "emma@personal.com" is currently signed in
    When I am on the "user details" page for "emma@personal.com"
    Then I should not see t("users.show.is_an_admin")
    And I should not see t("users.show.user_has_never_signed_in")
    And I should see t("users.show.last_login")

  @member
  Scenario: Show a member that logged 3 days ago
    Given The user "lars@personal.com" last logged in 3 days ago
    When I am on the "user details" page for "lars@personal.com"
    Then I should not see t("users.show.is_an_admin")
    And I should not see t("users.show.user_has_never_signed_in")
    And I should see t("users.show.last_login")

  @member
  Scenario: Show a member that has logged in 42 times
    Given The user "lars@personal.com" has logged in 42 times
    When I am on the "user details" page for "lars@personal.com"
    Then I should see t("users.show.logged_in_count")
    And I should see "42"
    And I should see t("users.show.last_login")


  @member
  Scenario: Show a member that has had her password reset
    Given The user "emma@personal.com" has had her password reset now
    When I am on the "user details" page for "emma@personal.com"
    Then I should see t("users.show.reset_password_sent_at")

  @member
  Scenario: Show a member that has never had her password reset
    When I am on the "user details" page for "emma@personal.com"
    Then I should see t("users.show.password_never_reset")


  @user
  Scenario: Show an user who has never logged in
    When I am on the "user details" page for "nils@personal.se"
    Then I should not see t("users.show.is_an_admin")
    And I should see t("users.show.user_has_never_signed_in")
    And I should not see t("users.show.last_login")

  @user
  Scenario: Show an user that is currently logged in
    Given The user "anna@personal.se" is currently signed in
    When I am on the "user details" page for "anna@personal.se"
    Then I should not see t("users.show.is_an_admin")
    And I should not see t("users.show.user_has_never_signed_in")
    And I should see t("users.show.last_login")

  @user
  Scenario: Show an user that logged in 100 days ago
    Given The user "sam@personal.se" last logged in 100 days ago
    When I am on the "user details" page for "sam@personal.se"
    Then I should not see t("users.show.is_an_admin")
    And I should not see t("users.show.user_has_never_signed_in")
    And I should see t("users.show.last_login")

  @user
  Scenario: Show all emails and applications for a user
    When I am on the "user details" page for "emma@personal.com"
    Then I should see "emma@personal.com"
    And I should see "emma@happymutts.com"
    And I should see "emma@bowsers.com"
    And I should see "5560360793"
    And I should see "2120000142"
