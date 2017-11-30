Feature: When a new application is received, all admins get an email notification

  As an admin,
  So that I know that SHF received a new application and that we need to start reviewing it,
  I should get an email with a link to the application so I can go look at it
  and the email of the applicant so I have it if there is some problem with the application or the SHF system
  I can contact the applicant easily.


  Background:

    Given the following users exists
      | email               | admin |
      | admin1@shf.se       | yes   |
      | admin2@shf.se       | yes   |
      | emma@happymutts.com |       |


    And the following business categories exist
      | name         |
      | Groomer      |


  Scenario: User submits a new application and email is sent to all admins
    Given I am logged in as "emma@happymutts.com"
    And I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | membership_applications.new.first_name | membership_applications.new.last_name | membership_applications.new.company_number | membership_applications.new.phone_number | membership_applications.new.contact_email |
      | Emma                                   | HappyMutts                            | 5562252998                                 | 031-1234567                              | emma@happymutts.com                       |
    And I select "Groomer" Category
    And I click on t("membership_applications.new.submit_button_label")
    Then I should be on the "landing" page
    And I should see t("membership_applications.create.success", email_address: 'emma@happymutts.com')
    And I am logged out
    And I am logged in as "admin1@shf.se"
    Then "admin1@shf.se" should receive an email
    And I open the email
    And I should see t("application_mailer.admin.new_application_received.subject") in the email subject
    And I should see t("application_mailer.admin.new_application_received.message_text.new_app_arrived") in the email body
    And I should see t("application_mailer.admin.new_application_received.message_text.from") in the email body
    And I should see t("application_mailer.admin.new_application_received.message_text.view_app_here") in the email body
    And I should see t("application_mailer.admin.new_application_received.message_text.must_be_logged_in") in the email body
    And I am logged out
    And I am logged in as "admin2@shf.se"
    Then "admin2@shf.se" should receive an email
    And I open the email
    And I should see t("application_mailer.admin.new_application_received.subject") in the email subject
    And I should see t("application_mailer.admin.new_application_received.message_text.new_app_arrived") in the email body
    And I should see t("application_mailer.admin.new_application_received.message_text.from") in the email body
    And I should see t("application_mailer.admin.new_application_received.message_text.view_app_here") in the email body
    And I should see t("application_mailer.admin.new_application_received.message_text.must_be_logged_in") in the email body


  Scenario: User submits a new application app with bad info so it is not created, so no email sent [SAD PATH]
    Given I am logged in as "emma@happymutts.com"
    And I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | membership_applications.new.first_name | membership_applications.new.phone_number | membership_applications.new.contact_email |
      | Emma                                   | 031-1234567                              | emma@happymutts.com                       |
    And I select "Groomer" Category
    And I click on t("membership_applications.new.submit_button_label")
    And I should see t("membership_applications.create.error")
    Then "admin1@shf.se" should receive 0 email
    Then "admin2@shf.se" should receive 0 email
