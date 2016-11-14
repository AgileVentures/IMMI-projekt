Feature: As an Admin
  In order to get members into SHF and get their money
  I need to be able to accept/reject their application
  PT: https://www.pivotaltracker.com/story/show/133950603

  Background:
    Given the following users exists
      | email                  | admin |
      | din@mail.se            |       |
      | admin@sgf.com          | true  |

    And the following applications exist:
      | company_name | user_email  |
      | DoggieZone   | din@mail.se |

    And I am logged in as "admin@sgf.com"
    And time is frozen at 2016-12-16

  Scenario: Flag a Membership Application as accepted
    Given I am on "DoggieZone" application page
    When I set "membership_application_status" to "Accepted"
    And I click on "Update"
    Then I should see "Membership Application successfully updated"
    And "Accepted" should be set in "membership_application_status"
    And I should see "Membership accepted at 2016-12-16"
    And I should be on the management page for "DoggieZone"

  Scenario: Flag a Membership Application as rejected
    And I am on "DoggieZone" application page
    When I set "membership_application_status" to "Rejected"
    And I click on "Update"
    Then I should see "Membership Application successfully updated"
    And "Rejected" should be set in "membership_application_status"
    And I should see "Membership rejected at 2016-12-16"

  Scenario: Page for status update is not visible for non admins
    Given I am Logged out
    And I am logged in as "din@mail.se"
    Given I am on "DoggieZone" application page
    Then I should see "You are not authorized to perform this action."
