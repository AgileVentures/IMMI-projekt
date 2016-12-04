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
      | email                 | admin |
      | emma@happymutts.com   |       |
      | lars@happymutts.com   |       |
      | anna@happymutts.com   |       |
      | bowser@snarkybarky.se |       |
      | admin@shf.se          | true  |

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
      | first_name | user_email            | company_number | status   | category_name |
      | Emma       | emma@happymutts.com   | 5562252998     | approved | Groomer       |
      | Lars       | lars@happymutts.com   | 5562252998     | approved | Trainer       |
      | Anna       | anna@happymutts.com   | 5562252998     | approved | Psychologist  |
      | Bowser     | bowser@snarkybarky.se | 2120000142     | approved | Agility!       |


  Scenario: Categories of 3 employees all show for a company
    Given I am Logged out
    And I am the page for company number "5562252998"
    Then I should see "Groomer"
    And I should see "Trainer"
    And I should see "Psychologist"
    And I should not see "Rehab"