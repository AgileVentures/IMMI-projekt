Feature: As a visitor,
  so that I can find companies that can offer me services,
  I want to see all companies

  Background:
    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    Given the following companies exist:
      | name                 | company_number | email                  | region       |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm    |
      | Bowsers              | 2120000142     | bowwow@bowsersy.com    | Västerbotten |

    And the following users exists
      | email               | admin |
      | emma@happymutts.com |       |
      | a@happymutts.com    |       |
      | admin@shf.se        | true  |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |

    And the following applications exist:
      | first_name | user_email          | company_number | status  | category_name |
      | Emma       | emma@happymutts.com | 5560360793     | Godkänd | Groomer       |
      | Anna       | a@happymutts.com    | 2120000142     | Godkänd | Groomer       |

  @javascript
  Scenario: Visitor sees all companies
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I should see "Bowsers"
    And I should see "No More Snarky Barky"
    And I should see "Groomer"
    And I should not see "Psychologist"
    And I should not see t("companies.new_company")

  Scenario: User sees all the companies
    Given I am logged in as "emma@happymutts.com"
    And I am on the "landing" page
    Then I should see t("companies.index.title")
    And I should see "Bowsers"
    And I should see "No More Snarky Barky"
    And I should not see t("companies.new_company")
