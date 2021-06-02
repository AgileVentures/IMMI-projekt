Feature: Create a new membership application

  2020-09-10:  Note that 2 scenarios have been removed from this feature file
    and put into 'problem-scenarios-create_membership_application.feature'.
    They have been causing intermittent failures during CI Semaphore tests.
    See the note in that file for more info.

  As a user
  In order to get a membership with SHF (which makes my business more valuable )
  I need to be able to submit a Membership Application
  And as part of the process of creating an application,
  I need to either specify an existing company number for my company, or,
  If that is not available, I need to create a new company

  PT: https://www.pivotaltracker.com/story/show/133940725
  &: https://www.pivotaltracker.com/story/show/135027425

  Secondary feature:
  As an admin
  So that we can minimize trouble signing up and sign up as many users as possible
  I would like required aspects of the membership form to be highlighted when they are missed
  PT: https://www.pivotaltracker.com/story/show/134192165

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist
      | email                  | admin | member | first_name | last_name |
      | applicant_1@random.com |       |        | Kicki      | Andersson |
      | applicant_2@random.com |       |        |            |           |
      | member@random.com      |       | true   | Lars       | IsaMember |
      | admin@shf.se           | yes   |        |            |           |
      | mandalorian@random.com | false |        | Din        | Djarin    |
    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |

    And the application file upload options exist
    And the Membership Ethical Guidelines Master Checklist exists

    And the following companies exist:
      | name                 | company_number | email                  | region     |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm  |
      | Good Dog Spot        | 2120000142     | spot@gooddog.com       | Stockholm  |

    And the following applications exist:
      | user_email        | company_number | state    | categories |
      | member@random.com | 5560360793     | accepted | Groomer    |

    And I am logged in as "applicant_1@random.com"

  @selenium
  Scenario: Successful app, no files uploaded, user sees success message and files delivery reminder
    Given I am on the "user account" page
    And I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                           | 031-1234567                       | info@craft.se                      |
    And I select "Groomer" Category

    And I select files delivery radio button "upload_now"

    And I click on t("shf_applications.new.submit_button_label")
    Then I should be on the "user account" page for "applicant_1@random.com"
    And I should see t("shf_applications.create.success_with_app_files_missing")
    When I am on the "edit my application" page
    Then "applicant_1@random.com" should receive an email
    And I open the email
    And I should see t("mailers.shf_application_mailer.acknowledge_received.subject") in the email subject
    And I am logged in as "admin@shf.se"
    Then "admin@shf.se" should receive an email
    And I open the email
    And I should see t("mailers.admin_mailer.new_application_received.subject") in the email subject

  @selenium
  Scenario: Successful app, with files uploaded, user sees success message
    Given I am on the "user account" page
    And I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                           | 031-1234567                       | info@craft.se                      |

    And I select "Groomer" Category

    And I choose a file named "diploma.pdf" to upload for the application

    And I select files delivery radio button "upload_now"

    And I click on t("shf_applications.new.submit_button_label")

    Then I should be on the "user account" page for "applicant_1@random.com"

    And I should see t("shf_applications.create.success", email_address: info@craft.se)

    When I am on the "edit my application" page
    Then "applicant_1@random.com" should receive an email
    And I open the email
    And I should see t("mailers.shf_application_mailer.acknowledge_received.subject") in the email subject
    And I am logged in as "admin@shf.se"
    Then "admin@shf.se" should receive an email
    And I open the email
    And I should see t("mailers.admin_mailer.new_application_received.subject") in the email subject

  @selenium
  Scenario: Successful app, files to be sent via email, user sees success message and reminder to deliver files
    Given I am on the "user account" page
    And I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                           | 031-1234567                       | info@craft.se                      |

    And I select "Groomer" Category

    And I select files delivery radio button "email"

    And I click on t("shf_applications.new.submit_button_label")

    Then I should be on the "user account" page for "applicant_1@random.com"

    And I should see t("shf_applications.create.success_with_app_files_missing")
    And I should see t("shf_applications.create.remember_to_deliver_files")

    When I am on the "edit my application" page
    Then "applicant_1@random.com" should receive an email
    And I open the email
    And I should see t("mailers.shf_application_mailer.acknowledge_received.subject") in the email subject
    And I am logged in as "admin@shf.se"
    Then "admin@shf.se" should receive an email
    And I open the email
    And I should see t("mailers.admin_mailer.new_application_received.subject") in the email subject

  @selenium
  Scenario: Successful App, two companies, no file upload, message: success, but need to deliver files
    Given I am on the "user account" page
    And I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793, 212000-0142              | 031-1234567                       | info@craft.se                      |
    And I select "Groomer" Category

    And I select files delivery radio button "upload_now"

    And I click on t("shf_applications.new.submit_button_label")
    Then I should be on the "user account" page for "applicant_1@random.com"

    And I should see t("shf_applications.create.success_with_app_files_missing")

    And I should see t("shf_applications.create.upload_file_or_select_method")

    When I am on the "show my application" page for "applicant_1@random.com"
    And I should see "5560360793, 2120000142"
    Then "applicant_1@random.com" should receive an email
    And I open the email
    And I should see t("mailers.shf_application_mailer.acknowledge_received.subject") in the email subject
    And I am logged in as "admin@shf.se"
    Then "admin@shf.se" should receive an email
    And I open the email
    And I should see t("mailers.admin_mailer.new_application_received.subject") in the email subject

  @selenium
  Scenario: User creates App with two companies, corrects an error in company number
    Given I am on the "user account" page
    And I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 556036-07, 2120000142                | 031-1234567                       | info@craft.se                      |
    And I select "Groomer" Category

    And I select files delivery radio button "files_uploaded"

    And I click on t("shf_applications.new.submit_button_label")
    And I should see t("activerecord.errors.models.shf_application.attributes.companies.not_found", value: '55603607')
    Then I fill in t("shf_applications.show.company_number") with "556036-0793, 2120000142"
    And I click on t("shf_applications.new.submit_button_label")
    Then I should be on the "user account" page for "applicant_1@random.com"

    And I should see t("shf_applications.create.success_with_app_files_missing")

    When I am on the "show my application" page for "applicant_1@random.com"
    And I should see "5560360793, 2120000142"

  @selenium
  Scenario: A user can submit a new Membership Application with multiple categories
    Given I am on the "user account" page
    And I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                           | 031-1234567                       | info@craft.se                      |
    And I select "Trainer" Category
    And I select "Psychologist" Category

    And I select files delivery radio button "files_uploaded"

    And I click on t("shf_applications.new.submit_button_label")
    Then I should be on the "user account" page for "applicant_1@random.com"

    And I should see t("shf_applications.create.success_with_app_files_missing")


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


  @selenium
  Scenario Outline: Apply for membership - when things go wrong with application data [SAD PATH]
    Given I am on the "new application" page
    And I fill in the translated form with data:
      | shf_applications.new.contact_email | shf_applications.new.phone_number |
      | <c_email>                          | <phone>                           |

    And I select files delivery radio button "files_uploaded"

    When I click on t("shf_applications.new.submit_button_label")

    Then I should see error <model_attribute> <error>
    And I should receive no emails
    And "admin@shf.se" should receive no emails
    And I should not see t("shf_applications.uploads.please_upload_again")

    Scenarios:
      | c_email       | phone      | model_attribute                                                   | error                            |
      |               | 0706898525 | t("activerecord.attributes.shf_application.contact_email")        | t("errors.messages.blank")       |
      |               | 0706898525 | t("activerecord.attributes.shf_application.business_categories")  | t("errors.messages.blank")       |
      | kicki@imminu  | 0706898525 | t("activerecord.attributes.shf_application.contact_email")        | t("errors.messages.invalid")     |
      # | kickiimmi.nu  | 0706898525 | t("activerecord.attributes.shf_application.contact_email")        | t("errors.messages.invalid")     |

  @selenium
  Scenario Outline: Apply for membership with uploads, errors should show please upload again message [SAD PATH]
    Given I am on the "new application" page
    And I fill in the translated form with data:
      | shf_applications.new.contact_email | shf_applications.new.phone_number |
      | <c_email>                          | <phone>                           |

    And I choose a file named "diploma.pdf" to upload for the application

    And I select files delivery radio button "files_uploaded"

    When I click on t("shf_applications.new.submit_button_label")
    Then I should see t("shf_applications.uploads.please_upload_again")

    Scenarios:
      | c_email       | phone      |
      |               | 0706898525 |
      |               | 0706898525 |
      | kicki@imminu  | 0706898525 |
      # | kickiimmi.nu  | 0706898525 |




  @selenium
  Scenario Outline: Apply for membership - when things go wrong with company create [SAD PATH]
    Given I am on the "new application" page
    And I fill in the translated form with data:
      | shf_applications.new.contact_email | shf_applications.new.phone_number |
      | <c_email>                          | <phone>                           |

    And I select files delivery radio button "files_uploaded"

    # Create new company in modal
    Then I want to create a new company
    And I click on t("companies.new.title")
    And I fill in the translated form with data:
      | companies.company_create_modal.company_number | companies.show.email |
      | <c_number>                                    | <c_email>            |

    And I click on t("companies.create.create_submit")

    Then I should see error <model_attribute> <error>
    And I should receive no emails
    And "admin@shf.se" should receive no emails

    Scenarios:
      | c_number   | c_email       | phone      | model_attribute                                     | error                        |
      |            | kicki@immi.nu | 0706898525 | t("activerecord.attributes.company.company_number") | t("errors.messages.blank")   |
      | 5562252998 |               | 0706898525 | t("activerecord.attributes.company.email")          | t("errors.messages.invalid") |


  Scenario: Apply for membership: company number wrong length (no uploads) [SAD PATH]
    Given I am on the "new application" page

    # Create new company in modal
    And I click on t("companies.new.title")

    And I fill in "company-number-in-modal" with "00"
    And I fill in t("companies.show.email") with "kicki@immi.nu"

    And I click on t("companies.create.create_submit")
    Then I should not see t("shf_applications.uploads.please_upload_again")

  @selenium
  Scenario Outline: Cannot change locale if there are errors in the new application
    Given I am on the "new application" page

    And I fill in the translated form with data:
      | shf_applications.new.contact_email | shf_applications.new.phone_number |
      | <c_email>                          | <phone>                           |

    And I select files delivery radio button "files_uploaded"

    And I click on t("shf_applications.new.submit_button_label")

    Then I should see error <model_attribute> <error>
    And I should not see t("show_in_swedish") image
    And I should not see t("show_in_english") image
    And I should see t("cannot_change_language") image

    Scenarios:
      | c_email       | phone      | model_attribute                                             | error                            |
      | kicki@imminu  | 0706898525 | t("activerecord.attributes.shf_application.contact_email")  | t("errors.messages.invalid")     |


  Scenario: A member with existing application cannot submit a new application
    Given I am logged out
    And I am logged in as "member@random.com"
    And I am on the "new application" page
    Then I should see a message telling me I am not allowed to see that page


  Scenario: An admin cannot submit a new application because we don't know which User it is for
    Given I am logged in as "admin@shf.se"
    And I am on the "new application" page
    Then I should see a message telling me I am not allowed to see that page

  @selenium
  Scenario: Cannot see subcategories
    Given I am logged in as "admin@shf.se"
    And I am on the "business categories" page
    And I click the icon with CSS class "add-entity-button" for the row with "Groomer"
    And I should see t("business_categories.index.add_subcategory")
    When I fill in the translated form with data:
      | activerecord.attributes.business_category.name | activerecord.attributes.business_category.description |
      | overall grooming                               | full service grooming                                    |

    When I click on t("save")
    Then I should see "overall grooming"
    Then I am Logged out
    Given I am logged in as "mandalorian@random.com"
    Given I am on the "user account" page
    And I click on t("menus.nav.users.apply_for_membership") link
    Then I should be on the "new application" page
    And I should not see "overall grooming"
