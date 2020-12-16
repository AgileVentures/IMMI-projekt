Feature: Admin can delete membership appications

  As an Admin
  So that I can get rid of old, accidental, or spam/bot membership applications
  I need to be able to delete shf membership applications


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
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

    And the following payments exist
      | user_email    | start_date | expire_date | payment_type | status | hips_id | company_number |
      | wils@woof.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5569467466     |


    And the following applications exist:
      | user_email       | company_number | state        |
      | emma@random.com  | 5560360793     | under_review |
      | hans@bowsers.com | 2120000142     | under_review |
      | nils@bowsers.com | 2120000142     | accepted     |
      | wils@woof.com    | 5569467466     | accepted     |


  Scenario: Admin should see the 'delete' button
    Given I am logged in as "admin@shf.se"
    And I am on the "application" page for "emma@random.com"
    Then I should not see a message telling me I am not allowed to see that page
    And I should see t("shf_applications.show.delete")


  Scenario: Member should not see the 'delete' button on their own application
    Given I am logged in as "emma@random.com"
    And I am on the "application" page for "emma@random.com"
    Then I should not see a message telling me I am not allowed to see that page
    And I should not see t("shf_applications.show.delete")

  Scenario: Visitor should not see the 'delete' button
    Given I am Logged out
    And I am on the "application" page for "emma@random.com"
    Then I should see a message telling me I am not allowed to see that page
    And I should not see t("shf_applications.show.delete")


  Scenario: Admin wants to delete a membership application
    Given I am logged in as "admin@shf.se"
    And I am on the "application" page for "emma@random.com"
    And I click on t("shf_applications.show.delete")
    Then I should see t("shf_applications.application_deleted")
    And I should not see "Emma"


  Rule:  When a membership application is deleted, if it is the only application
     associated with a company, then delete the company too.

    Scenario: Admin deletes a membership application; company should still exist (has another application assoc.)
      Given I am logged in as "admin@shf.se"
      And I am on the "application" page for "hans@bowsers.com"
      And I click on t("shf_applications.show.delete")
      Then I should see t("shf_applications.application_deleted")
      And I should not see "Hans"
      And I am on the "all companies" page
      And I should see "2120000142"

    @time_adjust
    Scenario: Admin deletes the only membership application associated with a company. Company is deleted
      Given the date is set to "2017-10-01"
      Given I am logged in as "admin@shf.se"
      And I am on the "all companies" page
      Then I should see "3" companies
      And I should see "WOOF"
      And I am on the "application" page for "wils@woof.com"
      And I click on t("shf_applications.show.delete")
      Then I should see t("shf_applications.application_deleted")
      And I should not see "Wils"
      When I am on the "all companies" page
      Then I should see "2" companies
