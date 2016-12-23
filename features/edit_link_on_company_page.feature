Feature: As the owner of a company (or an admin)
  As I am on the company
  I should easily be able to edit it

  Background:

    Given the following users exists
      | email                 | admin | is_member | company_number |
      | emma@happymutts.com   |       | true      | 5562252998     |
      | lars@happymutts.com   |       | true      | 5562252998     |
      | anna@happymutts.com   |       | true      | 5562252998     |
      | bowser@snarkybarky.se |       | true      | 2120000142     |
      | admin@shf.se          | true  | false     |                |

    And the following applications exist:
      | first_name | user_email            | company_number | status  |
      | Emma       | emma@happymutts.com   | 5562252998     | Godkänd |
      | Lars       | lars@happymutts.com   | 5562252998     | Godkänd |
      | Anna       | anna@happymutts.com   | 5562252998     | Godkänd |
      | Bowser     | bowser@snarkybarky.se | 2120000142     | Godkänd |


  Scenario: Visitor does not see edit link for a company
    Given I am Logged out
    And I am the page for company number "5562252998"
    Then I should see t("companies.show.email")
    And I should not see t("companies.edit_company")

  Scenario: Admin does see edit link for company
    Given I am logged in as "admin@shf.se"
    And I am the page for company number "5562252998"
    Then I should see t("companies.show.email")
    And I should see t("companies.edit_company")

  Scenario: Other user does not see edit link for a company
    Given I am logged in as "bowser@snarkybarky.se"
    And I am the page for company number "5562252998"
    Then I should see t("companies.show.email")
    And I should not see t("companies.edit_company")

  Scenario: User related to company does see edit link for company
    Given I am logged in as "emma@happymutts.com"
    And I am the page for company number "5562252998"
    Then I should see t("companies.show.email")
    And I should see t("companies.edit_company")
