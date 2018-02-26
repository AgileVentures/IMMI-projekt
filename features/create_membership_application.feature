Feature: Create a new membership application

  As a user
  In order to get a membership with SHF (which makes my business more valuable )
  I need to be able to submit a Membership Application
  PT: https://www.pivotaltracker.com/story/show/133940725
  &: https://www.pivotaltracker.com/story/show/135027425

  Secondary feature:
  As an admin
  So that we can minimize trouble signing up and sign up as many users as possible
  I would like required aspects of the membership form to be highlighted when they are missed
  PT: https://www.pivotaltracker.com/story/show/134192165

  Background:
    Given the following users exists
      | email                  | admin | member |
      | applicant_1@random.com |       |        |
      | applicant_2@random.com |       |        |
      | member@random.com      |       | true   |
      | admin@shf.se           | yes   |        |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |

    And the following applications exist:
      | user_email        | company_number | state    |
      | member@random.com | 5560360793     | accepted |

    And I am logged in as "applicant_1@random.com"


  Scenario: A user can submit a new Membership Application with 1 category
    Given I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | shf_applications.new.first_name | shf_applications.new.last_name | shf_applications.new.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | Kicki                           | Andersson                      | 5562252998                          | 031-1234567                       | info@craft.se                      |
    And I select "Groomer" Category
    And I click on t("shf_applications.new.submit_button_label")
    Then I should be on the "user instructions" page
    And I should see t("shf_applications.create.success", email_address: info@craft.se)
    When I am on the "edit my application" page
    Then the t("shf_applications.new.first_name") field should be set to "Kicki"
    And the t("shf_applications.new.last_name") field should be set to "Andersson"
    Then "applicant_1@random.com" should receive an email
    And I open the email
    And I should see t("mailers.shf_application_mailer.acknowledge_received.subject") in the email subject
    And I am logged in as "admin@shf.se"
    Then "admin@shf.se" should receive an email
    And I open the email
    And I should see t("mailers.admin_mailer.new_application_received.subject") in the email subject


  Scenario: A user can submit a new Membership Application with multiple categories
    Given I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | shf_applications.new.first_name | shf_applications.new.last_name | shf_applications.new.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | Kicki                           | Andersson                      | 5562252998                          | 031-1234567                       | info@craft.se                      |
    And I select "Trainer" Category
    And I select "Psychologist" Category
    And I click on t("shf_applications.new.submit_button_label")
    Then I should be on the "user instructions" page
    And I should see t("shf_applications.create.success", email_address: info@craft.se)


  Scenario: A user can submit a new Membership Application with no categories
    Given I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | shf_applications.new.first_name | shf_applications.new.last_name | shf_applications.new.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | Kicki                                  | Andersson                             | 5562252998                                 | 031-1234567                              | info@craft.se                             |
    And I click on t("shf_applications.new.submit_button_label")
    Then I should be on the "user instructions" page
    And I should see t("shf_applications.create.success", email_address: info@craft.se)


  Scenario: Applicant cannot see membership number when submitting
    Given I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    Then I should not see t("shf_applications.show.membership_number")


  Scenario: Applicant can see which fields are required
    Given I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    Then the field t("shf_applications.new.first_name") should have a required field indicator
    And the field t("shf_applications.new.company_number") should have a required field indicator
    And the field t("shf_applications.new.last_name") should have a required field indicator
    And the field t("shf_applications.new.contact_email") should have a required field indicator
    And the field t("shf_applications.new.phone_number") should not have a required field indicator
    And I should see t("is_required_field")


  Scenario: Two users can submit a new Membership Application (with empty membershipnumbers)
    Given I am logged in as "applicant_1@random.com"
    And I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | shf_applications.new.first_name | shf_applications.new.last_name | shf_applications.new.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | Applicant1                      | Andersson                      | 5562252998                          | 031-1234567                       | applicant_1@random.com             |
    And I click on t("shf_applications.new.submit_button_label")
    Then I should see t("shf_applications.create.success", email_address: applicant_1@random.com)
    Given I am logged in as "applicant_2@random.com"
    And I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | shf_applications.new.first_name | shf_applications.new.last_name | shf_applications.new.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | Applicant2                      | Andersson                      | 2120000142                          | 031-1234567                       | applicant_2@random.com             |
    And I click on t("shf_applications.new.submit_button_label")
    Then I should see t("shf_applications.create.success", email_address: applicant_2@random.com)


  Scenario Outline: Apply for membership - when things go wrong
    Given I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | shf_applications.new.first_name | shf_applications.new.last_name | shf_applications.new.company_number | shf_applications.new.contact_email | shf_applications.new.phone_number |
      | <f_name>                        | <l_name>                       | <c_number>                          | <c_email>                          | <phone>                           |

    When I click on t("shf_applications.new.submit_button_label")
    Then I should see error <model_attribute> <error>
    And I should receive no emails
    And "admin@shf.se" should receive no emails


    Scenarios:
      | f_name | c_number   | l_name    | c_email       | phone      | model_attribute                                             | error                        |
      | Kicki  |            | Andersson | kicki@immi.nu | 0706898525 | t("activerecord.attributes.shf_application.company_number") | t("errors.messages.blank")   |
      | Kicki  | 5562252998 |           | kicki@immi.nu | 0706898525 | t("activerecord.attributes.shf_application.last_name")      | t("errors.messages.blank")   |
      | Kicki  | 5562252998 | Andersson |               | 0706898525 | t("activerecord.attributes.shf_application.contact_email")  | t("errors.messages.blank")   |
      |        | 5562252998 | Andersson | kicki@immi.nu | 0706898525 | t("activerecord.attributes.shf_application.first_name")     | t("errors.messages.blank")   |
      | Kicki  | 5562252998 | Andersson | kicki@imminu  | 0706898525 | t("activerecord.attributes.shf_application.contact_email")  | t("errors.messages.invalid") |
      | Kicki  | 5562252998 | Andersson | kickiimmi.nu  | 0706898525 | t("activerecord.attributes.shf_application.contact_email")  | t("errors.messages.invalid") |


  Scenario Outline: Apply for membership: company number wrong length
    Given I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | shf_applications.new.first_name | shf_applications.new.last_name | shf_applications.new.company_number | shf_applications.new.contact_email | shf_applications.new.phone_number |
      | <f_name>                        | <l_name>                       | <c_number>                          | <c_email>                          | <phone>                           |

    And I click on t("shf_applications.new.submit_button_label")
    Then I should see <error>

    Scenarios:
      | f_name | c_number | l_name    | c_email       | phone      | error                                        |
      | Kicki  | 00       | Andersson | kicki@immi.nu | 0706898525 | t("errors.messages.wrong_length", count: 10) |


  Scenario: Cannot change locale if there are errors in the new application
    Given I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | shf_applications.new.first_name | shf_applications.new.last_name | shf_applications.new.company_number | shf_applications.new.contact_email | shf_applications.new.phone_number |
      | Kicki                           | Andersson                      | 1                                   | kicki@immi.n                       | 0706898525                        |

    And I click on t("shf_applications.new.submit_button_label")
    Then I should see t("errors.messages.wrong_length", count: 10)
    And I should not see t("show_in_swedish") image
    And I should not see t("show_in_english") image
    And I should see t("cannot_change_language") image


  # Note: this functional integration test passes; it proves that a member can submit a new application.
  # However, our application does not currently provide a menu option or other way for the Member to do this!
  Scenario: A member can submit a new application
    Given I am logged out
    And I am logged in as "member@random.com"
    And I am on the "new application" page
    And I fill in the translated form with data:
      | shf_applications.new.first_name | shf_applications.new.last_name | shf_applications.new.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | Lars                                   | IsaMember                             | 5562252998                                 | 031-1234567                              | member@random.com                         |
    And I select "Groomer" Category
    And I click on t("shf_applications.new.submit_button_label")
    Then I should be on the "user instructions" page
    And I should see t("shf_applications.create.success", email_address: member@random.com  )
    When I am on the "edit my application" page
    Then the t("shf_applications.new.first_name") field should be set to "Lars"
    And the t("shf_applications.new.last_name") field should be set to "IsaMember"
    Then "member@random.com" should receive an email
    And I open the email
    And I should see t("mailers.shf_application_mailer.acknowledge_received.subject") in the email subject
    And I am logged in as "admin@shf.se"
    Then "admin@shf.se" should receive an email
    And I open the email
    And I should see t("mailers.admin_mailer.new_application_received.subject") in the email subject


  Scenario: An admin cannot submit a new application because we don't know which User it is for
    Given I am logged in as "admin@shf.se"
    And I am on the "new application" page
    Then I should see t("errors.not_permitted")
