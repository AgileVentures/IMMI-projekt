Feature: As an applicant
  In order to show my credentials
  I need to be able to upload files
  PT: https://www.pivotaltracker.com/story/show/133109591

  Background:
    Given the following users exists
      | email                  | admin |
      | applicant_1@random.com |       |
      | applicant_2@random.com |       |
      | admin@shf.com          | true  |


    And the following applications exist:
      | first_name | user_email             | company_number |
      | Emma       | applicant_1@random.com | 5562252998     |

  Scenario: Upload a file during a new application
    Given I am logged in as "applicant_2@random.com"
    And I am on the "submit new membership application" page
    And I fill in "Förnamn" with "Hans"
    And I fill in "Efternamn" with "Newfoundland"
    And I fill in "Org nr" with "5560360793"
    And I fill in "E-post" with "applicant_2@random.com"
    And I fill in "Telefon" with "031-1234567"
    And I choose a file named "diploma.pdf" to upload
    And I click on "Submit"
    And I should see "Tack, din ansökan har skickats."
    And I should see "Filen laddades upp: diploma.pdf"
    And I am on the "edit my application" page
    Then I should see "Uppladdade filer för denna ansökan:"
    And I should see "diploma.pdf" uploaded for this membership application

  Scenario: Upload a file for an existing application
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload
    And I click on "Submit"
    Then I should see "Uppladdade filer för denna ansökan:"
    And I should see "diploma.pdf" uploaded for this membership application
    And I should see "Ansökan har uppdaterats."
    And I should see "Filen laddades upp: diploma.pdf"
    And I should see "Ansökan har uppdaterats."


  Scenario: Upload a second file
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload
    And I click on "Submit"
    And I am on the "edit my application" page
    When I choose a file named "picture.jpg" to upload
    And I click on "Submit"
    Then I should see "Uppladdade filer för denna ansökan:"
    And I should see "diploma.pdf" uploaded for this membership application
    And I should see "picture.jpg" uploaded for this membership application
    And I should see 2 uploaded files listed

  Scenario: Upload multiple files at one time (multiple select)
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose the files named ["picture.jpg", "picture.png", "diploma.pdf"] to upload
    And I click on "Submit"
    Then I should see "Uppladdade filer för denna ansökan:"
    And I should see "diploma.pdf" uploaded for this membership application
    And I should see "picture.jpg" uploaded for this membership application
    And I should see "picture.png" uploaded for this membership application
    And I should see 3 uploaded files listed

  Scenario: Try to upload a file with unacceptable content type
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "tred.exe" to upload
    And I click on "Submit"
    Then I should see "Sorry, this is not a file type you can upload."
    And I should not see "not-accepted.exe" uploaded for this membership application

  Scenario: User deletes a file that was uploaded
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload
    And I click on "Submit"
    And I am on the "edit my application" page
    And I click on trash icon for "diploma.pdf"
    Then I should not see "diploma.pdf" uploaded for this membership application

  Scenario: User uploads a file to an existing membership application
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload
    And I click on "Submit"
    Then I should see "Uppladdade filer för denna ansökan:"
    And I should see "diploma.pdf" uploaded for this membership application


  Scenario: User can click on a file name to see the file
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    And I choose a file named "diploma.pdf" to upload
    And I click on "Submit"
    And I click on "diploma.pdf"


  Scenario: Admin can click on a file name to see the file
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    And I choose a file named "diploma.pdf" to upload
    And I click on "Submit"
    And I am Logged out
    And I am logged in as "admin@shf.com"
    And I am on the list applications page
    And I click the "Manage" action for the row with "5562252998"
    And I click on "diploma.pdf"

