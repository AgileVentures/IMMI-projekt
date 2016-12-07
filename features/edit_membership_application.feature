Feature: As an applicant
  In order to be able to edit my application
  I want to be allowed to do that

  PT: https://www.pivotaltracker.com/story/show/134078325


  Background:
    Given the following users exists
      | email                  |
      | applicant_1@random.com |
      | applicant_2@random.com |

    And the following applications exist:
      | first_name | user_email             | company_number |
      | Emma       | applicant_1@random.com |5560360793      |
      | Hans       | applicant_2@random.com |2120000142      |

  Scenario: Applicant wants to edit his own application
    Given I am logged in as "applicant_1@random.com"
    And I am on the "landing" page
    And I click on "Min ansökan"
    Then I should be on "Edit My Application" page
    And I fill in "Förnamn" with "Anna"
    And I click on "Submit"
    Then I should see "Ansökan har uppdaterats."
    And I should be on the application page for "Anna"
    And I should see "Anna Lastname"

  Scenario: Applicant makes mistake when editing his own application
    Given I am logged in as "applicant_1@random.com"
    And I am on the "landing" page
    And I click on "Min ansökan"
    Then I should be on "Edit My Application" page
    And I fill in "E-post" with "sussimmi.nu"
    And I click on "Submit"
    Then I should see "Ett eller flera problem hindrade din ansökan från att sparas."
    And I should be on "Edit My Application" page

  Scenario: Applicant can not edit applications not created by him
    Given I am logged in as "applicant_1@random.com"
    And I navigate to the edit page for "Hans"
    Then I should see "Du har inte behörighet att göra detta."