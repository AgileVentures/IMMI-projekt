Feature: As an Admin
  In order to get members into SHF and get their money
  I need to be able to accept/reject their application
  PT: https://www.pivotaltracker.com/story/show/133950603

  Background:
    Given the following users exists
      | email                  | admin |
      | applicant_1@random.com |       |
      | applicant_2@random.com |       |
      | admin@sgf.com          | true  |

    And the following applications exist:
      | first_name | user_email             | company_number |
      | Emma       | applicant_1@random.com | 5562252998     |
      | Hans       | applicant_2@random.com | 2120000142     |


    And I am logged in as "admin@sgf.com"
    And time is frozen at 2016-12-16

  Scenario: Flag a Membership Application as rejected
    And I am on "Hans" application page
    When I set "membership_application_status" to "Avböjd"
    And I click on "Update"
    Then I should see "Ansökan har uppdaterats."
    And "Avböjd" should be set in "membership_application_status"
    And I should see "Status: Avböjd - 2016-12-16"

  Scenario: Application submitter can see but not update the Application status
    Given I am Logged out
    And I am logged in as "applicant_1@random.com"
    Given I am on "Emma" application page
    Then I should see "Ansökan från Emma"
    And I should see "Status"
    And I should not see button "Update"

