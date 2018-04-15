Feature: Create a new membership application

  As a user
  In order to get a membership with SHF (which makes my business more valuable )
  I need to be able to submit a Membership Application
  And as part of the process of creating an application,
  I need to either select an existing company number for my company, or,
  If that is not available, I need to create a new company

  PT: https://www.pivotaltracker.com/story/show/133940725
  &: https://www.pivotaltracker.com/story/show/135027425

  Secondary feature:
  As an admin
  So that we can minimize trouble signing up and sign up as many users as possible
  I would like required aspects of the membership form to be highlighted when they are missed
  PT: https://www.pivotaltracker.com/story/show/134192165

  Background:
    Given the following users exists
      | email                  | admin | member | first_name | last_name |
      | applicant_1@random.com |       |        | Kicki      | Andersson |
      | applicant_2@random.com |       |        |            |           |
      | member@random.com      |       | true   | Lars       | IsaMember |
      | admin@shf.se           | yes   |        |            |           |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |

    And the following companies exist:
      | name                 | company_number | email                  | region     |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm  |

    And the following applications exist:
      | user_email        | company_number | state    |
      | member@random.com | 5560360793     | accepted |

    And I am logged in as "applicant_1@random.com"


  Scenario: A user can submit a new Membership Application with 1 category
    Given I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                           | 031-1234567                       | info@craft.se                      |
    And I select "Groomer" Category
    And I click on t("shf_applications.new.submit_button_label")
    Then I should be on the "user instructions" page
    And I should see t("shf_applications.create.success", email_address: info@craft.se)
    When I am on the "edit my application" page
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
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                           | 031-1234567                       | info@craft.se                      |
    And I select "Trainer" Category
    And I select "Psychologist" Category
    And I click on t("shf_applications.new.submit_button_label")
    Then I should be on the "user instructions" page
    And I should see t("shf_applications.create.success", email_address: info@craft.se)

  @selenium_browser
  Scenario: A user can submit a new Membership Application with no categories
    Given I am on the "new application" page
    And I fill in the translated form with data:
      | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 031-1234567                       | info@craft.se                      |

    # Create new company in modal
    And I click on t("companies.new.title")
    And I fill in t("companies.show.company_number") with "2286411992"
    And I fill in t("companies.show.email") with "info@craft.se"
    And I click on t("companies.create.create_submit")
    And I wait for all ajax requests to complete
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
    And the field t("shf_applications.new.company_number") should have a required field indicator
    And the field t("shf_applications.new.contact_email") should have a required field indicator
    And the field t("shf_applications.new.phone_number") should not have a required field indicator
    And I should see t("is_required_field")

  @selenium_browser
  Scenario: Two users can submit a new Membership Application (with empty membershipnumbers)
    And I am on the "new application" page
    And I fill in the translated form with data:
      | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 031-1234567                       | applicant_1@random.com             |

    # Create new company in modal
    And I click on t("companies.new.title")
    And I fill in t("companies.show.company_number") with "5562252998"
    And I fill in t("companies.show.email") with "info@craft.se"
    And I click on t("companies.create.create_submit")
    And I wait for all ajax requests to complete
    And I click on t("shf_applications.new.submit_button_label")

    Then I should see t("shf_applications.create.success", email_address: applicant_1@random.com)

    Given I am logged in as "applicant_2@random.com"
    And I am on the "new application" page
    And I fill in the translated form with data:
      | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 031-1234567                       | applicant_2@random.com             |

    # Create new company in modal
    And I click on t("companies.new.title")
    And I fill in t("companies.show.company_number") with "2120000142"
    And I fill in t("companies.show.email") with "info@craft.se"
    And I click on t("companies.create.create_submit")
    And I wait for all ajax requests to complete
    And I click on t("shf_applications.new.submit_button_label")

    Then I should see t("shf_applications.create.success", email_address: applicant_2@random.com)


  Scenario Outline: Apply for membership - when things go wrong with application data
    Given I am on the "new application" page
    And I fill in the translated form with data:
      | shf_applications.new.contact_email | shf_applications.new.phone_number |
      | <c_email>                          | <phone>                           |
    When I click on t("shf_applications.new.submit_button_label")
    Then I should see error <model_attribute> <error>
    And I should receive no emails
    And "admin@shf.se" should receive no emails

    Scenarios:
      | c_email       | phone      | model_attribute                                             | error                            |
      |               | 0706898525 | t("activerecord.attributes.shf_application.contact_email")  | t("errors.messages.blank")       |
      | kicki@imminu  | 0706898525 | t("activerecord.attributes.shf_application.contact_email")  | t("errors.messages.invalid")     |
      | kickiimmi.nu  | 0706898525 | t("activerecord.attributes.shf_application.contact_email")  | t("errors.messages.invalid")     |


  @selenium
  Scenario Outline: Apply for membership - when things go wrong with company create
    Given I am on the "new application" page
    And I fill in the translated form with data:
      | shf_applications.new.contact_email | shf_applications.new.phone_number |
      | <c_email>                          | <phone>                           |

    # Create new company in modal
    And I click on t("companies.new.title")
    And I fill in the translated form with data:
      | companies.show.company_number | companies.show.email |
      | <c_number>                    | <c_email>            |

    And I click on t("companies.create.create_submit")

    Then I should see error <model_attribute> <error>
    And I should receive no emails
    And "admin@shf.se" should receive no emails

    Scenarios:
      | c_number   | c_email       | phone      | model_attribute                                     | error                        |
      |            | kicki@immi.nu | 0706898525 | t("activerecord.attributes.company.company_number") | t("errors.messages.blank")   |
      | 5562252998 |               | 0706898525 | t("activerecord.attributes.company.email")          | t("errors.messages.invalid") |


  Scenario Outline: Apply for membership: company number wrong length
    Given I am on the "new application" page

    # Create new company in modal
    And I click on t("companies.new.title")
    And I fill in the translated form with data:
      | companies.show.company_number | companies.show.email |
      | <c_number>                    | <c_email>            |

    And I click on t("companies.create.create_submit")
    Then I should see <error>

    Scenarios:
      | c_number | c_email       | error                                        |
      | 00       | kicki@immi.nu | t("errors.messages.wrong_length", count: 10) |


  Scenario Outline: Cannot change locale if there are errors in the new application
    Given I am on the "new application" page

    And I fill in the translated form with data:
      | shf_applications.new.contact_email | shf_applications.new.phone_number |
      | <c_email>                          | <phone>                           |

    And I click on t("shf_applications.new.submit_button_label")
    Then I should see error <model_attribute> <error>
    And I should not see t("show_in_swedish") image
    And I should not see t("show_in_english") image
    And I should see t("cannot_change_language") image

    Scenarios:
      | c_email       | phone      | model_attribute                                             | error                            |
      | kickiimmi.nu  | 0706898525 | t("activerecord.attributes.shf_application.contact_email")  | t("errors.messages.invalid")     |


  Scenario: A member with existing application cannot submit a new application
    Given I am logged out
    And I am logged in as "member@random.com"
    And I am on the "new application" page
    Then I should see t("errors.not_permitted")


  Scenario: An admin cannot submit a new application because we don't know which User it is for
    Given I am logged in as "admin@shf.se"
    And I am on the "new application" page
    Then I should see t("errors.not_permitted")
