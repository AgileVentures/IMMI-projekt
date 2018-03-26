Feature: Applicant uploads a file for their application
  As an applicant
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
      | user_email             | company_number | state                 |
      | applicant_1@random.com | 5562252998     | waiting_for_applicant |

    And the following companies exist:
      | name                 | company_number | email                  | region     |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm  |


  Scenario: Upload a file during a new application
    Given I am logged in as "applicant_2@random.com"
    And I am on the "submit new membership application" page
    And I fill in the translated form with data:
      | shf_applications.new.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                          | 031-1234567                       | applicant_2@random.com             |
    And I choose a file named "diploma.pdf" to upload
    When I click on t("shf_applications.new.submit_button_label")
    Then I should see t("shf_applications.create.success", email_address: applicant_2@random.com)
    And I should see t("shf_applications.uploads.file_was_uploaded", filename: 'diploma.pdf')
    And I am on the "edit my application" page
    Then I should see t("shf_applications.uploads.files_uploaded")
    And I should see "diploma.pdf" uploaded for this membership application
    And I should see the file delete action


  Scenario: Upload a file for an existing application
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.uploads.files_uploaded")
    And I should see "diploma.pdf" uploaded for this membership application
    And I should see t("shf_applications.update.success")
    And I should see t("shf_applications.uploads.file_was_uploaded", filename: 'diploma.pdf')
    And I should see t("shf_applications.update.success")


  Scenario: Upload a second file
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload
    And I click on t("shf_applications.edit.submit_button_label")
    And I am Logged out
    And I am logged in as "admin@shf.com"
    And I am on the "application" page for "applicant_1@random.com"
    Then I click on t("shf_applications.ask_applicant_for_info_btn")
    And  I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "picture.jpg" to upload
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.uploads.files_uploaded")
    And I should see "diploma.pdf" uploaded for this membership application
    And I should see "picture.jpg" uploaded for this membership application
    And I should see 2 uploaded files listed


  @selenium
  Scenario: Upload multiple files at one time (multiple select)
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose the files named ["picture.jpg", "picture.png", "diploma.pdf"] to upload
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.uploads.files_uploaded")
    And I should see "diploma.pdf" uploaded for this membership application
    And I should see "picture.jpg" uploaded for this membership application
    And I should see "picture.png" uploaded for this membership application
    And I should see 3 uploaded files listed


  @selenium
  Scenario: Use the upload button multiple times
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "picture.jpg" to upload
    And I choose a file named "picture.png" to upload
    And I choose a file named "diploma.pdf" to upload
    Then I should see "diploma.pdf"
    And I should not see "picture.jpg"
    And I should not see "picture.png"


  Scenario: Try to upload a file with unacceptable content type
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "tred.exe" to upload
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.uploads.invalid_upload_type")
    And I should not see "not-accepted.exe" uploaded for this membership application


  Scenario: User deletes a file that was uploaded
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload
    And I click on t("shf_applications.edit.submit_button_label")
    And I am Logged out
    And I am logged in as "admin@shf.com"
    And I am on the "application" page for "applicant_1@random.com"
    Then I click on t("shf_applications.ask_applicant_for_info_btn")
    And  I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    And I click on trash icon for "diploma.pdf"
    Then I should not see "diploma.pdf" uploaded for this membership application


  Scenario: User uploads a file to an existing membership application
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.uploads.files_uploaded")
    And I should see "diploma.pdf" uploaded for this membership application


  Scenario: User can click on a file name to see the file
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    And I choose a file named "diploma.pdf" to upload
    And I click on t("shf_applications.edit.submit_button_label")
    And I click on "diploma.pdf"


  Scenario: Link to file uses _blank to open a new window
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    And I choose a file named "diploma.pdf" to upload
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see link "uploaded-file-link-1" with target = "_blank"



  Scenario: Admin can click on a file name to see the file
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    And I choose a file named "diploma.pdf" to upload
    And I click on t("shf_applications.edit.submit_button_label")
    And I am Logged out
    And I am logged in as "admin@shf.com"
    And I am on the "membership applications" page
    And I click the t("manage") action for the row with "5562252998"
    And I click on "diploma.pdf"

  Scenario: Applicant doesn't see delete action when just viewing application with 1 file uploaded
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    And I choose a file named "diploma.pdf" to upload
    And I click on t("shf_applications.edit.submit_button_label")
    When I am on the "application" page for "applicant_1@random.com"
    Then I should not see the file delete action

  Scenario: Admin doesn't see delete action when just viewing application with 1 file uploaded
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    And I choose a file named "diploma.pdf" to upload
    And I click on t("shf_applications.edit.submit_button_label")
    And I am Logged out
    And I am logged in as "admin@shf.com"
    When I am on the "application" page for "applicant_1@random.com"
    Then I should not see the file delete action
