Feature: As an admin
  In order to keep business categories correct and helpful to visitors and members
  I need to be able to delete any that aren't needed or valid

  PT:

  When a membership application is deleted, if it is the only application
  associated with a company, then delete the company too.

  Background:
    Given the following users exists
      | email            | admin |
      | emma@random.com  |       |
      | hans@bowsers.com |       |
      | nils@bowsers.com |       |
      | wils@woof.com    |       |
      | bob@bowsers.com  |       |
      | admin@shf.se     | true  |

    And the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |
      | Norrbotten   |

    And the following kommuns exist:
      | name      |
      | Alingsås  |
      | Bromölla  |
      | Laxå      |

    And the following companies exist:
      | name        | company_number | email               | region       | kommun   |
      | Happy Mutts | 2120000142     | woof@happymutts.com | Stockholm    | Alingsås |
      | Bowsers     | 5560360793     | bark@bowsers.com    | Stockholm    | Bromölla |
      | WOOF        | 5569467466     | woof@woof.com       | Västerbotten | Laxå     |


    And the following applications exist:
      | user_email       | company_number | state        |
      | emma@random.com  | 5560360793     | under_review |
      | hans@bowsers.com | 2120000142     | under_review |
      | nils@bowsers.com | 2120000142     | accepted     |
      | wils@woof.com    | 5569467466     | accepted     |


  Scenario: Admin should see the 'delete' button
    Given I am logged in as "admin@shf.se"
    And I am on the "application" page for "emma@random.com"
    Then I should not see t("errors.not_permitted")
    And I should see t("membership_applications.show.delete")


  Scenario: Member should not see the 'delete' button on their own application
    Given I am logged in as "emma@random.com"
    And I am on the "application" page for "emma@random.com"
    Then I should not see t("errors.not_permitted")
    And I should not see t("membership_applications.show.delete")

  Scenario: Visitor should not see the 'delete' button
    Given I am Logged out
    And I am on the "application" page for "emma@random.com"
    Then I should see t("errors.not_permitted")
    And I should not see t("membership_applications.show.delete")


  Scenario: Admin wants to delete a membership application
    Given I am logged in as "admin@shf.se"
    And I am on the "application" page for "emma@random.com"
    And I click on t("membership_applications.show.delete")
    Then I should see t("membership_applications.application_deleted")
    And I should not see "Emma"


  Scenario: Admin deletes a membership application; company should still exist (has another application assoc.)
    Given I am logged in as "admin@shf.se"
    And I am on the "application" page for "hans@bowsers.com"
    And I click on t("membership_applications.show.delete")
    Then I should see t("membership_applications.application_deleted")
    And I should not see "Hans"
    And I am on the "all companies" page
    And I should see "2120000142"

  @focus
  Scenario: Admin deletes the only membership application associated with a company. Company is deleted
    Given I am logged in as "admin@shf.se"
    And I am on the "all companies" page
    Then I should see "3" companies
    And I should see "WOOF"
    And I am on the "application" page for "wils@woof.com"
    And I click on t("membership_applications.show.delete")
    Then I should see t("membership_applications.application_deleted")
    And I should not see "Wils"
    When I am on the "all companies" page
    Then I should see "2" companies
    And I should not see "WOOF"
