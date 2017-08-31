Feature: As a user
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
      | email                  |
      | applicant_1@random.com |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |

    And I am logged in as "applicant_1@random.com"

  Scenario: A user can submit a new Membership Application with 1 category
    Given I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | membership_applications.new.first_name | membership_applications.new.last_name | membership_applications.new.company_number | membership_applications.new.phone_number | membership_applications.new.contact_email |
      | Kicki                                  | Andersson                             | 5562252998                                 | 031-1234567                              | info@craft.se                             |
    And I select "Groomer" Category
    And I click on t("membership_applications.new.submit_button_label")
    Then I should be on the "landing" page
    And I should see t("membership_applications.create.success")
    When I click on t("menus.nav.users.my_application")
    Then the t("membership_applications.new.first_name") field should be set to "Kicki"
    And the t("membership_applications.new.last_name") field should be set to "Andersson"


  Scenario: A user can submit a new Membership Application with multiple categories
    Given I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | membership_applications.new.first_name | membership_applications.new.last_name | membership_applications.new.company_number | membership_applications.new.phone_number | membership_applications.new.contact_email |
      | Kicki                                  | Andersson                             | 5562252998                                 | 031-1234567                              | info@craft.se                             |
    And I select "Trainer" Category
    And I select "Psychologist" Category
    And I click on t("membership_applications.new.submit_button_label")
    Then I should be on the "landing" page
    And I should see t("membership_applications.create.success")


  Scenario: A user can submit a new Membership Application with no categories
    Given I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | membership_applications.new.first_name | membership_applications.new.last_name | membership_applications.new.company_number | membership_applications.new.phone_number | membership_applications.new.contact_email |
      | Kicki                                  | Andersson                             | 5562252998                                 | 031-1234567                              | info@craft.se                             |
    And I click on t("membership_applications.new.submit_button_label")
    Then I should be on the "landing" page
    And I should see t("membership_applications.create.success")


  Scenario: Applicant not see membership number when submitting
    Given I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    Then I should not see t("membership_applications.show.membership_number")


  Scenario: Applicant can see which fields are required
    Given I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    Then the field t("membership_applications.new.first_name") should have a required field indicator
    And the field t("membership_applications.new.company_number") should have a required field indicator
    And the field t("membership_applications.new.last_name") should have a required field indicator
    And the field t("membership_applications.new.contact_email") should have a required field indicator
    And the field t("membership_applications.new.phone_number") should not have a required field indicator
    And I should see t("is_required_field")


  Scenario Outline: Apply for membership - when things go wrong
    Given I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | membership_applications.new.first_name | membership_applications.new.last_name | membership_applications.new.company_number | membership_applications.new.contact_email | membership_applications.new.phone_number |
      | <f_name>                               | <l_name>                              | <c_number>                                 | <c_email>                                 | <phone>                                  |

    When I click on t("membership_applications.new.submit_button_label")
    Then I should see error <model_attribute> <error>

    Scenarios:
      | f_name | c_number   | l_name    | c_email       | phone      | model_attribute                                                    | error                        |
      | Kicki  |            | Andersson | kicki@immi.nu | 0706898525 | t("activerecord.attributes.membership_application.company_number") | t("errors.messages.blank")   |
      | Kicki  | 5562252998 |           | kicki@immi.nu | 0706898525 | t("activerecord.attributes.membership_application.last_name")      | t("errors.messages.blank")   |
      | Kicki  | 5562252998 | Andersson |               | 0706898525 | t("activerecord.attributes.membership_application.contact_email")  | t("errors.messages.blank")   |
      |        | 5562252998 | Andersson | kicki@immi.nu | 0706898525 | t("activerecord.attributes.membership_application.first_name")     | t("errors.messages.blank")   |
      | Kicki  | 5562252998 | Andersson | kicki@imminu  | 0706898525 | t("activerecord.attributes.membership_application.contact_email")  | t("errors.messages.invalid") |
      | Kicki  | 5562252998 | Andersson | kickiimmi.nu  | 0706898525 | t("activerecord.attributes.membership_application.contact_email")  | t("errors.messages.invalid") |


  Scenario Outline: Apply for membership: company number wrong length
    Given I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | membership_applications.new.first_name | membership_applications.new.last_name | membership_applications.new.company_number | membership_applications.new.contact_email | membership_applications.new.phone_number |
      | <f_name>                               | <l_name>                              | <c_number>                                 | <c_email>                                 | <phone>                                  |

    And I click on t("membership_applications.new.submit_button_label")
    Then I should see <error>

    Scenarios:
      | f_name | c_number | l_name    | c_email       | phone      | error                                                     |
      | Kicki  | 00       | Andersson | kicki@immi.nu | 0706898525 | t("errors.messages.wrong_length", count: 10)|


  Scenario: Cannot change locale if there are errors in the new application
    Given I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | membership_applications.new.first_name | membership_applications.new.last_name | membership_applications.new.company_number | membership_applications.new.contact_email | membership_applications.new.phone_number |
      | Kicki                                  | Andersson                             | 1                                          | kicki@immi.n                              | 0706898525                               |

    And I click on t("membership_applications.new.submit_button_label")
    Then I should see t("errors.messages.wrong_length", count: 10)
    And I should not see t("show_in_swedish") image
    And I should not see t("show_in_english") image
    And I should see t("cannot_change_language") image
