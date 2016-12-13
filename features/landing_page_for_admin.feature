Feature: As an Admin
  So that I can deal with member applications
  Show me a specific landing page with member applications that need attention

  PT: https://www.pivotaltracker.com/story/show/135683887

  Background:
    Given the following users exists
      | email              | is_member | admin |
      | emma@happymutts.se | true      |       |
      | hans@bowsers.com   | false     |       |
      | admin@shf.se       | true      | true  |



  Scenario: After login, Admin sees new memberships on their landing page
    Given I am logged in as "admin@shf.se"
    When I am on the "landing" page
    Then I should see "Alla inkomna ansökningar"
    And I should see "Du är inloggad som admin"

  Scenario: After login, User sees instructions about applying for membership
    Given I am logged in as "hans@bowsers.com"
    When I am on the "landing" page
    Then I should not see "Alla inkomna ansökningar"
    And I should not see "Du är inloggad som admin"

  Scenario: After login, Member sees instructions about using their badge, etc
    Given I am logged in as "emma@happymutts.se"
    When I am on the "landing" page
    Then I should not see "Alla inkomna ansökningar"
    And I should not see "Du är inloggad som admin"


  Scenario: Visitor does not see instructions
    Given I am Logged out
    When I am on the "landing" page
    Then I should not see "Alla inkomna ansökningar"
    And I should not see "Du är inloggad som admin"

