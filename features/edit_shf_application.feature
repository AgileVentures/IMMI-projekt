Feature: Edit SHF Application

  As an applicant
  In order to correct errors or provide more information
  I need to be able to edit my SHF application

  PT: https://www.pivotaltracker.com/story/show/134078325


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email             | member | admin |
      | emma@random.com   | false  |       |
      | hans@random.com   | false  |       |
      | nils@random.com   | true   |       |
      | bob@barkybobs.com | false  |       |
      | admin@shf.se      | true   | true  |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |

    And the application file upload options exist

    And the following applications exist:
      | user_email        | company_number         | state                 | categories |
      | emma@random.com   | 5560360793             | waiting_for_applicant | Groomer    |
      | hans@random.com   | 2120000142, 5560360793 | new                   | Groomer    |
      | nils@random.com   | 2120000142             | accepted              | Groomer    |
      | bob@barkybobs.com | 5560360793             | rejected              | Groomer    |

  @selenium
  Scenario: Applicant makes mistake when editing their own application (no files uploaded) [SAD PATH]
    Given I am logged in as "emma@random.com"
    Given I am on the "user instructions" page
    And I click on t("menus.nav.users.my_application") link
    Then I should be on "Edit My Application" page
    And I fill in t("shf_applications.show.contact_email") with ""
    And I unselect "Groomer" Category
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.update.error")
    And I should see error t("shf_applications.show.contact_email") t("errors.messages.blank")
    Then I should see error t("activerecord.attributes.shf_application.business_categories") t("errors.messages.blank")
    And I should see button t("shf_applications.edit.submit_button_label")
    And I should not see t("shf_applications.uploads.please_upload_again")

  @selenium
  Scenario: Applicant makes mistake when uploading a file and editing their own application [SAD PATH]
    Given I am logged in as "emma@random.com"
    And I am on the "user instructions" page
    And I click on first t("menus.nav.users.my_application") link
    Then I should be on "Edit My Application" page
    And I choose a file named "diploma.pdf" to upload
    And I fill in t("shf_applications.show.contact_email") with ""
    And I unselect "Groomer" Category
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.update.error")
    And I should see t("shf_applications.uploads.please_upload_again")

  @selenium
  Scenario: Add 2nd company, no files uploaded, user sees success and deliver-files prompt
    Given I am logged in as "emma@random.com"
    And I am on the "user instructions" page
    And I click on first t("menus.nav.users.my_application") link
    Then I should be on "Edit My Application" page
    Then I fill in t("shf_applications.show.company_number") with "5560360793, 212000-0142"

    And I select files delivery radio button "upload_now"

    And I click on t("shf_applications.edit.submit_button_label")
    Then I should be on the "show my application" page for "emma@random.com"

    And I should see t("shf_applications.update.success_with_app_files_missing")
    And I should see t("shf_applications.update.upload_file_or_select_method")

    And I should see "5560360793, 2120000142"

  @selenium
  Scenario: Files uploaded, user sees success and does not see deliver-files prompt
    Given I am logged in as "emma@random.com"
    And I am on the "user instructions" page
    And I click on first t("menus.nav.users.my_application") link
    Then I should be on "Edit My Application" page

    And I select files delivery radio button "upload_now"
    And I choose a file named "diploma.pdf" to upload

    And I click on t("shf_applications.edit.submit_button_label")
    Then I should be on the "show my application" page for "emma@random.com"

    And I should see t("shf_applications.update.success")
    And I should not see t("shf_applications.update.success_with_app_files_missing")

  @selenium
  Scenario: User deletes uploaded files
    Given I am logged in as "emma@random.com"
    And I am on the "user instructions" page
    And I click on first t("menus.nav.users.my_application") link
    Then I should be on "Edit My Application" page

    And I select files delivery radio button "upload_now"
    And I choose files named "diploma.pdf, image.jpg" to upload

    And I click on t("shf_applications.edit.submit_button_label")
    Then I should be on the "show my application" page for "emma@random.com"

    And I should see t("shf_applications.update.success")
    And I should not see t("shf_applications.update.success_with_app_files_missing")

    And I click on first t("menus.nav.users.my_application") link
    Then I should be on "Edit My Application" page

    And I delete the second uploaded file
    And I should not see "image.jpg"

    And I should be on "Edit My Application" page

    And I should see "diploma.pdf"

    And I delete the first uploaded file
    And I should not see "diploma.pdf"

    And I should see t("shf_applications.uploads.no_files")


  @selenium @skip_ci_test
  Scenario: Create 2nd company, file delivery via email, user sees success and deliver-files reminder
    Given I am logged in as "emma@random.com"
    Given I am on the "edit application" page
    Then I should be on "Edit My Application" page

    # Create new company in modal
    And I click on t("companies.new.title")
    And I fill in "company-number-in-modal" with "2286411992"
    And I fill in t("companies.show.email") with "info@craft.se"
    And I click on t("companies.create.create_submit")
    # FIXME do we still need to wait this long? does waiting for AJAX to complete work reliably here instead?
    And I wait 4 seconds
    And I wait for all ajax requests to complete

    And I should see t("shf_applications.new.file_delivery_selection")

    And I select files delivery radio button "email"

    And I click on t("shf_applications.edit.submit_button_label")
    Then I should be on the "show my application" page for "emma@random.com"

    And I should see t("shf_applications.update.success_with_app_files_missing")
    And I should see t("shf_applications.update.remember_to_deliver_files")

    And I should see "5560360793, 2286411992"

  @selenium
  Scenario: User edit app with two companies, corrects an error in company number
    Given I am logged in as "hans@random.com"
    And I am on the "user instructions" page
    And I click on first t("menus.nav.users.my_application") link
    Then I should be on "Edit My Application" page
    And the t("shf_applications.show.company_number") field should be set to "5560360793, 2120000142"

    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 556036-07, 2120000142                | 031-1234567                       | info@craft.se                      |

    And I click on t("shf_applications.edit.submit_button_label")
    And I should see t("activerecord.errors.models.shf_application.attributes.companies.not_found", value: '55603607')
    Then I fill in t("shf_applications.show.company_number") with "556036-0793, 2120000142"
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should be on the "show my application" page for "hans@random.com"

    And I should see t("shf_applications.update.success_with_app_files_missing")

    And I should see "5560360793, 2120000142"

  Scenario: Applicant can not edit applications not created by them
    Given I am logged in as "emma@random.com"
    And I am on the "edit application" page for "hans@random.com"
    Then I should see a message telling me I am not allowed to see that page

  Scenario: Applicant can not edit accepted application
    Given I am logged in as "nils@random.com"
    And I am on the "edit application" page for "nils@random.com"
    Then I should see a message telling me I am not allowed to see that page

  Scenario: Applicant can view accepted application
    Given I am logged in as "nils@random.com"
    And I am on the "show my application" page for "nils@random.com"
    Then I should not see a message telling me I am not allowed to see that page
    And I should see t("shf_applications.accepted")

  Scenario: Applicant can not edit rejected application
    Given I am logged in as "bob@barkybobs.com"
    And I am on the "edit application" page for "bob@barkybobs.com"
    Then I should see a message telling me I am not allowed to see that page

  Scenario: Applicant can view rejected application
    Given I am logged in as "bob@barkybobs.com"
    And I am on the "show my application" page for "bob@barkybobs.com"
    Then I should not see a message telling me I am not allowed to see that page
    And I should see t("shf_applications.rejected")

  Scenario: Member wants to view their own application
    Given I am logged in as "nils@random.com"
    And I am on the "landing" page
    And I click on t("menus.nav.members.my_application")
    Then I should be on "Show My Application" page

  Scenario: Admin should be able to edit membership number
    Given I am logged in as "admin@shf.se"
    And I am on the "edit application" page for "nils@random.com"
    Then I should see t("shf_applications.show.membership_number")

  @selenium
  Scenario: Admin can't edit membership number for a rejected application
    Given I am logged in as "admin@shf.se"
    And I am on the "edit application" page for "bob@barkybobs.com"
    And I should not see t("shf_applications.edit.submit_button_label")

  @selenium
  Scenario: Cannot change locale if there are errors in the application
    Given I am logged in as "emma@random.com"
    And I am on the "user instructions" page
    And I click on first t("menus.nav.users.my_application") link
    Then I should be on "Edit My Application" page
    And I fill in t("shf_applications.show.contact_email") with ""
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.update.error")
    And I should not see t("show_in_swedish") image
    And I should not see t("show_in_english") image
    And I should see t("cannot_change_language") image
