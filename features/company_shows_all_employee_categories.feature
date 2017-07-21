Feature: As a visitor
  So that I can see if a company offers skills/services that I want,
  I want to see the skills/services of all of the employees in the
  company on the company's info page

  The way to edit them is via each individual's profile page,
  since each individual had to submit documentation about their skills on
  the company page. (So they are _not_ editable on the company page by anyone.)

  If this can't be done in the MVP, then remove the categories
  from the company page for now.

  PT https://www.pivotaltracker.com/story/show/135397241

  Background:

    Given the following users exists
      | first_name | email                 | admin |
      | Emma       | emma@happymutts.com   |       |
      | Lars       | lars@happymutts.com   |       |
      | Anna       | anna@happymutts.com   |       |
      | Bowser     | bowser@snarkybarky.se |       |
      | admin      | admin@shf.se          | true  |

    And the following companies exist:
      | name                 | company_number | email                  |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com |
      | HappyMutts           | 2120000142     | woof@happymutts.com    |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | Awesome      |
      | Rehab        |
      | Agility      |

    And the following applications exist:
      | user_email            | company_number | categories    | state    |
      | emma@happymutts.com   | 5562252998     | Groomer       | accepted |
      | lars@happymutts.com   | 5562252998     | Trainer       | accepted |
      | anna@happymutts.com   | 5562252998     | Psychologist  | accepted |
      | bowser@snarkybarky.se | 2120000142     | Agility       | accepted |


  Scenario: Categories of 3 employees all show for a company
    Given I am Logged out
    And I am the page for company number "5562252998"
    Then I should see "Groomer"
    And I should see "Trainer"
    And I should see "Psychologist"
    And I should not see "Rehab"

