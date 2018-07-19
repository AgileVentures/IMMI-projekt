Feature: As an applicant
  In order to be able to edit my application
  I want to be allowed to do that

  PT: https://www.pivotaltracker.com/story/show/134078325


  Background:
    Given the following users exists
      | email             | member    | admin |
      | emma@random.com   | false     |       |
      | hans@random.com   | false     |       |
      | nils@random.com   | true      |       |
      | bob@barkybobs.com | false     |       |
      | admin@shf.se      | true      | true  |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |

    And the following applications exist:
      | user_email        | company_number         | state                 | categories |
      | emma@random.com   | 5560360793             | waiting_for_applicant | Groomer    |
      | hans@random.com   | 2120000142, 5560360793 | under_review          | Groomer    |
      | nils@random.com   | 2120000142             | accepted              | Groomer    |
      | bob@barkybobs.com | 5560360793             | rejected              | Groomer    |

  @selenium
  Scenario: Applicant makes mistake when editing his own application
    Given I am logged in as "emma@random.com"
    Given I am on the "user instructions" page
    And I click on t("menus.nav.users.my_application")
    Then I should be on "Edit My Application" page
    And I fill in t("shf_applications.show.contact_email") with ""
    And I unselect "Groomer" Category
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.update.error")
    And I should see error t("shf_applications.show.contact_email") t("errors.messages.blank")
    Then I should see error t("activerecord.attributes.shf_application.business_categories") t("errors.messages.blank")
    And I should see button t("shf_applications.edit.submit_button_label")

  Scenario: Applicant adds second company to application
    Given I am logged in as "emma@random.com"
    And I am on the "landing" page
    And I click on t("menus.nav.users.my_application")
    Then I should be on "Edit My Application" page
    Then I fill in t("shf_applications.show.company_number") with "5560360793, 212000-0142"
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should be on the "show my application" page for "emma@random.com"
    And I should see t("shf_applications.update.success", email_address: info@craft.se)
    And I should see "5560360793, 2120000142"

  @selenium
  Scenario: Applicant creates second company for application
    Given I am logged in as "emma@random.com"
    Given I am on the "edit application" page
    Then I should be on "Edit My Application" page

    # Create new company in modal
    And I click on t("companies.new.title")
    And I fill in t("companies.show.company_number") with "2286411992"
    And I fill in t("companies.show.email") with "info@craft.se"
    And I click on t("companies.create.create_submit")
    And I wait 2 seconds
    And I wait for all ajax requests to complete

    And I click on t("shf_applications.edit.submit_button_label")
    Then I should be on the "show my application" page for "emma@random.com"
    And I should see t("shf_applications.update.success", email_address: info@craft.se)
    And I should see "5560360793, 2286411992"

  Scenario: User edit app with two companies, corrects an error in company number
    Given I am logged in as "hans@random.com"
    And I am on the "landing" page
    And I click on t("menus.nav.users.my_application")
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
    And I should see t("shf_applications.update.success", email_address: info@craft.se)
    And I should see "5560360793, 2120000142"

  Scenario: Applicant can not edit applications not created by him
    Given I am logged in as "emma@random.com"
    And I am on the "edit application" page for "hans@random.com"
    Then I should see t("errors.not_permitted")

  Scenario: Applicant can not edit accepted application
    Given I am logged in as "nils@random.com"
    And I am on the "edit application" page for "nils@random.com"
    Then I should see t("errors.not_permitted")

  Scenario: Applicant can view accepted application
    Given I am logged in as "nils@random.com"
    And I am on the "show my application" page for "nils@random.com"
    Then I should not see t("errors.not_permitted")
    And I should see t("shf_applications.accepted")

  Scenario: Applicant can not edit rejected application
    Given I am logged in as "bob@barkybobs.com"
    And I am on the "edit application" page for "bob@barkybobs.com"
    Then I should see t("errors.not_permitted")

  Scenario: Applicant can view rejected application
    Given I am logged in as "bob@barkybobs.com"
    And I am on the "show my application" page for "bob@barkybobs.com"
    Then I should not see t("errors.not_permitted")
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

  Scenario: Admin can't edit membership number for a rejected application
    Given I am logged in as "admin@shf.se"
    And I am on the "edit application" page for "bob@barkybobs.com"
    And I should not see t("shf_applications.edit.submit_button_label")

  Scenario: Cannot change locale if there are errors in the application
    Given I am logged in as "emma@random.com"
    And I am on the "landing" page
    And I click on t("menus.nav.users.my_application")
    Then I should be on "Edit My Application" page
    And I fill in t("shf_applications.show.contact_email") with "sussimmi.nu"
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.update.error")
    And I should not see t("show_in_swedish") image
    And I should not see t("show_in_english") image
    And I should see t("cannot_change_language") image
