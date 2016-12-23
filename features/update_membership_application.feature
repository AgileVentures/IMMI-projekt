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
    When I set "membership_application_status" to t("membership_applications.rejected")
    And I click on t("update")
    Then I should see t("membership_applications.update.success")
    And t("membership_applications.rejected") should be set in "membership_application_status"
    And I should see status line with status t("membership_applications.rejected") and date "2016-12-16"


  Scenario: Application submitter can see but not update the Application status
    Given I am Logged out
    And I am logged in as "applicant_1@random.com"
    Given I am on "Emma" application page
    Then I should see t("membership_applications.show.title", member_full_name: 'Emma Lastname')
    And I should see t("membership_applications.show.app_status")
    And I should not see button t("update")

