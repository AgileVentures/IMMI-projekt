Feature: As a visitor,
  So that I can see if a company can provide the services I need,
  Show me the details about a company
  And show the address details consistent with the visibility setting

  Because some Org Nr.s are actually for individuals and we don't have a reliable
  way to tell if they are or not, and because we do not want to
  (and legally cannot) show the org nr. for an individual,
  only show the Org Nr to admins.

  PivotalTracker: https://www.pivotaltracker.com/story/show/135474603


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
      | Company3             | 6613265393     | cmpy3@mail.com         | Stockholm    | Alingsås | post_code      |
      | Company4             | 6222279082     | cmpy4@mail.com         | Stockholm    | Alingsås | city           |
      | Company5             | 8025085252     | cmpy5@mail.com         | Stockholm    | Alingsås | kommun         |
      | Company6             | 6914762726     | cmpy6@mail.com         | Stockholm    | Alingsås | none           |

    And the following users exists
      | email               | admin |
      | emma@happymutts.com |       |
      | a@happymutts.com    |       |
      | member@cmpy6.com    |       |
      | admin@shf.se        | true  |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | Rehab        |
      | Walker       |
      | JustForFun   |

    And the following applications exist:
      | user_email          | company_number | categories              | state    |
      | emma@happymutts.com | 5560360793     | Groomer, JustForFun     | accepted |
      | a@happymutts.com    | 2120000142     | Groomer, Trainer, Rehab | accepted |
      | emma@happymutts.com | 2120000142     | Psychologist, Groomer   | accepted |
      | a@happymutts.com    | 6613265393     | Groomer                 | accepted |
      | a@happymutts.com    | 6222279082     | Groomer                 | accepted |
      | a@happymutts.com    | 8025085252     | Groomer                 | accepted |
      | member@cmpy6.com    | 6914762726     | Groomer                 | accepted |

  Scenario: Show company details to a visitor, but don't show the org nr.
    Given I am Logged out
    And I am the page for company number "5560360793"
    Then I should not see "5560360793"
    And I should see "No More Snarky Barky"
    And I should see "Groomer"
    And I should see "JustForFun"
    And I should see "snarky@snarkybarky.com"
    And I should see "123123123"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "http://www.example.com"
    When I am the page for company number "2120000142"
    Then I should not see "2120000142"
    And I should see "Bowsers"
    And I should see "Groomer"
    And I should see "Trainer"
    And I should see "Rehab"
    And I should see "Psychologist"
    And I should see "bowwow@bowsersy.com"
    And I should see "123123123"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "http://www.example.com"

  Scenario: Show company details to member of the company, but don't show the org nr.
    Given I am logged in as "emma@happymutts.com"
    And I am the page for company number "5560360793"
    Then I should not see "5560360793"
    And I should see "No More Snarky Barky"
    And I should see "Groomer"
    And I should see "JustForFun"
    And I should see "snarky@snarkybarky.com"
    And I should see "123123123"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "http://www.example.com"

  Scenario: Show company details to admin and do show the org nr.
    Given I am logged in as "admin@shf.se"
    And I am the page for company number "5560360793"
    Then I should see "5560360793"
    And I should see "No More Snarky Barky"
    And I should see "Groomer"
    And I should see "JustForFun"
    And I should see "snarky@snarkybarky.com"
    And I should see "123123123"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "http://www.example.com"
    When I am the page for company number "2120000142"
    Then I should see "2120000142"
    And I should see "Bowsers"
    And I should see "Groomer"
    And I should see "Trainer"
    And I should see "Rehab"
    And I should see "Psychologist"
    And I should see "bowwow@bowsersy.com"
    And I should see "123123123"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "http://www.example.com"

  Scenario: Show company address to admin regardless of visibility setting
    Given I am logged in as "admin@shf.se"
    And I am the page for company number "6914762726"
    Then I should see "6914762726"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "Alingsås"

  Scenario: Show company address to member regardless of visibility setting
    Given I am logged in as "member@cmpy6.com"
    And I am the page for company number "6914762726"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "Alingsås"

  Scenario: Visitor: Don't show company street address
    Given I am Logged out
    And I am the page for company number "6613265393"
    And I should see "Company3"
    And I should not see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "Alingsås"

  Scenario: Visitor: Don't show company street address or postal code
    Given I am Logged out
    And I am the page for company number "6222279082"
    And I should see "Company4"
    And I should not see "Hundforetagarevägen 1"
    And I should not see "310 40"
    And I should see "Harplinge"
    And I should see "Alingsås"

  Scenario: Visitor: Don't show company street, postal code or city
    Given I am Logged out
    And I am the page for company number "8025085252"
    And I should see "Company5"
    And I should not see "Hundforetagarevägen 1"
    And I should not see "310 40"
    And I should not see "Harplinge"
    And I should see "Alingsås"

  Scenario: Visitor: Don't show company address
    Given I am Logged out
    And I am the page for company number "6914762726"
    And I should see "Company6"
    And I should not see "Hundforetagarevägen 1"
    And I should not see "310 40"
    And I should not see "Harplinge"
    And I should not see "Alingsås"
