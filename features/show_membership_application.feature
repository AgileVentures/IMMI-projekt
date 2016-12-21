Feature: As an Admin
  So that we can accept or reject new Memberships,
  I need to review a Membership Application that has been submitted
  PT: https://www.pivotaltracker.com/story/show/133950343

  Secondary feature:
  As an admin
  In order to handle new member applications
  I need to be able to log in to an admin part of the site

  PT: https://www.pivotaltracker.com/story/show/133080839

  Background:
    Given the following users exists
      | email           | admin |
      | emma@random.com |       |
      | hans@random.com |       |
      | anna@random.com |       |
      | admin@sgf.com   | true  |

    And the following applications exist:
      | first_name | user_email      | company_number | status   |
      | Emma       | emma@random.com | 5562252998     | Godkänd  |
      | Hans       | hans@random.com | 5560360793     | Inlämnad  |
      | Anna       | anna@random.com | 2120000142     | Inlämnad  |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |

  Scenario: Listing incoming Applications open for Admin
    Given I am logged in as "admin@sgf.com"
    And I am on the list applications page
    Then I should see "3" applications
    And I click on "Emma Lastname"
    Then I should be on the application page for "Emma"
    And I should see "Emma Lastname"
    And I should see "5562252998"

  Scenario: Admin can see an application with one business categories given
    Given I am logged in as "hans@random.com"
    And I am on the "landing" page
    And I click on "Min ansökan"
    And I select "Groomer" Category
    And I click on t("membership_applications.edit.submit_button_label")
    And I am Logged out
    And I am logged in as "admin@sgf.com"
    And I am on the list applications page
    Then I should see "3" applications
    And I click on "Hans Lastname"
    Then I should be on the application page for "Hans"
    And I should see "Hans Lastname"
    And I should see "5560360793"
    And I should see "Groomer"
    And I should not see "Trainer"
    And I should not see "Psychologist"

  Scenario: Admin can see an application with multiple business categories given
    Given I am logged in as "emma@random.com"
    And I am on the "landing" page
    And I click on "Min ansökan"
    And I select "Trainer" Category
    And I select "Psychologist" Category
    And I click on t("membership_applications.edit.submit_button_label")
    And I am Logged out
    And I am logged in as "admin@sgf.com"
    And I am on the list applications page
    Then I should see "3" applications
    And I click on "Emma Lastname"
    Then I should be on the application page for "Emma"
    And I should see "Emma Lastname"
    And I should see "5562252998"
    And I should see "Trainer"
    And I should see "Psychologist"
    And I should not see "Groomer"

  Scenario: Approved member should see membership number
    Given I am logged in as "emma@random.com"
    And I am on the "landing" page
    And I click on "Min ansökan"
    Then I should see "Medlemsnummer"

  Scenario: Listing incoming Applications restricted for Non-admins
    Given I am logged in as "hans@random.com"
    And I am on the list applications page
    Then I should see "Du har inte behörighet att göra detta."

  Scenario: Clicking the edit button on show page
    Given I am logged in as "admin@sgf.com"
    When I am on the application page for "Emma"
    And I click on "Redigera ansökan"
    Then I should be on the edit application page for "Emma"

  Scenario: User does not see edit-link
    Given I am logged in as "emma@random.com"
    When I am on the application page for "Emma"
    Then I should not see "Redigera ansökan"
