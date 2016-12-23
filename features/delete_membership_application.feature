Feature: As an admin
  In order to keep business categories correct and helpful to visitors and members
  I need to be able to delete any that aren't needed or valid

  PT:


  Background:
    Given the following users exists
      | email           | is_member | admin |
      | emma@random.com | false     |       |
      | hans@random.com | false     |       |
      | nils@random.com | true      |       |
      | admin@shf.se    | false     | true  |

    And the following applications exist:
      | first_name | user_email      | company_number | status  |
      | Emma       | emma@random.com | 5560360793     | pending |
      | Hans       | hans@random.com | 2120000142     | pending |
      | Nils       | nils@random.com | 2120000142     | Godkänd |


  Scenario: Admin should see the 'delete' button
    Given I am logged in as "admin@shf.se"
    And I am on the application page for "Emma"
    Then I should not see t("errors.not_permitted")
    And I should see t("membership_applications.show.delete")


  Scenario: Member should not see the 'delete' button on their own application
    Given I am logged in as "emma@random.com"
    And I am on the application page for "Emma"
    Then I should not see t("errors.not_permitted")
    And I should not see t("membership_applications.show.delete")

  Scenario: Visitor should not see the 'delete' button
    Given I am Logged out
    And I am on the application page for "Emma"
    Then I should see t("errors.not_permitted")
    And I should not see t("membership_applications.show.delete")


  Scenario: Admin wants to delete a membership application
    Given I am logged in as "admin@shf.se"
    And I am on the application page for "Emma"
    And I click on t("membership_applications.show.delete")
    Then I should see t("membership_applications.application_deleted")
    And I should not see "Emma"



  Scenario: Admin delete a membership application; company should still exist
    Given I am logged in as "admin@shf.se"
    And I am on the application page for "Hans"
    And I click on t("membership_applications.show.delete")
    Then I should see t("membership_applications.application_deleted")
    And I should not see "Hans"
    And I am on the "all companies" page
    And I should see "2120000142"
