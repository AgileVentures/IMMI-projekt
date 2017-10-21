Feature: As a visitor
  So that I can how near or far a company is
  Show me the company location on a map on the company details page

  PivotalTracker https://www.pivotaltracker.com/story/show/133079479


  Background:

    Given the following users exist
      | email               | admin |
      | emma@happymutts.com |       |


    And the following regions exist:
      | name       |
      | Norrbotten |

    And the following kommuns exist:
      | name       |
      | Övertorneå |


    And the following companies exist:
      | name                 | company_number | email                  | region     | kommun     | city       | post_code | street_address    |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Norrbotten | Övertorneå | Övertorneå | 957 31    | Matarengivägen 24 |


    And the following business categories exist
      | name    |
      | Groomer |


    And the following applications exist:
      | user_email          | company_number | categories | state    |
      | emma@happymutts.com | 5560360793     | Groomer    | accepted |


  @selenium
  Scenario: Show the company location on the Company detail page (popup should not link to the detail page)
    Given I am on the page for company number "5560360793"
    Then I should see xpath "//*[@id='map']"

