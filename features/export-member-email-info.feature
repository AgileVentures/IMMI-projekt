Feature: Admin export member information to a CSV file

  As an Admin
  So that I can use the member information in other systems (Mailchimp, postal mail),
  I need to be able to export member information (names, email, addresses) to a CSV file


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | last_name   | email                       | admin |
      | Emmasdottir | emma@happymutts.com         |       |
      | Wilson      | wils@woof.com               |       |
      | admin       | admin@shf.se                | true  |


    And the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |
      | Norrbotten   |


    And the following companies exist:
      | name                 | company_number | email                 | region       |
      | Happy Mutts          | 2120000142     | woof@happymutts.com   | Stockholm    |
      | WOOF                 | 5569467466     | woof@woof.com         | Västerbotten |

    And the following applications exist:
      | user_email          | company_number | state    |
      | emma@happymutts.com | 2120000142     | accepted |
      | wils@woof.com       | 5569467466     | new      |



  Scenario: Visitor can't export
    Given I am Logged out
    When I am on the "membership applications" page
    Then I should see a message telling me I am not allowed to see that page


  Scenario: User can't export
    Given I am logged in as "wils@woof.com"
    When I am on the "membership applications" page
    Then I should see a message telling me I am not allowed to see that page


  Scenario: Member can't export
    Given I am logged in as "emma@happymutts.com"
    When I am on the "membership applications" page
    Then I should see a message telling me I am not allowed to see that page

  Scenario: Admin can export
    Given I am logged in as "admin@shf.se"
    And I am on the "landing" page
    When I click on t("admin.index.export") button
    And I am on the "landing" page
    Then I should see t("admin.export_ansokan_csv.success")
