Feature: As an Admin
  In order to get an easy overview of applications
  I need to see the status listed
  PT: https://www.pivotaltracker.com/story/show/134357317

  Background:
    Given the following users exists
      | email                         | admin |
      | under_review@mail.se          |       |
      | accepted@mail.se              |       |
      | rejected@mail.se              |       |
      | waiting_for_applicant@mail.se |       |
      | admin@sgf.com                 | true  |

    And the following applications exist:
      | company_number | user_email                    | state                 |
      | 5562252998     | under_review@mail.se          | under_review          |
      | 2120000142     | accepted@mail.se              | accepted              |
      | 5560360793     | rejected@mail.se              | rejected              |
      | 0000000000     | waiting_for_applicant@mail.se | waiting_for_applicant |

    And I am logged in as "admin@sgf.com"

  Scenario: Showing state in the application listing
    Given I am logged in as "admin@sgf.com"
    And I am on the list applications page
    Then I should see "4" applications
    And I should see t("membership_applications.index.state")
    And I should see t("membership_applications.under_review")
    And I should see t("membership_applications.accepted")
    And I should see t("membership_applications.rejected")
    And I should see t("membership_applications.waiting_for_applicant")
