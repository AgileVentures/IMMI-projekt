Feature: As a visitor,
  so that I can find companies that can offer me services,
  I want to see all companies

  Background:
    Given the following companies exist:
      | name                 | company_number | email                  |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com |
      | Bowsers              | 2120000142     | bowwow@bowsersy.com    |

    And the following users exists
      | email               | admin |
      | emma@happymutts.com |       |
      | a@happymutts.com    |       |
      | admin@shf.se        | true  |

    And the following applications exist:
      | first_name | user_email          | company_number | status   | category_name |
      | Emma       | emma@happymutts.com | 5560360793     | Accepted | Groomer       |
      | Anna       | a@happymutts.com    | 2120000142     | Accepted | Groomer       |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |

  Scenario: Visitor sees all companies
    Given I am Logged out
    And I am on the "landing" page
    Then I should see "Hitta H-märkt företag"
    And I should see "Bowsers"
    And I should see "No More Snarky Barky"
    And I should see "Groomer"
    And I should not see "Psychologist"
    And I should not see "Skapa nytt företag"

  Scenario: User sees all the companies
    Given I am logged in as "emma@happymutts.com"
    And I am on the "landing" page
    Then I should see "Hitta H-märkt företag"
    And I should see "Bowsers"
    And I should see "No More Snarky Barky"
    And I should not see "Skapa nytt företag"
