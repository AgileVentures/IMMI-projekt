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
      | first_name | user_email             | company_number | state                 |
      | Emma       | applicant_1@random.com | 5562252998     | waiting_for_applicant |


  Scenario: Upload a file during a new application
    Given I am logged in as "applicant_2@random.com"
    And I am on the "submit new membership application" page
    And I fill in the translated form with data:
      | membership_applications.new.first_name | membership_applications.new.last_name | membership_applications.new.company_number | membership_applications.new.phone_number | membership_applications.new.contact_email |
      | Hans                                   | Newfoundland                          | 5560360793                                 | 031-1234567                              | applicant_2@random.com                    |
    And I choose a file named "diploma.pdf" to upload
    When I click on t("membership_applications.new.submit_button_label")
    Then I should see t("membership_applications.create.success")
    And I should see t("membership_applications.uploads.file_was_uploaded", filename: 'diploma.pdf')
    And I am on the "edit my application" page
    Then I should see t("membership_applications.uploads.files_uploaded")
    And I should see "diploma.pdf" uploaded for this membership application


  Scenario: Upload a file for an existing application
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.uploads.files_uploaded")
    And I should see "diploma.pdf" uploaded for this membership application
    And I should see t("membership_applications.update.success")
    And I should see t("membership_applications.uploads.file_was_uploaded", filename: 'diploma.pdf')
    And I should see t("membership_applications.update.success")


  Scenario: Upload a second file
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload
    And I click on t("membership_applications.edit.submit_button_label")
    And I am Logged out
    And I am logged in as "admin@shf.com"
    And I am on "Emma" application page
    Then I click on t("membership_applications.ask_applicant_for_info")
    And  I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "picture.jpg" to upload
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.uploads.files_uploaded")
    And I should see "diploma.pdf" uploaded for this membership application
    And I should see "picture.jpg" uploaded for this membership application
    And I should see 2 uploaded files listed


  Scenario: Upload multiple files at one time (multiple select)
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose the files named ["picture.jpg", "picture.png", "diploma.pdf"] to upload
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.uploads.files_uploaded")
    And I should see "diploma.pdf" uploaded for this membership application
    And I should see "picture.jpg" uploaded for this membership application
    And I should see "picture.png" uploaded for this membership application
    And I should see 3 uploaded files listed


  Scenario: Try to upload a file with unacceptable content type
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "tred.exe" to upload
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.uploads.invalid_upload_type")
    And I should not see "not-accepted.exe" uploaded for this membership application


  Scenario: User deletes a file that was uploaded
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload
    And I click on t("membership_applications.edit.submit_button_label")
    And I am Logged out
    And I am logged in as "admin@shf.com"
    And I am on "Emma" application page
    Then I click on t("membership_applications.ask_applicant_for_info")
    And  I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    And I click on trash icon for "diploma.pdf"
    Then I should not see "diploma.pdf" uploaded for this membership application


  Scenario: User uploads a file to an existing membership application
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.uploads.files_uploaded")
    And I should see "diploma.pdf" uploaded for this membership application


  Scenario: User can click on a file name to see the file
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    And I choose a file named "diploma.pdf" to upload
    And I click on t("membership_applications.edit.submit_button_label")
    And I click on "diploma.pdf"


  Scenario: Link to file uses _blank to open a new window
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    And I choose a file named "diploma.pdf" to upload
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see link "uploaded-file-link-1" with target = "_blank"



  Scenario: Admin can click on a file name to see the file
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    And I choose a file named "diploma.pdf" to upload
    And I click on t("membership_applications.edit.submit_button_label")
    And I am Logged out
    And I am logged in as "admin@shf.com"
    And I am on the list applications page
    And I click the t("manage") action for the row with "5562252998"
    And I click on "diploma.pdf"

