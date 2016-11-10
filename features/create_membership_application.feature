Feature: As a visitor
  In order to get a membership with SHF (which makes my business more valuable )
  I need to be able to submit a Membership Application

  PT Feature: https://www.pivotaltracker.com/story/show/133940725


  Scenario: Visitor can submit a new Membership Application
    Given I am on the landing page
    And I click on "Apply for membership"
    And I fill in "Company Name" with "Craft Academy"
    And I fill in "Company Number" with "1234561234"
    And I fill in "Contact Person" with "Thomas"
    And I fill in "Company Email" with "info@craft.se"
    And I fill in "Phone Number" with "031-1234567"
    And I click on "Submit"
    Then I should be on the landing page
    And I should see "Thank you, Your application has been submitted"


  #TODO: Add sad path scenarios. 