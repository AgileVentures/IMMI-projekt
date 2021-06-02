Feature: New Applicant gets an email acknowledging their application

  As a new applicant,
  So that I know that SHF received my application and that I didn't do something wrong,
  and so I know what I should expect to happen next,
  I should get an email acknowledging my new application


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email               | admin |
      | emma@happymutts.com |       |


    And the following business categories exist
      | name    |
      | Groomer |

    And the application file upload options exist

    And the following companies exist:
      | name                 | company_number | email                  | region    |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm |


  @selenium
  Scenario: User submits a new application and email is sent
    Given I am logged in as "emma@happymutts.com"
    Given I am on the "user account" page
    And I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                           | 031-1234567                       | emma@happymutts.com                |
    And I select "Groomer" Category

    And I select files delivery radio button "upload_later"

    And I click on t("shf_applications.new.submit_button_label")

    Then I should be on the "user account" page

    And I should see t("shf_applications.create.success_with_app_files_missing")

    Then "emma@happymutts.com" should receive an email
    And I open the email
    And I should see ""Sveriges Hundföretagare" <from@example.org>" in the email "from" header
    And I should see ""Sveriges Hundföretagare" <reply@example.org>" in the email "reply-to" header
    And I should see t("mailers.shf_application_mailer.acknowledge_received.subject") in the email subject
    And I should see t("mailers.shf_application_mailer.acknowledge_received.message_text") in the email body


  @selenium
  Scenario: User submits a new application app with bad info so it is not created, so no email sent [SAD PATH]
    Given I am logged in as "emma@happymutts.com"
    Given I am on the "user account" page
    And I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                           | 031-1234567                       | emma@happymutts.com                |

    And I select files delivery radio button "upload_later"

    And I click on t("shf_applications.new.submit_button_label")
    And I should see t("shf_applications.create.error")
    Then "emma@happymutts.com" should receive 0 email


  @selenium
  Scenario: No files have been uploaded for the application is shown in the email sent
    Given I am logged in as "emma@happymutts.com"
    Given I am on the "user account" page
    When I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                           | 031-1234567                       | emma@happymutts.com                |
    And I select "Groomer" Category

    And I select files delivery radio button "upload_later"

    And I click on t("shf_applications.new.submit_button_label")
    Then I should see t("shf_applications.create.success_with_app_files_missing")
    And "emma@happymutts.com" should receive an email

    When I open the email
    And I should see ""Sveriges Hundföretagare" <from@example.org>" in the email "from" header
    And I should see t("shf_applications.uploads.no_files") in the email body
    And I should not see t("shf_applications.uploads.files_uploaded") in the email body


  @selenium
  Scenario: Files have been uploaded for the application are shown in the email sent
    Given I am logged in as "emma@happymutts.com"
    Given I am on the "user account" page
    And I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                           | 031-1234567                       | emma@happymutts.com                |
    And I select "Groomer" Category

    And I select files delivery radio button "upload_now"
    And I choose files named "picture.jpg, diploma.pdf" to upload for the application
    And I click on t("shf_applications.new.submit_button_label")
    Then I should see t("shf_applications.create.success", email_address: 'emma@happymutts.com')
    And "emma@happymutts.com" should receive an email

    When I open the email
    Then I should see ""Sveriges Hundföretagare" <from@example.org>" in the email "from" header
    And I should see t("shf_applications.uploads.files_uploaded") in the email body
    And I should not see t("shf_applications.uploads.no_files") in the email body
    And I should see "diploma.pdf" in the email body
    And I should see "picture.jpg" in the email body





