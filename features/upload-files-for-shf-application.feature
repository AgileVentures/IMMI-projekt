Feature: Applicant uploads a file for their application

  As an applicant
  In order to show my credentials when I apply for membership
  I need to be able to upload files

  PT: https://www.pivotaltracker.com/story/show/133109591

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                           | admin | first_name | last_name |
      | applicant_1@random.com          |       | One        | Applicant |
      | applicant_2@random.com          |       | Two        | Applicant |
      | applicant-has-a-file@random.com |       | HasAFile   | Applicant |
      | admin@shf.com                   | true  |            |           |

    And the following business categories exist
      | name    |
      | Groomer |

    And the application file upload options exist

    And the following applications exist:
      | user_email                      | company_number | state | uploaded file names |
      | applicant_1@random.com          | 5562252998     | new   |                     |
      | applicant-has-a-file@random.com | 5562252998     | new   | diploma.pdf         |

    And the following companies exist:
      | name                 | company_number | email                  | region    |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm |

    # ---------------------------------------------------------------------------------------------

  @selenium
  Scenario: Upload a file during a new application
    Given I am logged in as "applicant_2@random.com"
    And I am on the "submit new membership application" page
    And I fill in the translated form with data:
      | shf_applications.new.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                          | 031-1234567                       | applicant_2@random.com             |
    And I select "Groomer" Category
    And I select files delivery radio button "upload_now"

    And I choose a file named "diploma.pdf" to upload for the application
    When I click on t("shf_applications.new.submit_button_label")
    Then I should see t("shf_applications.create.success", email_address: applicant_2@random.com)
    And I should see t("shf_applications.uploads.file_was_uploaded", filename: 'diploma.pdf')
    And I am on the "edit my application" page
    Then I should see t("shf_applications.uploads.files_uploaded")
    And I should see "diploma.pdf" uploaded for this membership application
    And I should see the file delete action

  @selenium
  Scenario: Upload a file for an existing application
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload for the application
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.uploads.files_uploaded")
    And I should see "diploma.pdf" uploaded for this membership application
    And I should see t("shf_applications.update.success")
    And I should see t("shf_applications.uploads.file_was_uploaded", filename: 'diploma.pdf')
    And I should see t("shf_applications.update.success")

  @selenium
  Scenario: Upload a second file
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload for the application
    And I click on t("shf_applications.edit.submit_button_label")
    And I am Logged out

    When I am logged in as "admin@shf.com"
    And I am on the "application" page for "applicant_1@random.com"
    When I click on t("shf_applications.start_review_btn")
    Then I click on t("shf_applications.ask_applicant_for_info_btn")

    When  I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    And I choose a file named "picture.jpg" to upload for the application
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.uploads.files_uploaded")
    And I should see "diploma.pdf" uploaded for this membership application
    And I should see "picture.jpg" uploaded for this membership application
    And I should see 2 uploaded files listed


  @selenium
  Scenario: Admin can upload a file for a user's application; user can then see those uploaded files too
    Given I am logged in as "admin@shf.com"
    And I am on the "edit my application" page for "applicant_1@random.com"
    When I choose a file named "picture.jpg" to upload for the application
    And I select files delivery radio button "upload_now"
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.uploads.files_uploaded")
    And I should see "picture.jpg" uploaded for this membership application
    And I should see 1 uploaded files listed

    Given I am logged out
    Given I am logged in as "applicant_1@random.com"
    When I am on the "application" page for "applicant_1@random.com"
    Then I should see "picture.jpg" uploaded for this membership application
    And I should see 1 uploaded files listed


  @selenium
  Scenario: Upload multiple files at one time (multiple select)
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose files named "picture.jpg, picture.png, diploma.pdf" to upload for the application
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.uploads.files_uploaded")
    And I should see "diploma.pdf" uploaded for this membership application
    And I should see "picture.jpg" uploaded for this membership application
    And I should see "picture.png" uploaded for this membership application
    And I should see 3 uploaded files listed

    And I am logged in as "admin@shf.com"
    And I am on the "membership applications" page
    And I should see "3" files for the "second" listed application


  @selenium
  Scenario: Use the upload button multiple times
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "picture.jpg" to upload for the application
    And I choose a file named "picture.png" to upload for the application
    And I choose a file named "diploma.pdf" to upload for the application
    Then I should see "diploma.pdf"
    # FIXME - the following 2 lines sometimes fail:
    And I should not see "picture.jpg"
    And I should not see "picture.png"

  @selenium
  Scenario: Try to upload a file with unacceptable content type
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "tred.exe" to upload for the application
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.uploads.invalid_upload_type")
    And I should not see "not-accepted.exe" uploaded for this membership application


  @selenium
  Scenario: User deletes a file that was uploaded
    Given I am logged in as "applicant-has-a-file@random.com"
    And I am on the "edit my application" page
    And I click on trash icon for "diploma.pdf"
    Then I should not see "diploma.pdf" uploaded for this membership application
    And I should see t("shf_applications.uploads.no_files")


  @selenium
  Scenario: Admin can delete an uploaded file on a user's application
    Given I am logged in as "admin@shf.com"
    And I am on the "edit my application" page for "applicant-has-a-file@random.com"
    And I click on trash icon for "diploma.pdf"

    Then I should not see "diploma.pdf" uploaded for this membership application
    And I should see t("shf_applications.uploads.no_files")

    Given I am logged out
    Given I am logged in as "applicant-has-a-file@random.com"
    And I am on the "show my application" page
    Then I should not see "diploma.pdf" uploaded for this membership application
    And I should see t("shf_applications.uploads.no_files")


  @selenium
  Scenario: User uploads a file to an existing membership application
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload for the application
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.uploads.files_uploaded")
    And I should see "diploma.pdf" uploaded for this membership application

  @selenium
  Scenario: User can click on a file name to see the file; link uses _blank to open a new window
    Given I am logged in as "applicant-has-a-file@random.com"
    When I am on the "my application" page
    Then I should see link "uploaded-file-link-1" with target = "_blank"
    And I click on "diploma.pdf"


  @selenium
  Scenario: Admin can click on a file name to see the file; link uses _blank to open a new window
    Given I am logged in as "admin@shf.com"
    And I am on the "membership applications" page
    And I click the t("manage") action for the row with "Applicant, HasAFile"
    Then I should see link "uploaded-file-link-1" with target = "_blank"
    And I click on "diploma.pdf"


  @selenium
  Scenario: Applicant doesn't see delete action when just viewing application with 1 file uploaded
    Given I am logged in as "applicant-has-a-file@random.com"
    When I am on the "my application" page
    Then I should not see the file delete action


  @selenium
  Scenario: Admin doesn't see delete action when just viewing application with 1 file uploaded
    Given I am logged in as "admin@shf.com"
    When I am on the "application" page for "applicant-has-a-file@random.com"
    Then I should not see the file delete action
