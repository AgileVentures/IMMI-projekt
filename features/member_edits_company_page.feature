Feature: As a member
  So that visitors can see if my company offers services they might be interested in
  I need to be able to set a page that displays information about my company

  PT:  https://www.pivotaltracker.com/story/show/133081453

  Background:
    Given the following users exists
      | email                      | admin |
      | applicant_1@happymutts.com |       |
      | admin@shf.se               | true  |

    And the following companies exist:
      | name                 | company_number | email                  |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com |

    And the following applications exist:
      | first_name | user_email                 | company_number | status   | category_name |
      | Emma       | applicant_1@happymutts.com | 5562252998     | approved | Awesome       |


  Scenario: Member goes to company page after membership approval
    Given I am logged in as "applicant_1@happymutts.com"
    And I am on the "landing" page
    When I am on the "edit my company" page
    And I fill in the form with data :
      | Name         | Street         | Post Code | City   | Region    | Email                | Website                   |
      | Glada Jyckar | Ålstensgatan 4 | 123 45    | Bromma | Stockholm | kicki@gladajyckar.se | http://www.gladajyckar.se |
    And I click on "Submit"
    Then I should see "The company was successfully updated."
    And I should see "Company: Glada Jyckar"
    And I should see "123 45"
    And I should see "Bromma"
    #And I should see "Awesome"

#  Scenario: User tries to go do company page (sad path)
#    Given I am logged in as "applicant_2@random.com"
#    And I am on the "my company page" page
#    Then I should see "You are not authorized to perform this action"

  Scenario: Admin views all companies
    Given I am logged in as "admin@shf.se"
    And I am on the "all companies" page
    Then I should see "Companies"


  Scenario: Admin creates a company

  Scenario: Admin edits a company


  Scenario: User tries to create a company
    Given I am logged in as "applicant_1@happymutts.com"
    And I am on the "create a new company" page
    Then I should see "You are not authorized to perform this action"

  Scenario: User tries to view all companies
    Given I am logged in as "applicant_1@happymutts.com"
    And I am on the "all companies" page
    Then I should see "You are not authorized to perform this action"

  Scenario: Visitor tries to view all companies
    Given I am Logged out
    And I am on the "all companies" page
    Then I should see "You are not authorized to perform this action"

  Scenario: Visitor tries to create a company
    Given I am Logged out
    And I am on the "create a new company" page
    Then I should see "You are not authorized to perform this action"
