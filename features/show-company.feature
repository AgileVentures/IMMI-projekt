Feature: As a visitor,
  So that I can see if a company can provide the services I need,
  Show me the details about a company

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
      | name                 | company_number | email                  | region       | kommun   |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm    | Alingsås |
      | Bowsers              | 2120000142     | bowwow@bowsersy.com    | Västerbotten | Bromölla |
      | Company3             | 6613265393     | cmpy3@mail.com         | Stockholm    | Alingsås |
      | Company4             | 6222279082     | cmpy4@mail.com         | Stockholm    | Alingsås |
      | Company5             | 8025085252     | cmpy5@mail.com         | Stockholm    | Alingsås |
      | Company6             | 6914762726     | cmpy6@mail.com         | Stockholm    | Alingsås |
      | Company7             | 7661057765     | cmpy7@mail.com         | Stockholm    | Alingsås |
      | Company8             | 7736362901     | cmpy8@mail.com         | Stockholm    | Alingsås |
      | Company9             | 6112107039     | cmpy9@mail.com         | Stockholm    | Alingsås |
      | Company10            | 3609340140     | cmpy10@mail.com        | Stockholm    | Alingsås |
      | Company11            | 2965790286     | cmpy11@mail.com        | Stockholm    | Alingsås |
      | Company12            | 4268582063     | cmpy12@mail.com        | Stockholm    | Alingsås |
      | Company13            | 8028973322     | cmpy13@mail.com        | Stockholm    | Alingsås |

    And the following users exists
      | email               | admin |
      | emma@happymutts.com |       |
      | a@happymutts.com    |       |
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
      | first_name | user_email          | company_number | category_name | state    |
      | Emma       | emma@happymutts.com | 5560360793     | Groomer       | accepted |
      | Emma       | emma@happymutts.com | 5560360793     | JustForFun    | accepted |
      | Anna       | a@happymutts.com    | 2120000142     | Groomer       | accepted |
      | Anna       | a@happymutts.com    | 2120000142     | Trainer       | accepted |
      | Anna       | a@happymutts.com    | 2120000142     | Rehab         | accepted |
      | Emma       | emma@happymutts.com | 2120000142     | Psychologist  | accepted |
      | Emma       | emma@happymutts.com | 2120000142     | Groomer       | accepted |
      | Anna       | a@happymutts.com    | 6613265393     | Groomer       | accepted |
      | Anna       | a@happymutts.com    | 6222279082     | Groomer       | accepted |
      | Anna       | a@happymutts.com    | 8025085252     | Groomer       | accepted |
      | Anna       | a@happymutts.com    | 6914762726     | Groomer       | accepted |
      | Anna       | a@happymutts.com    | 7661057765     | Groomer       | accepted |
      | Anna       | a@happymutts.com    | 7736362901     | Groomer       | accepted |
      | Anna       | a@happymutts.com    | 6112107039     | Groomer       | accepted |
      | Anna       | a@happymutts.com    | 3609340140     | Groomer       | accepted |
      | Anna       | a@happymutts.com    | 2965790286     | Groomer       | accepted |
      | Anna       | a@happymutts.com    | 4268582063     | Groomer       | accepted |
      | Anna       | a@happymutts.com    | 8028973322     | Groomer       | accepted |


  Scenario: Show company details to a visitor, but don't show the org nr.
    Given I am Logged out
    And I am the page for company number "5560360793"
    Then I should not see "5560360793"
    And I should see "No More Snarky Barky"
    And I should see "Groomer"
    And I should see "JustForFun"
    And I should see "snarky@snarkybarky.com"
    And I should see "Stockholm"
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
    And I should see "Västerbotten"
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
    And I should see "Stockholm"
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
    And I should see "Stockholm"
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
    And I should see "Västerbotten"
    And I should see "123123123"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "http://www.example.com"
