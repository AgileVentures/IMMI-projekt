Feature: When a new application is received, all admins get an email notification

  As an admin,
  So that I know that SHF received a new application and that we need to start reviewing it,
  I should get an email with a link to the application so I can go look at it
  and the email of the applicant so I have it if there is some problem with the application or the SHF system
  I can contact the applicant easily.


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email               | admin | first_name | last_name  |
      | admin1@shf.se       | yes   |            |            |
      | admin2@shf.se       | yes   |            |            |
      | admin3@shf.se       | yes   |            |            |
      | emma@happymutts.com |       | Emma       | HappyMutts |


    And the following business categories exist
      | name         |
      | Groomer      |

    And the application file upload options exist

    And the following companies exist:
      | name                 | company_number | email                  | region     |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm  |

  @selenium
  Scenario: User submits a new application and email is sent to all 3 admins
    Given I am logged in as "emma@happymutts.com"
    Given I am on the "user instructions" page
    And I click on first t("menus.nav.users.apply_for_membership") link

    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                           | 031-1234567                       | emma@happymutts.com                |

    And I select "Groomer" Category

    And I select files delivery radio button "upload_later"

    And I click on t("shf_applications.new.submit_button_label")
    Then I should be on the "user account" page

    And I should see t("shf_applications.create.success_with_app_files_missing")

    And I am logged out
    And I am logged in as "admin1@shf.se"
    Then "admin1@shf.se" should receive an email
    And I open the email
    And I should see t("mailers.admin_mailer.new_application_received.subject") in the email subject
    And I should see t("mailers.admin_mailer.new_application_received.message_text.new_app_arrived") in the email body
    And I should see t("mailers.admin_mailer.new_application_received.message_text.from") in the email body
    And I should see t("mailers.admin_mailer.new_application_received.message_text.view_app_here") in the email body
    And I should see t("mailers.admin_mailer.new_application_received.message_text.must_be_logged_in") in the email body
    And I should not see "http://localhost:3000/ansokan/1/redigera" in the email body
    And I should see "http://localhost:3000/ansokan/1" in the email body
    And I should see ""Sveriges Hundföretagare" <from@example.org>" in the email "from" header
    And I should see ""Sveriges Hundföretagare" <reply@example.org>" in the email "reply-to" header
    When I follow "http://localhost:3000/ansokan/1" in the email
    Then I should see t("shf_applications.show.title", user_full_name: 'Emma HappyMutts')
    And I am logged out
    And I am logged in as "admin2@shf.se"
    Then "admin2@shf.se" should receive an email
    And I open the email
    And I should see t("mailers.admin_mailer.new_application_received.subject") in the email subject
    And I should see t("mailers.admin_mailer.new_application_received.message_text.new_app_arrived") in the email body
    And I should see t("mailers.admin_mailer.new_application_received.message_text.from") in the email body
    And I should see t("mailers.admin_mailer.new_application_received.message_text.view_app_here") in the email body
    And I should see t("mailers.admin_mailer.new_application_received.message_text.must_be_logged_in") in the email body
    And I should not see "http://localhost:3000/ansokan/1/redigera" in the email body
    And I should see "http://localhost:3000/ansokan/1" in the email body
    And I should see ""Sveriges Hundföretagare" <from@example.org>" in the email "from" header
    And I should see ""Sveriges Hundföretagare" <reply@example.org>" in the email "reply-to" header
    When I follow "http://localhost:3000/ansokan/1" in the email
    Then I should see t("shf_applications.show.title", user_full_name: 'Emma HappyMutts')
    Then "admin3@shf.se" should receive an email
    And I open the email
    And I should see t("mailers.admin_mailer.new_application_received.subject") in the email subject
    And I should see t("mailers.admin_mailer.new_application_received.message_text.new_app_arrived") in the email body
    And I should see t("mailers.admin_mailer.new_application_received.message_text.from") in the email body
    And I should see t("mailers.admin_mailer.new_application_received.message_text.view_app_here") in the email body
    And I should see t("mailers.admin_mailer.new_application_received.message_text.must_be_logged_in") in the email body
    And I should not see "http://localhost:3000/ansokan/1/redigera" in the email body
    And I should see "http://localhost:3000/ansokan/1" in the email body
    And I should see ""Sveriges Hundföretagare" <from@example.org>" in the email "from" header
    And I should see ""Sveriges Hundföretagare" <reply@example.org>" in the email "reply-to" header
    When I follow "http://localhost:3000/ansokan/1" in the email
    Then I should see t("shf_applications.show.title", user_full_name: 'Emma HappyMutts')

  @selenium
  Scenario: User submits a new application app with bad info so it is not created, so no email sent [SAD PATH]
    Given I am logged in as "emma@happymutts.com"
    Given I am on the "user instructions" page
    And I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                           | 031-1234567                       | emma@happymutts.com                 |

    And I select files delivery radio button "upload_later"

    And I click on t("shf_applications.new.submit_button_label")

    And I should see t("shf_applications.create.error")
    Then "admin1@shf.se" should receive 0 email
    Then "admin2@shf.se" should receive 0 email
