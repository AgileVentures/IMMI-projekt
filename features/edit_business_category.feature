Feature: As an admin
  In order to keep business categories correct and helpful to visitors and members
  I need to be able to edit and update them

  PT: https://www.pivotaltracker.com/story/show/135009339


  Background:
    Given the following users exists
      | email                | admin |
      | applicant@random.com |       |
      | admin@shf.com        | true  |

    And the following business categories exist
      | name         | description                     |
      | dog grooming | grooming dogs from head to tail |
      | dog crooning | crooning to dogs                |


  Scenario: Admin wants to edit a business category
    Given I am logged in as "admin@shf.com"
    And I am on the "business categories" page
    And I click the "Redigera" action for the row with "dog grooming"
    Then I should see "Redigerar: dog grooming"
    And I fill in "Category Name" with "doggy grooming"
    And I click on "Save"
    Then I should see "Kategori uppdaterad"
    And I should see "doggy grooming"


  Scenario: Admin makes a mistake when editing a business category = sad path
    Given I am logged in as "admin@shf.com"
    And I am on the "business categories" page
    Then I should see "dog crooning"
    And I should see "dog grooming"
    And I click the "Redigera" action for the row with "dog crooning"
    Then I should see "Redigerar: dog crooning"
    And I fill in "Category Name" with ""
    And I click on "Save"
    Then I should see "Name can't be blank"


  Scenario: A non-admin user cannot edit business categories
    Given I am logged in as "applicant_1@random.com"
    And I navigate to the business category edit page for "dog grooming"
    Then I should see "Du har inte behörighet att göra detta."

  Scenario: A visitor cannot edit business categories
    Given I am Logged out
    And I navigate to the business category edit page for "dog grooming"
    Then I should see "Du har inte behörighet att göra detta."