Feature: All companies are geocoded before being shown on the view all companies page
  As a visitor,
  so all companies are mapped when I look at the list of them,
  geocode any companies that aren't yet geocoded before everything is displayed,
  unless a company address visibility is set to 'none'

  Background:
    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    Given the following kommuns exist:
      | name      |
      | Alingsås  |
      | Bromölla  |

    Given the following companies exist:
      | name                 | company_number | email                  | region       | kommun   | visibility     |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm    | Alingsås | street_address |
      | Bowsers              | 2120000142     | bowwow@bowsersy.com    | Västerbotten | Bromölla | street_address |
      | CompanyNotVisible    | 5569467466     | company@notvisible.com | Stockholm    | Alingsås | none           |


    And the following users exists
      | email               | admin |
      | emma@happymutts.com |       |
      | a@happymutts.com    |       |
      | admin@shf.se        | true  |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Trainer      |

    And the following applications exist:
      | user_email          | company_number | categories | state    |
      | emma@happymutts.com | 5560360793     | Groomer    | accepted |
      | a@happymutts.com    | 2120000142     | Trainer    | accepted |



  Scenario: A company that isn't geocoded is geocoded before all are viewed
    Given all addresses for the company named "No More Snarky Barky" are not geocoded
    And all addresses for the company named "Bowsers" are not geocoded
    And all addresses for the company named "CompanyNotVisible" are not geocoded
    And I am Logged out
    When I am on the "landing" page
    Then all addresses for the company named "No More Snarky Barky" should be geocoded
    And all addresses for the company named "Bowsers" should be geocoded
    And all addresses for the company named "CompanyNotVisible" should not be geocoded
    And I should see "No More Snarky Barky"
    And I should see "Bowsers"
    And I should see "CompanyNotVisible"
