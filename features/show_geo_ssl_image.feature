Feature: As a visitor
  So that I can be sure that the map search is secure
  I want to see the GeoTrust SSL certificate Image

  PivotalTracker https://www.pivotaltracker.com/story/show/162063275


  Scenario:
    Given I am on the search page with the map "https://hitta.sverigeshundforetagare.se/"
    Then show me the page
    And I should see the GeoTrust SSL certificate Image
