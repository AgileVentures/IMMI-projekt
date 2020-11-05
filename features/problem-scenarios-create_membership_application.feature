Feature: Create a new membership application [CI PROBLEM SCENARIOS]

  2020-09-10:
  These scenarios have problems: they often fail on  (CI) Semaphore.
  Problems seem to be the timing of the DOM refresh/changes and the
  different processes  used (e.g. capybara, rails).

  We know these scenarios work in real life, but we still need to have
  these scenarios working so that we are sure that they continue to
  work and so that any other changes do not cause problems with them.


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
      | email                  | admin | member | first_name | last_name | agreed_to_membership_guidelines |
      | applicant_1@random.com |       |        | Kicki      | Andersson | true                            |
      | applicant_2@random.com |       |        |            |           | true                            |
      | member@random.com      |       | true   | Lars       | IsaMember | true                            |
      | admin@shf.se           | yes   |        |            |           |                                 |

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

  # ------------------------------------------------------------


  @selenium @skip_ci_test
  Scenario: User creates App with two companies, creates one company, corrects error in company number
    Given I am on the "user instructions" page
    And I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 556036-07                            | 031-1234567                       | info@craft.se                      |
    And I select "Groomer" Category

    # Create new company in modal
    And I click on t("companies.new.title")

    And I fill in "company-number-in-modal" with "2286411992"
    And I fill in t("companies.show.email") with "info@craft.se"

    Then I want to create a new company
    And I click on t("companies.create.create_submit")

    And I select files delivery radio button "upload_later"

    And I click on t("shf_applications.new.submit_button_label")
    And I should see t("activerecord.errors.models.shf_application.attributes.companies.not_found", value: '55603607')
    Then I fill in t("shf_applications.show.company_number") with "556036-0793, 2286411992"
    And I click on t("shf_applications.new.submit_button_label")
    Then I should be on the "user account" page for "applicant_1@random.com"

    And I should see t("shf_applications.create.success_with_app_files_missing")

    When I am on the "show my application" page for "applicant_1@random.com"
    And I should see "5560360793, 2286411992"


  @selenium @skip_ci_test
  Scenario: A user cannot submit a new Membership Application with no category [SAD PATH]
    Given I am on the "user instructions" page
    And I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 031-1234567                       | info@craft.se                      |

    # Create new company in modal
    And I click on t("companies.new.title")

    And I fill in "company-number-in-modal" with "2286411992"
    And I fill in t("companies.show.email") with "info@craft.se"

    Then I want to create a new company
    And I click on t("companies.create.create_submit")

    And I should see t("shf_applications.new.file_delivery_selection")

    And I select files delivery radio button "files_uploaded"

    And I click on t("shf_applications.new.submit_button_label")

    Then I should see error t("activerecord.attributes.shf_application.business_categories") t("errors.messages.blank")

    Then I select "Groomer" Category
    And I click on t("shf_applications.new.submit_button_label")

    And I should see t("shf_applications.create.success_with_app_files_missing")


  @selenium @skip_ci_test
  Scenario: Two users can submit a new Membership Application (with empty membership numbers)
    Given I am on the "user instructions" page
    And I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 031-1234567                       | applicant_1@random.com             |
    And I select "Groomer" Category

    # Create new company in modal
    And I click on t("companies.new.title")

    And I fill in "company-number-in-modal" with "5562252998"
    And I fill in t("companies.show.email") with "info@craft.se"

    Then I want to create a new company
    And I click on t("companies.create.create_submit")

    And I should see t("shf_applications.new.file_delivery_selection")

    And I select files delivery radio button "upload_later"

    And I click on t("shf_applications.new.submit_button_label")

    And I should see t("shf_applications.create.success_with_app_files_missing")

    Given I am logged in as "applicant_2@random.com"
    Given I am on the "user instructions" page
    And I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 2120000142                           | 031-1234567                       | applicant_2@random.com             |
    And I select "Groomer" Category

    # Create new company in modal
    And I click on t("companies.new.title")

    And I fill in "company-number-in-modal" with "6112107039"
    And I fill in t("companies.show.email") with "info@craft.se"

    Then I want to create a new company
    And I click on t("companies.create.create_submit")

    And I select files delivery radio button "upload_later"

    And I click on t("shf_applications.new.submit_button_label")
