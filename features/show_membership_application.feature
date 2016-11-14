Feature: As an Admin
  So that we can accept or reject new Memberships,
  I need to review a Membership Application that has been submitted
  PT: https://www.pivotaltracker.com/story/show/133950343

  Secondary feature:
  As an admin
  In order to handle new member applications
  I need to be able to log in to an admin part of the site

  PT: https://www.pivotaltracker.com/story/show/133080839

  Background:
    Given the following users exists
      | email                  | admin |
      | applicant_1@random.com |       |
      | applicant_2@random.com |       |
      | applican3_2@random.com |       |
      | admin@sgf.com          | true  |

    And the following applications exist:
      | company_name | company_number | contact_person | phone_number | company_email | user_email             |
      | Hunderiet    | 1234567890     | Emma Svensson  | 1234-234567  | min@mail.se   | applicant_1@random.com |
      | DoggieZone   | 2345678901     | Pam Andersson  | 0234-234567  | din@mail.se   | applicant_2@random.com |
      | Tassa-in AB  | 1234367890     | Anna Knutsson  | 1234-234569  | sin@mail.se   | applican3_2@random.com |


  Scenario: Listing incoming Applications open for Admin
    Given I am logged in as "admin@sgf.com"
    And I am on the list applications page
    Then I should see "3" applications
    When I click on "DoggieZone"
    Then I should be on the management page for "DoggieZone"
    And I should see:
      | content       |
      | 2345678901    |
      | Pam Andersson |
      | 0234-234567   |
      | din@mail.se   |

  Scenario: Listing incoming Applications restricted for Non-admins
    Given I am logged in as "applicant_2@random.com"
    And I am on the list applications page
    Then I should see "You are not authorized to perform this action."