Feature: As an applicant
  In order to be able to edit my application
  I want to be allowed to do that

  PT: https://www.pivotaltracker.com/story/show/134078325


  Background:
    Given the following users exists
      | first_name | email             | is_member | admin |
      | Emma       | emma@random.com   | false     |       |
      | Hans       | hans@random.com   | false     |       |
      | Nils       | nils@random.com   | true      |       |
      | Bob        | bob@barkybobs.com | true      |       |
      | admin      | admin@shf.se      | true      | true  |

    And the following applications exist:
      | user_email        | company_number | state                 |
      | emma@random.com   | 5560360793     | waiting_for_applicant |
      | hans@random.com   | 2120000142     | under_review          |
      | nils@random.com   | 2120000142     | accepted              |
      | bob@barkybobs.com | 5560360793     | rejected              |

  Scenario: Applicant wants to edit his own application
    Given I am logged in as "emma@random.com"
    And I am on the "landing" page
    And I click on t("menus.nav.users.my_application")
    Then I should be on "Edit My Application" page
    And I fill in t("membership_applications.show.first_name") with "Anna"
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.update.success")
    And I should be on the application page for "Anna"
    And I should see "Anna Lastname"

  Scenario: Applicant makes mistake when editing his own application
    Given I am logged in as "emma@random.com"
    And I am on the "landing" page
    And I click on t("menus.nav.users.my_application")
    Then I should be on "Edit My Application" page
    And I fill in t("membership_applications.show.contact_email") with "sussimmi.nu"
    And I fill in t("membership_applications.show.company_number") with ""
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.update.error")
    And I should see translated error membership_applications.show.company_number errors.messages.blank
    And I should see button t("membership_applications.edit.submit_button_label")

  Scenario: Applicant can not edit applications not created by him
    Given I am logged in as "emma@random.com"
    And I navigate to the edit page for "Hans"
    Then I should see t("errors.not_permitted")

  Scenario: Member wants to view their own application
    Given I am logged in as "nils@random.com"
    And I am on the "landing" page
    And I click on t("menus.nav.members.my_application")
    Then I should be on "Show My Application" page

  Scenario: Admin should be able to edit membership number
    Given I am logged in as "admin@shf.se"
    And I navigate to the edit page for "Nils"
    Then I should see t("membership_applications.show.membership_number")

  Scenario: Admin can't edit membership number for a rejected application
    Given I am logged in as "admin@shf.se"
    And I navigate to the edit page for "Bob"
    Then I should not see t("membership_applications.show.membership_number")

