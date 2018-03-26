Feature: New Applicant gets an email acknowledging their application

  As a new applicant,
  So that I know that SHF received my application and that I didn't do something wrong,
  and so I know what I should expect to happen next,
  I should get an email acknowledging my new application


  Background:

    Given the following users exists
      | email               | admin |
      | emma@happymutts.com |       |


    And the following business categories exist
      | name         |
      | Groomer      |

    And the following companies exist:
      | name                 | company_number | email                  | region     |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm  |


  Scenario: User submits a new application and email is sent
    Given I am logged in as "emma@happymutts.com"
    And I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                           | 031-1234567                       | emma@happymutts.com                |
    And I select "Groomer" Category
    And I click on t("shf_applications.new.submit_button_label")
    Then I should be on the "user instructions" page
    And I should see t("shf_applications.create.success", email_address: 'emma@happymutts.com')
    Then "emma@happymutts.com" should receive an email
    And I open the email
    And I should see t("mailers.shf_application_mailer.acknowledge_received.subject") in the email subject
    And I should see t("mailers.shf_application_mailer.acknowledge_received.message_text") in the email body


  Scenario: User submits a new application app with bad info so it is not created, so no email sent [SAD PATH]
    Given I am logged in as "emma@happymutts.com"
    And I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                           | 031-1234567                       | emmahappymutts.com                 |
    And I select "Groomer" Category
    And I click on t("shf_applications.new.submit_button_label")
    And I should see t("shf_applications.create.error")
    Then "emma@happymutts.com" should receive 0 email
