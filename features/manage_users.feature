Feature: As an admin
  In order to understand and manage our user base
  I need to be able to view and make changes to user records

  Background:
    Given the following users exist
      | email               | admin | member |
      | emma@happymutts.com |       |        |
      | anna@sadmutts.com   |       | true   |
      | ernt@mutts.com      |       |        |
      | admin@shf.se        | true  |        |
      | david@dogs.com      |       |        |

    Given the following payments exist
      | user_email        | start_date | expire_date | payment_type | status | hips_id |
      | anna@sadmutts.com | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |

    And the following applications exist:
      | user_email          | company_number | categories   | state    |
      | emma@happymutts.com | 5562252998     | Trainer      | accepted |
      | anna@sadmutts.com   | 2120000142     | Psychologist | accepted |
      | ernt@mutts.com      | 2120000142     | Psychologist | new      |

  Scenario: Admin can view all users
    Given I am logged in as "admin@shf.se"
    When I am on the "all users" page
    And I should see "admin@shf.se"
    And I should see "emma@happymutts.com"
    And I should see "anna@sadmutts.com"
    And I should see "ernt@mutts.com"

  @time_adjust
  Scenario: The right info is displayed for a user
    Given the date is set to "2017-12-01"
    And The user "emma@happymutts.com" was created 3 days ago
    And I am logged in as "admin@shf.se"
    When I am on the "all users" page
    Then I should see "emma@happymutts.com"
    And I should see "3 dagar sedan" for class "created-at" in the row for user "emma@happymutts.com"
    And I should see "1" for class "sign-in-count" in the row for user "emma@happymutts.com"
    And I should see "0" for class "applications-open" in the row for user "emma@happymutts.com"
    And I should see t("no") for class "is-member" in the row for user "emma@happymutts.com"
    And I should see "0" for class "sign-in-count" in the row for user "david@dogs.com"
    And I should see "0" for class "applications-open" in the row for user "david@dogs.com"
    And I should see t("no") for class "is-member" in the row for user "david@dogs.com"
    And I should see "0" for class "sign-in-count" in the row for user "ernt@mutts.com"
    And I should see "1" for class "applications-open" in the row for user "ernt@mutts.com"
    And I should see t("no") for class "is-member" in the row for user "ernt@mutts.com"
    And I should see "0" for class "sign-in-count" in the row for user "anna@sadmutts.com"
    And I should see "0" for class "applications-open" in the row for user "anna@sadmutts.com"
    And I should see t("yes") for class "is-member" in the row for user "anna@sadmutts.com"
    And I should see "2017-12-31" for class "expire_date" in the row for user "anna@sadmutts.com"

  Scenario: Member cannot view all users
    Given I am logged in as "anna@sadmutts.com"
    When I am on the "all users" page
    And I should see t("errors.not_permitted")

  Scenario: User (non-member) cannot view all users
    Given I am logged in as "ernt@mutts.com"
    When I am on the "all users" page
    And I should see t("errors.not_permitted")

  Scenario: Visitor cannot view all users
    Given I am Logged out
    When I am on the "all users" page
    And I should see t("errors.not_permitted")
